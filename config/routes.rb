MusicHub::Application.routes.draw do

  post 'twilio/voice' => 'twilio#voice'  

  root 'twilio#index'
  match 'ivr/welcome' => 'twilio#ivr_welcome', via: [:get, :post], as: 'welcome'

  match 'ivr/selection' => 'twilio#menu_selection', via: [:get, :post], as: 'menu'

  match 'ivr/planets' => 'twilio#planet_selection', via: [:get, :post], as: 'planets'

  get 'recordings/:agent' => 'recordings#show', as: 'recordings'
  post 'recordings/create' => 'recordings#create', as: 'new_recording'

  match 'ivr/screen_call' => 'twilio#screen_call', via: [:get, :post]

  match 'ivr/agent_screen' => 'twilio#agent_screen', via: [:get, :post]

  match 'ivr/agent_voicemail' => 'twilio#agent_voicemail', via: [:get, :post]

end

