Rails.application.routes.draw do
  
  root to: 'pages#index'
  get 'pages/vacation'
  get 'pages/residential'
  get 'pages/commercial'

end
