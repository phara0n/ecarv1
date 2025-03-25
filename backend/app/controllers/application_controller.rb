class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  
  # Add authentication for all requests
  before_action :authenticate_request
  
  # Handle record not found errors
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  
  # Handle validation errors
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  
  # Define authenticate_request as a no-op for development
  def authenticate_request
    # In development, this is a no-op to allow testing
    # In production, this would authenticate the JWT token
    true
  end
  
  private
  
  def not_found
    render json: { error: 'Resource not found' }, status: :not_found
  end
  
  def unprocessable_entity(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end
end
