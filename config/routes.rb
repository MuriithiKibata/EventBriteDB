Rails.application.routes.draw do
  resources :mpesas
  resources :ticket_statuses
 
  # update route
  resources :events do
    member do
      post 'purchase_ticket'
    end
  end
  resources :tickets
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  post 'stkpush', to: 'mpesa#stkpush'
  post 'stkquery', to: 'mpesa#stkquery'
end
