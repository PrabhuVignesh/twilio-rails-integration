MusicHub::Application.routes.draw do

  post 'twilio/voice' => 'twilio#voice'  

  root 'twilio#index'
  match 'ivr/welcome' => 'twilio#ivr_welcome', via: [:get, :post], as: 'welcome'

  match 'ivr/selection' => 'twilio#menu_selection', via: [:get, :post], as: 'menu'

  match 'ivr/planets' => 'twilio#planet_selection', via: [:get, :post], as: 'planets'
  match 'ivr/record_create' => 'twilio#record_create', via: [:get, :post], as: 'create'

  get 'recordings/:agent' => 'recordings#show', as: 'recordings'
  post 'recordings/create' => 'recordings#create', as: 'new_recording'

  match 'ivr/agent_voicemail' => 'twilio#agent_voicemail', via: [:get, :post]
  match 'sms/sms_flow' => 'twilio#sms_flow', via: [:get, :post], as:'sms_flow'

end

