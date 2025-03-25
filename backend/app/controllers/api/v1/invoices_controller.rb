module Api
  module V1
    class InvoicesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_invoice, only: [:show, :update, :destroy, :download, :update_payment]
      
      # GET /api/v1/invoices
      def index
        # Different behavior based on user role
        if current_user.admin? || current_user.manager?
          # Administrators see all invoices with filtering options
          @invoices = Invoice.includes(:repair, :customer)
                            .order(issue_date: :desc)
          
          # Apply filters if provided
          @invoices = @invoices.where(payment_status: params[:payment_status]) if params[:payment_status].present?
          @invoices = @invoices.where(customer_id: params[:customer_id]) if params[:customer_id].present?
          @invoices = @invoices.where(issue_date: params[:start_date]..params[:end_date]) if params[:start_date].present? && params[:end_date].present?
          
        elsif current_user.customer?
          # Customers only see their own invoices
          @invoices = current_user.invoices.includes(:repair)
                                 .order(issue_date: :desc)
        else
          # Technicians see invoices related to their repairs
          @invoices = Invoice.joins(:repair)
                            .where(repairs: { technician_id: current_user.id })
                            .includes(:customer)
                            .order(issue_date: :desc)
        end
        
        # Paginate results
        @invoices = @invoices.page(params[:page] || 1).per(params[:per_page] || 10)
        
        render json: {
          invoices: ActiveModelSerializers::SerializableResource.new(@invoices, each_serializer: InvoiceSerializer),
          meta: {
            total_count: @invoices.total_count,
            total_pages: @invoices.total_pages,
            current_page: @invoices.current_page
          }
        }
      end
      
      # GET /api/v1/invoices/:id
      def show
        authorize @invoice
        render json: @invoice, serializer: InvoiceDetailSerializer
      end
      
      # POST /api/v1/invoices
      def create
        # Only admins and managers can create invoices
        authorize Invoice
        
        @invoice = Invoice.new(invoice_params)
        
        # Set default values for Tunisian invoice requirements
        @invoice.fiscal_id = "123456789" # Example fiscal ID
        @invoice.commercial_registry = "B987654321" # Example commercial registry
        
        if @invoice.save
          # Generate PDF with Tunisian "Facturation Normalisée" format
          @invoice.generate_pdf
          
          # Send notification to customer about new invoice
          InvoiceMailer.invoice_created(@invoice).deliver_later if @invoice.customer.email.present?
          
          render json: @invoice, serializer: InvoiceDetailSerializer, status: :created
        else
          render json: { errors: @invoice.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # PATCH/PUT /api/v1/invoices/:id
      def update
        authorize @invoice
        
        if @invoice.update(invoice_params)
          # Regenerate PDF if amounts changed
          @invoice.generate_pdf if invoice_params[:amount].present? || invoice_params[:tax_amount].present?
          
          render json: @invoice, serializer: InvoiceDetailSerializer
        else
          render json: { errors: @invoice.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/invoices/:id
      def destroy
        authorize @invoice
        @invoice.destroy
        head :no_content
      end
      
      # GET /api/v1/invoices/:id/download
      def download
        authorize @invoice
        
        if @invoice.pdf_file.attached?
          redirect_to rails_blob_url(@invoice.pdf_file), allow_other_host: true
        else
          # Generate PDF if it doesn't exist
          @invoice.generate_pdf
          redirect_to rails_blob_url(@invoice.pdf_file), allow_other_host: true
        end
      end
      
      # PATCH /api/v1/invoices/:id/update_payment
      def update_payment
        authorize @invoice
        
        # Handle partial payments (common in Tunisia)
        if payment_params[:payment_method].present? && payment_params[:paid_amount].present?
          paid_amount = payment_params[:paid_amount].to_f
          
          # Update paid amount
          @invoice.paid_amount = paid_amount
          @invoice.payment_date = Date.today
          @invoice.payment_method = payment_params[:payment_method]
          
          # Set payment status based on paid amount
          if paid_amount >= @invoice.total_amount
            @invoice.payment_status = :paid
          elsif paid_amount > 0
            @invoice.payment_status = :partial
          else
            @invoice.payment_status = :unpaid
          end
          
          if @invoice.save
            # Send notification to customer about payment status
            InvoiceMailer.payment_updated(@invoice).deliver_later if @invoice.customer.email.present?
            
            render json: @invoice, serializer: InvoiceDetailSerializer
          else
            render json: { errors: @invoice.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { errors: ["Payment method and amount are required"] }, status: :unprocessable_entity
        end
      end
      
      private
      
      def set_invoice
        @invoice = Invoice.find(params[:id])
      end
      
      def invoice_params
        params.require(:invoice).permit(
          :repair_id, 
          :customer_id, 
          :amount, 
          :tax_amount, 
          :issue_date, 
          :due_date, 
          :payment_status, 
          :payment_method
        )
      end
      
      def payment_params
        params.require(:payment).permit(:payment_method, :paid_amount)
      end
    end
  end
end
