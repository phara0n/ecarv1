ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def generate_jwt_token(user)
      JWT.encode(
        { 
          sub: user.id,
          iat: Time.current.to_i,
          exp: 24.hours.from_now.to_i
        },
        Rails.application.credentials.secret_key_base || 'test_secret_key'
      )
    end
  end
end
