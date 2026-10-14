Rails.application.routes.draw do
  root "murals#index"
  resources :murals, only: :show, param: :slug

  namespace :admin do
    get "login", to: "sessions#new", as: :login
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy", as: :logout
    root "dashboard#index"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
