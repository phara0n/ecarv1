module Authentication
  class AuthenticateCustomer
    prepend SimpleCommand
    
    def initialize(email, password)
      @email = email
      @password = password
    end
    
    def call
      JsonWebToken.encode(customer_id: customer.id) if customer
    end
    
    private
    
    attr_accessor :email, :password
    
    def customer
      customer = Customer.find_by(email: email)
      return customer if customer && customer.authenticate(password)
      
      errors.add :user_authentication, 'Invalid credentials'
      nil
    end
  end
end 