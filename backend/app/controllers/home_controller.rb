class HomeController < ApplicationController
  def index
    render json: { 
      message: "Welcome to the eCar Garage API",
      version: "1.0.0",
      docs: "/docs"
    }
  end
end
