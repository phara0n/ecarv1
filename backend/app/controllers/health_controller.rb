class HealthController < ApplicationController
  def check
    render json: { status: 'ok', message: 'System is healthy' }
  end
end
