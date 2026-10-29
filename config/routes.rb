Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#show"
  get "dashboard", to: "dashboard#show"

  namespace :api do
    resources :flight_updates, only: :create
  end
end
