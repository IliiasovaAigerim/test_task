Rails.application.routes.draw do
  devise_for :users
  namespace :api do
    namespace :v1 do
      resources :posts, only: [:create]
      resources :ratings, only: [:create]
      get 'posts/top/:n', to: 'posts#top', constraints: { n: /\d+/ }
      get 'ips', to: 'ips#multiple_authors'
    end
  end
end
