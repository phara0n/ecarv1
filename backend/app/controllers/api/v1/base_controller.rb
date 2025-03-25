module Api
  module V1
    class BaseController < ApplicationController
      # Skip CSRF protection for API endpoints
      skip_before_action :verify_authenticity_token, if: -> { request.format.json? }
      
      before_action :authenticate_request
      
      private
      
      # Authenticate JWT token
      def authenticate_request
        @current_user = AuthorizeApiRequest.call(request.headers).result
        render json: { error: 'Not Authorized' }, status: 401 unless @current_user
      end
      
      # Current authenticated user
      def current_user
        @current_user
      end
    end
  end
end 