class Invoice < ApplicationRecord
  belongs_to :repair
  has_one :vehicle, through: :repair
  has_one :customer, through: :vehicle
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_status, presence: true
  validates :vat_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  enum payment_status: {
    pending: 'pending',
    paid: 'paid',
    partially_paid: 'partially_paid',
    cancelled: 'cancelled'
  }
  
  scope :pending, -> { where(payment_status: 'pending') }
  scope :paid, -> { where(payment_status: 'paid') }
  
  def total_with_vat
    return amount if vat_amount.nil?
    amount + vat_amount
  end
  
  # Attach PDF document using Active Storage
  has_one_attached :pdf
end
