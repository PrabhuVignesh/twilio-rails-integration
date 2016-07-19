require 'twilio-ruby'

class RecordingsController < ApplicationController

  # GET /recordings/:agent
  def show
    @agent_number = params[:agent]
    @agent = Agent.find_by(phone_number: @agent_number)
    @recordings = @agent.recordings 
  end

  # POST /recordings/create
  def create
    agent_id = params[:agent_id]


    twiml = Twilio::TwiML::Response.new do |r|
        r.Play params[:RecordingUrl] + ".mp3"
        r.Record maxLength: '20', transcribe: true, transcribeCallback: "/recordings/create?agent_id=#{params[:agent_id]}"
        r.Say "I did not receive a recording.", voice: 'alice'
      end
      
    

    @agent.recordings.create(
      url: params[:RecordingUrl] + ".mp3",
      transcription: params[:TranscriptionText],
      phone_number: params[:Caller]
    )

    render status: :ok, plain: "Ok"
  end

end