class Vehicle < ApplicationRecord
  belongs_to :customer
  has_many :repairs, dependent: :destroy
  
  validates :brand, presence: true
  validates :model, presence: true
  validates :year, presence: true, numericality: { only_integer: true, greater_than: 1900, less_than_or_equal_to: -> { Date.current.year + 1 } }
  validates :license_plate, presence: true, uniqueness: true
  validates :vin, uniqueness: true, allow_blank: true
  validates :current_mileage, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :average_daily_usage, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  def next_service_due_date
    last_repair = repairs.where.not(next_service_estimate: nil).order(completion_date: :desc).first
    last_repair&.next_service_estimate
  end
  
  def days_until_next_service
    return nil if next_service_due_date.nil?
    (next_service_due_date - Date.current).to_i
  end
end
