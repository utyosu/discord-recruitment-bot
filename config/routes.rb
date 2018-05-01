Rails.application.routes.draw do
  namespace :api, defaults: {format: :json} do
    resources :recruitments, only: [:index, :create, :update, :destroy] do
      resources :participants, only: [:create, :destroy]
    end
    resources :interactions, only: [:create]
    get '/interactions/search', to: 'interactions#search'
    delete '/interactions/destroy_by_keyword', to: 'interactions#destroy_by_keyword'
  end
end
