MusicHub::Application.routes.draw do
#  get "musicbox/new"
#  post "musicbox/create"
#  post "musicbox/update"
#  get "musicbox/edit"
#  post "musicbox/destroy"
#  post "musicbox/create_music_track"
#  get "musicbox/index"
 # get "musicbox/show"
 # get "musicbox/box_container"
 # get "musicbox/play_a_track"

  post 'twilio/voice' => 'twilio#voice'  

root 'twilio#index'
  match 'ivr/welcome' => 'twilio#ivr_welcome', via: [:get, :post], as: 'welcome'

  # callback for user entry
  match 'ivr/selection' => 'twilio#menu_selection', via: [:get, :post], as: 'menu'

  # callback for planet entry
  match 'ivr/planets' => 'twilio#planet_selection', via: [:get, :post], as: 'planets'




  #get 'auth/:provider/callback', to: 'sessions#create'
  #get 'auth/failure', to: redirect('/')
 # resources :users do
  #  member do
   #   get :following, :followers
    #end
  #end

#  resources :likes, only: [:create, :destroy]
#  resources :sessions,      only: [:new, :create, :destroy]
#  resources :microposts,    only: [:create, :destroy]
#  resources :relationships, only: [:create, :destroy]
#  root to: 'static_pages#home'
#  match '/signup',  to: 'users#new',            via: 'get'
#  match '/signin',  to: 'sessions#new',         via: 'get'
#  match '/signout', to: 'sessions#destroy',     via: 'delete'
#  match '/musicboxes',    to: 'static_pages#musicboxes',    via: 'get'
#  match '/about',   to: 'static_pages#about',   via: 'get'
#  match '/contact', to: 'static_pages#contact', via: 'get'
#  match '/sound_cloud_log_in', to:  'users#sound_cloud_log_in', via: 'get'
#  match '/sound_cloud_redirect', to:  'users#sound_cloud_redirect', via: 'get'
end

