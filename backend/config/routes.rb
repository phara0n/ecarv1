Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Health check endpoint
  get 'health_check', to: 'health#check'

  # Root path
  root 'home#index'

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post '/login', to: 'authentication#login'
      
      # Customer routes
      resources :customers, only: [:index, :show, :create, :update, :destroy] do
        collection do
          get 'me', to: 'customers#me'
          get :statistics
        end
      end
      
      # Vehicle routes
      resources :vehicles, only: [:index, :show, :create, :update, :destroy] do
        member do
          patch 'update_mileage'
        end
      end
      
      # Repair routes
      resources :repairs, only: [:index, :show, :create, :update, :destroy] do
        collection do
          get 'upcoming'
        end
      end
      
      # Invoice routes
      resources :invoices, only: [:index, :show, :create, :update, :destroy] do
        member do
          patch 'mark_as_paid'
          patch 'mark_as_partially_paid'
          patch 'mark_as_cancelled'
          get 'generate_pdf'
        end
      end
    end
  end
end
