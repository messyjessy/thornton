Rails.application.routes.draw do
  
  devise_for :users
  root to: 'pages#index'
  get 'pages/vacation'
  get 'pages/residential'
  get 'pages/commercial'

end
