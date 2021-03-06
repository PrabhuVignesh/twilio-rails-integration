require 'twilio-ruby'
require 'sanitize'

class TwilioController < ApplicationController
  include Webhookable
 
  after_filter :set_header
 
  skip_before_action :verify_authenticity_token
 
  def voice
  	response = Twilio::TwiML::Response.new do |r|
  	  r.Say 'Hi.. welcome to satori application! it is really nice to have you connected with satori application..Hear some music..', :voice => 'alice'
      r.Play 'http://linode.rabasa.com/cantina.mp3'
  	end
 
  	render_twiml response
  end
  # POST ivr/welcome
  def ivr_welcome
    response = Twilio::TwiML::Response.new do |r|
      r.Gather numDigits: '1', action: menu_path do |g|
        g.Say "Hello... Welcome....Press 1 to welcome message, Press 2 for menu!",voice: 'alice', loop: 4
      end
    end
    render text: response.text
  end

  # GET ivr/selection
  def menu_selection
    user_selection = params[:Digits]

    case user_selection
    when "1"
      @output = "Hello, Welcome to satori application."
      twiml_say(@output, true)
    when "2"
      list_planets
    else
      @output = "Returning to the main menu."
      twiml_say(@output)
    end
  end

  def list_planets
    message = "To play some random music, press 1. To get satori applications, press 2. To get satori community list, press 3. 
To get permission you have, press 4. To record your voice, press 5. To listen last recorded file, Press 6 To
    go back to the main menu, press the star key."

    response = Twilio::TwiML::Response.new do |r|
      r.Gather numDigits: '1', action: planets_path do |g|
        g.Say message, voice: 'alice', loop:3
      end
    end

    render text: response.text
  end

  # POST/GET ivr/planets
  def planet_selection
    user_selection = params[:Digits]

    case user_selection
    when "1"
      say = 'Hi.. welcome to satori application! it is really nice to have you connected with satori application enjoy the music'
      wait_music(say)
        
    when "2"
      twiml_say("Buzz, Compliance dashboard, PMG events, Custom list")
    when "3"
      twiml_say("Satori developers, NGDC, CFS, KM-ISD, Automation")
    when "4"
      twiml_say("Admin, Owners, Viewers")
    when "5"
      agent_voicemail
    when "6"
      play_mp3 = Recording.last
      twiml = Twilio::TwiML::Response.new do |r|
        r.Play play_mp3.url
      end
      render xml: twiml.to_xml      
    else
      @output = "Returning to the main menu."
      twiml_say(@output)
    end
  end

  def record_create

    @record = Recording.new
    @record.url = params[:RecordingUrl] + ".mp3"
    @record.transcription = params[:TranscriptionText]
    @record.phone_number = params[:Caller]
    @record.save
    twiml_play(params[:RecordingUrl])
      render xml: twiml.to_xml
  end

  def sms_flow
    incoming = Sanitize.clean(params[:From]).gsub(/^\+\d/, '')
    sms_input = params[:Body].downcase
    if sms_input == "hi"
        send_response_sms(incoming,"Hello buddy")
    else
      send_default_sms(incoming)
    end
    # @app_number = ENV['TWILIO_NUMBER']
    # @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    # sms_message = @client.account.messages.create(
    #   from: @app_number,
    #   to: "+91 8377003750",
    #   body: "Hi Prabhu vignesh This is from satori twilio integration",
    # )
  end

  private

  def send_default_sms(to)
    @app_number = ENV['TWILIO_NUMBER']
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    sms_message = @client.account.messages.create(
      from: @app_number,
      to: to,
      body: "This is sample SMS from satori twilio !!",
    )
  end

  def send_response_sms(to,response)
    @app_number = ENV['TWILIO_NUMBER']
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    sms_message = @client.account.messages.create(
      from: @app_number,
      to: to,
      body: response,
    )
  end


  def agent_voicemail
    status = params[:DialCallStatus] || "completed"
    recording = params[:RecordingUrl]
     if (status != "completed" || recording.nil? ) 
      twiml = Twilio::TwiML::Response.new do |r|
        r.Say "Please record your response after the beep. Press # to complete", voice: 'alice'
        r.Record maxLength: '20', transcribe: true, transcribeCallback: "/ivr/record_create", :finishOnKey => '#', :maxLength => '90'

        #r.Record maxLength: '20', transcribe: true

        #r.Play params[:RecordingUrl] + ".mp3" if params[:RecordingUrl].present?
        r.Say "Could not get your voice", voice: 'alice'

      end
    else
      twiml = Twilio::TwiML::Response.new do |r|
        r.Hangup
      end
    end
    render xml: twiml.to_xml
  end

  def wait_music(phrase, exit = false)
    response = Twilio::TwiML::Response.new do |r|          
         r.Say phrase, voice: 'alice'
         r.Play 'http://linode.rabasa.com/cantina.mp3'
      if exit 
        r.Say "Thank you for calling satori"
        r.Hangup
      else
        r.Redirect welcome_path
      end
    end
    render_twiml response
  end

  def twiml_say(phrase, exit = false)
    # Respond with some TwiML and say something.
    # Should we hangup or go back to the main menu?
    response = Twilio::TwiML::Response.new do |r|
      r.Say phrase, voice: 'alice'
      if exit 
        r.Say "Thank you for calling satori"
        r.Hangup
      else
        r.Redirect welcome_path
      end
    end

    render text: response.text
  end

  def twiml_play(phrase, exit = false)
    # Respond with some TwiML and say something.
    # Should we hangup or go back to the main menu?
    response = Twilio::TwiML::Response.new do |r|
      r.Play phrase
      if exit 
        r.Say "Thank you for calling satori"
        r.Hangup
      else
        r.Redirect welcome_path
      end
    end

    render text: response.text
  end



  def twiml_dial(phone_number)
    response = Twilio::TwiML::Response.new do |r|
      r.Dial phone_number
    end

    render text: response.text
  end

end
