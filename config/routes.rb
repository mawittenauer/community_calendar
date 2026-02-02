Rails.application.routes.draw do
  devise_for :admin_users

  root "public_calendar#index"

  namespace :admin do
    get "dashboard/index"
    root "dashboard#index"
    resources :categories
    resources :tags
    resources :venues
    resources :events
  end

  namespace :api do
    namespace :v1 do
      resources :categories, only: [:index]
      resources :tags, only: [:index]
      resources :events, only: [:index, :show]
    end
  end
end
