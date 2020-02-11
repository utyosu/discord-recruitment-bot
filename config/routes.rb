Rails.application.routes.draw do
  get "analysises", to: "analysises#index"
  get "analysises/records", to: "analysises#records"
  get "analysises/kings", to: "analysises#kings"
  get "analysises/hourlyactive", to: "analysises#hourlyactive"
  get "analysises/monthlyactive", to: "analysises#monthlyactive"
end
