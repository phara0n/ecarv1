class RepairSerializer < ActiveModel::Serializer
  attributes :id, :description, :start_date, :completion_date, :cost, :status, 
             :mechanic, :parts_used, :labor_hours, :next_service_estimate, :total_days
  
  belongs_to :vehicle
  has_one :invoice
end 