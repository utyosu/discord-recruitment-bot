Rails.application.routes.draw do
  get 'analysises', to: "analysises#index"
  namespace :api, defaults: {format: :json} do
    resources :recruitments, only: [:index, :create, :update, :destroy] do
      resources :participants, only: [:create, :destroy]
    end
    resources :interactions, only: [:index, :create]
    get '/interactions/search', to: 'interactions#search'
    delete '/interactions/destroy_by_keyword', to: 'interactions#destroy_by_keyword'
    resources :user_statuses, only: [:index, :create]
    get '/user_statuses/last_updated', to: 'user_statuses#last_updated'
    resources :users, only: [:update]
    get '/users/get_from_discord_id/:id', to: 'users#get_from_discord_id'
  end
end
