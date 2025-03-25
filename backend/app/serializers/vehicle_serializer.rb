class VehicleSerializer < ActiveModel::Serializer
  attributes :id, :brand, :model, :year, :license_plate, :vin, :current_mileage, 
             :average_daily_usage, :next_service_due_date, :days_until_next_service
  
  belongs_to :customer
  has_many :repairs
end 