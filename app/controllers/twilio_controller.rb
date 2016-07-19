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
To get permission you have, press 4. To record your voice, press 5. To
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
    else
      @output = "Returning to the main menu."
      twiml_say(@output)
    end
  end


  # # POST ivr/agent_voicemail
  # def agent_voicemail
  #     recording = params[:RecordingUrl]
  #     twiml = Twilio::TwiML::Response.new do |r|
  #       r.Say "Please say something to record", voice: 'alice'
  #       r.Record maxLength: '20', transcribe: true, transcribeCallback: "/recordings/create?agent_id=#{params[:agent_id]}"
  #       r.Say "I did not receive a recording.", voice: 'alice'
  #     end
  #   render xml: twiml.to_xml
  # end


  private

    def agent_voicemail
      recording = params[:RecordingUrl]
      twiml = Twilio::TwiML::Response.new do |r|
        r.Say "Please say something to record", voice: 'alice'
        #r.Record maxLength: '20', transcribe: true, transcribeCallback: "/recordings/create?agent_id=#{params[:agent_id]}"

        r.Record maxLength: '20', transcribe: true
        raise params.inspect
        r.Play params[:RecordingUrl] + ".mp3" if params[:RecordingUrl].present?
        r.Say "Test voice prabhu.", voice: 'alice'

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

  def twiml_dial(phone_number)
    response = Twilio::TwiML::Response.new do |r|
      r.Dial phone_number
    end

    render text: response.text
  end

end
