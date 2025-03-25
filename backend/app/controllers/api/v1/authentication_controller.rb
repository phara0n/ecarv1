module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :authenticate_request
      
      # POST /api/v1/login
      def login
        command = Authentication::AuthenticateCustomer.call(params[:email], params[:password])
        
        if command.success?
          render json: { token: command.result, message: 'Login successful' }
        else
          render json: { error: command.errors }, status: :unauthorized
        end
      end
    end
  end
end
