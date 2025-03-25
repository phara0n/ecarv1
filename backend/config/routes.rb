Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post '/login', to: 'authentication#login'
      
      # Customer routes
      resources :customers
      
      # Vehicle routes with nested resources
      resources :vehicles do
        # Update mileage endpoint
        patch :update_mileage, on: :member
        
        # Repair routes with nested invoice resource
        resources :repairs do
          resources :invoices
        end
      end
    end
  end
  
  # Root route
  root 'api/v1/customers#index'
end
