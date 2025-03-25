module Api
  module V1
    class RepairsController < BaseController
      before_action :set_vehicle
      before_action :set_repair, only: [:show, :update, :destroy]
      
      # GET /api/v1/vehicles/:vehicle_id/repairs
      def index
        @repairs = @vehicle.repairs
        render json: @repairs
      end
      
      # GET /api/v1/vehicles/:vehicle_id/repairs/:id
      def show
        render json: @repair
      end
      
      # POST /api/v1/vehicles/:vehicle_id/repairs
      def create
        @repair = @vehicle.repairs.build(repair_params)
        
        if @repair.save
          render json: @repair, status: :created
        else
          render json: { errors: @repair.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # PUT /api/v1/vehicles/:vehicle_id/repairs/:id
      def update
        if @repair.update(repair_params)
          render json: @repair
        else
          render json: { errors: @repair.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/vehicles/:vehicle_id/repairs/:id
      def destroy
        @repair.destroy
        head :no_content
      end
      
      private
      
      def set_vehicle
        @vehicle = current_user.vehicles.find(params[:vehicle_id])
      end
      
      def set_repair
        @repair = @vehicle.repairs.find(params[:id])
      end
      
      def repair_params
        params.require(:repair).permit(:description, :start_date, :completion_date, 
                                      :cost, :status, :mechanic, :parts_used, 
                                      :labor_hours, :next_service_estimate)
      end
    end
  end
end
