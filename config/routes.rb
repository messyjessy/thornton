Rails.application.routes.draw do
  
  devise_for :users, :controllers => { registrations: 'registrations' }
  root to: 'pages#index'
  get 'pages/vacation'
  get 'pages/residential'
  get 'pages/commercial'
  
  get 'pages/profile'
 
  get 'pages/add_commercial'
  get 'pages/add_residential'
  get 'pages/add_vacation'
  
  get 'pages/edit_commercial'
  get 'pages/edit_residential'
  get 'pages/edit_vacation'
end