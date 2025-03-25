module Api
  module V1
    class BaseController < ApplicationController
      # Skip authentication for development
      skip_before_action :authenticate_request
      
      private
      
      # Current authenticated user - mock for testing
      def current_user
        @current_user ||= Customer.first
      end
    end
  end
end 