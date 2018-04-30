Rails.application.routes.draw do
  namespace :api, defaults: {format: :json} do
    resources :recruitments, only: [:index, :create, :destroy] do
      resources :participants, only: [:create, :destroy]
    end
  end
end
