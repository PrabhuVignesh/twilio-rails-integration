require 'twilio-ruby'
require 'sanitize'
class TwilioController < ApplicationController
  include Webhookable
 
  after_filter :set_header
 
  skip_before_action :verify_authenticity_token
 
  def voice
  	response = Twilio::TwiML::Response.new do |r|
  	  r.Say 'Hi.. welcome to satori application! it is really nice to have you connected with satori application', :voice => 'alice'
      r.Play 'http://linode.rabasa.com/cantina.mp3'
  	end
 
  	render_twiml response
  end
  # POST ivr/welcome
  def ivr_welcome
    response = Twilio::TwiML::Response.new do |r|
      r.Gather numDigits: '1', action: menu_path do |g|
        g.Say "Press 1 to welcome message, Press 2 for menu!",voice: 'alice', loop: 4
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
To get permission you have, press 4. To
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
    else
      @output = "Returning to the main menu."
      twiml_say(@output)
    end
  end

 # POST ivr/screen_call
  def screen_call
    @customer_phone_number = params[:From]

    twiml = Twilio::TwiML::Response.new do |r|
      # will return status 'completed' if digits are entered
      r.Gather numDigits: '1', action: '/ivr/agent_screen_response' do |g|
        g.Say "You have an incoming call from an Alien with phone number
        #{@customer_phone_number}."
        g.Say "Press any key to accept."
      end

      # will return status no-answer since this is a Number callback
      r.Say "Sorry, I didn't get your response."
      r.Hangup
    end
    render xml: twiml.to_xml
  end

  # POST ivr/agent_screen_response
  def agent_screen_response
    agent_selected = params[:Digits]

    if agent_selected
      twiml = Twilio::TwiML::Response.new do |r|
        r.Say "Connecting you to the E.T. in distress. All calls are recorded."
      end
    end

    render xml: twiml.to_xml
  end

  # POST ivr/agent_voicemail
  def agent_voicemail
    status = params[:DialCallStatus] || "completed"
    recording = params[:RecordingUrl]

    # If the call to the agent was not successful, and there is no recording,
    # then record a voicemail
    if (status != "completed" || recording.nil? )
      twiml = Twilio::TwiML::Response.new do |r|
        r.Say "It appears that planet is unavailable. Please leave a message after the beep.", voice: 'alice', language: 'en-GB'
        r.Record maxLength: '20', transcribe: true, transcribeCallback: "/recordings/create?agent_id=#{params[:agent_id]}"
        r.Say "I did not receive a recording.", voice: 'alice', language: 'en-GB'
      end
    # otherwise end the call
    else
      twiml = Twilio::TwiML::Response.new do |r|
        r.Hangup
      end
    end
    render xml: twiml.to_xml
  end



  private

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

  def twiml_dial(phone_number)
    response = Twilio::TwiML::Response.new do |r|
      r.Dial phone_number
    end

    render text: response.text
  end

end
