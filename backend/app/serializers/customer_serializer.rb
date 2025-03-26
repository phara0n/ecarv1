class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :phone, :address, :city, :postal_code,
             :vehicle_count, :repair_count, :total_spent, :is_active,
             :notes, :profile_image_url, :created_at, :updated_at
  
  has_many :vehicles

  def vehicle_count
    object.vehicles.count
  end

  def repair_count
    object.repairs.count
  end

  def total_spent
    object.repairs.sum(:cost)
  end
end 