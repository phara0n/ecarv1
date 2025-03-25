module Api
  module V1
    class CustomersController < BaseController
      before_action :set_customer, only: [:show, :update, :destroy]
      
      # GET /api/v1/customers
      def index
        @customers = Customer.all
        render json: @customers
      end
      
      # GET /api/v1/customers/:id
      def show
        render json: @customer
      end
      
      # POST /api/v1/customers
      def create
        @customer = Customer.new(customer_params)
        
        if @customer.save
          render json: @customer, status: :created
        else
          render json: { errors: @customer.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # PUT /api/v1/customers/:id
      def update
        if @customer.update(customer_params)
          render json: @customer
        else
          render json: { errors: @customer.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/customers/:id
      def destroy
        @customer.destroy
        head :no_content
      end
      
      private
      
      def set_customer
        @customer = Customer.find(params[:id])
      end
      
      def customer_params
        params.require(:customer).permit(:name, :email, :phone, :password, :password_confirmation)
      end
    end
  end
end
