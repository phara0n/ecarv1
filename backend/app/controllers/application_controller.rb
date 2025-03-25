class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  
  # Handle record not found errors
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  
  # Handle validation errors
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  
  private
  
  def not_found
    render json: { error: 'Resource not found' }, status: :not_found
  end
  
  def unprocessable_entity(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end
end
