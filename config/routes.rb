Rails.application.routes.draw do
  get 'analysises', to: "analysises#index"
  namespace :api, defaults: {format: :json} do
    resources :recruitments, only: [:index, :create, :update, :destroy] do
      resources :participants, only: [:create, :destroy]
    end
    resources :interactions, only: [:index, :create]
    resources :user_statuses, only: [:index, :create]
    get '/interactions/search', to: 'interactions#search'
    delete '/interactions/destroy_by_keyword', to: 'interactions#destroy_by_keyword'
  end
end
