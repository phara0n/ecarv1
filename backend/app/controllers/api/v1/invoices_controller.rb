module Api
  module V1
    class InvoicesController < BaseController
      before_action :set_vehicle
      before_action :set_repair
      before_action :set_invoice, only: [:show, :update, :destroy]
      
      # GET /api/v1/vehicles/:vehicle_id/repairs/:repair_id/invoices
      def index
        @invoices = @repair.invoice
        render json: @invoices
      end
      
      # GET /api/v1/vehicles/:vehicle_id/repairs/:repair_id/invoices/:id
      def show
        render json: @invoice
      end
      
      # POST /api/v1/vehicles/:vehicle_id/repairs/:repair_id/invoices
      def create
        @invoice = @repair.build_invoice(invoice_params)
        
        if @invoice.save
          render json: @invoice, status: :created
        else
          render json: { errors: @invoice.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # PUT /api/v1/vehicles/:vehicle_id/repairs/:repair_id/invoices/:id
      def update
        if @invoice.update(invoice_params)
          render json: @invoice
        else
          render json: { errors: @invoice.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/vehicles/:vehicle_id/repairs/:repair_id/invoices/:id
      def destroy
        @invoice.destroy
        head :no_content
      end
      
      private
      
      def set_vehicle
        @vehicle = current_user.vehicles.find(params[:vehicle_id])
      end
      
      def set_repair
        @repair = @vehicle.repairs.find(params[:repair_id])
      end
      
      def set_invoice
        @invoice = @repair.invoice
      end
      
      def invoice_params
        params.require(:invoice).permit(:amount, :payment_status, :pdf_document, :vat_amount, :payment_method)
      end
    end
  end
end
