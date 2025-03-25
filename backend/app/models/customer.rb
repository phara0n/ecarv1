class Customer < ApplicationRecord
  has_secure_password
  
  has_many :vehicles, dependent: :destroy
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, 
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
end
