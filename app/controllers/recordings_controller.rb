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
    agent_id = params[:agent_id]

    @record = Recording.new
    @record.url = params[:RecordingUrl] + ".mp3"
    @record.transcription = params[:TranscriptionText]
    @record.phone_number = params[:Caller]
    @record.save



    # @agent.recordings.create(
    #   url: params[:RecordingUrl] + ".mp3",
    #   transcription: params[:TranscriptionText],
    #   phone_number: params[:Caller]
    # )

    render status: :ok, plain: "Ok"
  end

end