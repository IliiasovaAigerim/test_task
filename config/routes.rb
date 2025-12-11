Rails.application.routes.draw do
  devise_for :users
  namespace :api do
    namespace :v1 do
      resources :posts, only: [:create]
      resources :ratings, only: [:create]
    end
  end
  get "up" => "rails/health#show", as: :rails_health_check
  # post 'ratings', to: 'ratings#create'

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
