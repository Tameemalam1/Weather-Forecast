Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :forecasts, only: [:new, :create, :show]
  root 'forecasts#new'  # Optionally set the root route to the new action
end
