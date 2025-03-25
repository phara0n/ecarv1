class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :phone
  
  has_many :vehicles
end 