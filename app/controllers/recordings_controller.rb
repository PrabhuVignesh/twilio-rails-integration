require 'twilio-ruby'

class RecordingsController < ApplicationController
skip_before_action :verify_authenticity_token
  # GET /recordings/:agent
  def show
    @agent_number = params[:agent]
    @agent = Agent.find_by(phone_number: @agent_number)
    @recordings = @agent.recordings 
  end

  # POST /recordings/create
  def create

    @record = Recording.new
    @record.url = params[:RecordingUrl] + ".mp3"
    @record.transcription = params[:TranscriptionText]
    @record.phone_number = params[:Caller]
    @record.save

      twiml = Twilio::TwiML::Response.new do |r|

        r.Play params[:RecordingUrl]

      end
      render xml: twiml.to_xml

  end

end