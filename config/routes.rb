Rails.application.routes.draw do
  root to: "home#index"
  resources :rentals, only: [:index, :show]
  resources :cart_rentals, only: [:new, :create]
  resources :users, only: [:new, :create, :show, :edit, :update, :destroy]
  resources :orders, only: [:index, :show]

  get "/admin/dashboard", to: "admin#dashboard"

  namespace :admin do
    resources :rentals
    resources :orders
  end

  get "/cart", to: "cart_rentals#show"
  put "/cart", to: "cart_rentals#update"
  delete "/cart", to: "cart_rentals#delete"

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  get "/logout", to: "sessions#delete"
  get "/dashboard", to: "users#dashboard"
  post "/checkout", to: "orders#create"

  get "/:activity_name", to: "activity#show" # keep at bottom of routes
end
