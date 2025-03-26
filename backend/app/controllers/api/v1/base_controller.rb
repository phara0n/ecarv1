module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_request
      
      private
      
      def authenticate_request
        header = request.headers['Authorization']
        if header.present?
          token = header.split(' ').last
          begin
            @decoded = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256')
            @current_user = User.find(@decoded[0]['user_id'])
          rescue JWT::DecodeError => e
            render json: { error: 'Invalid token' }, status: :unauthorized
          rescue ActiveRecord::RecordNotFound => e
            render json: { error: 'User not found' }, status: :unauthorized
          end
        else
          # For development, allow requests without authentication
          if Rails.env.development?
            @current_user = User.first || User.create!(
              email: 'admin@example.com',
              password: 'password123',
              role: 'admin'
            )
          else
            render json: { error: 'Token missing' }, status: :unauthorized
          end
        end
      end
      
      def current_user
        @current_user
      end
    end
  end
end 