class Repair < ApplicationRecord
  belongs_to :vehicle
  has_one :invoice, dependent: :destroy
  has_one :customer, through: :vehicle
  
  validates :description, presence: true
  validates :start_date, presence: true
  validates :status, presence: true
  validates :cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :labor_hours, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  enum status: {
    scheduled: 'scheduled',
    in_progress: 'in_progress',
    completed: 'completed',
    cancelled: 'cancelled'
  }
  
  scope :completed, -> { where(status: 'completed') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :scheduled, -> { where(status: 'scheduled') }
  
  def total_days
    return nil if start_date.nil? || completion_date.nil?
    (completion_date - start_date).to_i
  end
end
