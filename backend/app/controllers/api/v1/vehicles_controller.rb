module Api
  module V1
    class VehiclesController < BaseController
      before_action :set_vehicle, only: [:show, :update, :destroy]
      
      # GET /api/v1/vehicles
      def index
        @vehicles = current_user.vehicles
        render json: @vehicles
      end
      
      # GET /api/v1/vehicles/:id
      def show
        render json: @vehicle
      end
      
      # POST /api/v1/vehicles
      def create
        @vehicle = current_user.vehicles.build(vehicle_params)
        
        if @vehicle.save
          render json: @vehicle, status: :created
        else
          render json: { errors: @vehicle.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # PUT /api/v1/vehicles/:id
      def update
        if @vehicle.update(vehicle_params)
          render json: @vehicle
        else
          render json: { errors: @vehicle.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/vehicles/:id
      def destroy
        @vehicle.destroy
        head :no_content
      end
      
      # PATCH /api/v1/vehicles/:id/update_mileage
      def update_mileage
        @vehicle = current_user.vehicles.find(params[:id])
        
        if @vehicle.update(current_mileage: params[:current_mileage])
          render json: @vehicle
        else
          render json: { errors: @vehicle.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      private
      
      def set_vehicle
        @vehicle = current_user.vehicles.find(params[:id])
      end
      
      def vehicle_params
        params.require(:vehicle).permit(:brand, :model, :year, :license_plate, :vin, :current_mileage)
      end
    end
  end
end
