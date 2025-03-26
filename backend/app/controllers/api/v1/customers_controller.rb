module Api
  module V1
    class CustomersController < BaseController
      before_action :set_customer, only: [:show, :update, :destroy]
      
      # GET /api/v1/customers
      def index
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 10).to_i
        
        # Build query with filters
        @customers = Customer.all
        
        # Apply search if present
        if params[:search].present?
          search_term = "%#{params[:search]}%"
          @customers = @customers.where('name ILIKE ? OR email ILIKE ? OR phone ILIKE ?', 
                                     search_term, search_term, search_term)
        end
        
        # Apply active filter if present
        @customers = @customers.where(is_active: params[:is_active]) if params[:is_active].present?
        
        # Apply sorting
        sort_by = params[:sort_by]&.to_sym || :created_at
        sort_direction = params[:sort_direction]&.to_sym || :desc
        
        if Customer.column_names.include?(sort_by.to_s)
          @customers = @customers.order(sort_by => sort_direction)
        end
        
        # Apply pagination
        total = @customers.count
        @customers = @customers.limit(per_page).offset((page - 1) * per_page)
        
        render json: {
          data: @customers,
          meta: {
            total: total,
            current_page: page,
            per_page: per_page,
            last_page: (total.to_f / per_page).ceil
          }
        }
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
      
      def statistics
        total_customers = Customer.count
        active_customers = Customer.where(is_active: true).count
        inactive_customers = total_customers - active_customers
        new_customers_last_month = Customer.where('created_at >= ?', 1.month.ago).count
        customer_growth_percentage = calculate_growth_percentage
        
        # Calculate averages
        avg_vehicles = Customer.average(:vehicle_count) || 0
        avg_repairs = Customer.average(:repair_count) || 0
        avg_spent = Customer.average(:total_spent) || 0
        
        # Get top cities
        top_cities = Customer.group(:city)
                           .where.not(city: [nil, ''])
                           .count
                           .sort_by { |_, count| -count }
                           .first(5)
                           .map { |city, count| { name: city, count: count } }
        
        # Get monthly new customers for the last 12 months
        monthly_new_customers = 12.times.map do |i|
          month = (Time.current - i.months).beginning_of_month
          {
            month: month.strftime('%b'),
            count: Customer.where(created_at: month.beginning_of_month..month.end_of_month).count
          }
        end.reverse
        
        render json: {
          total_customers: total_customers,
          active_customers: active_customers,
          inactive_customers: inactive_customers,
          new_customers_last_month: new_customers_last_month,
          customer_growth_percentage: customer_growth_percentage,
          average_vehicles_per_customer: avg_vehicles.round(2),
          average_repairs_per_customer: avg_repairs.round(2),
          average_total_spent: avg_spent.round(2),
          top_cities: top_cities,
          monthly_new_customers: monthly_new_customers
        }
      end
      
      private
      
      def set_customer
        @customer = Customer.find(params[:id])
      end
      
      def customer_params
        params.require(:customer).permit(:name, :email, :phone, :password, :password_confirmation)
      end
      
      def calculate_growth_percentage
        current_month_customers = Customer.where('created_at >= ?', Time.current.beginning_of_month).count
        last_month_customers = Customer.where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month).count
        
        if last_month_customers.zero?
          return current_month_customers.positive? ? 100.0 : 0.0
        end
        
        ((current_month_customers - last_month_customers).to_f / last_month_customers * 100).round(2)
      end
    end
  end
end
