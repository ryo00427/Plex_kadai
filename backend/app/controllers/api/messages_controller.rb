module Api
  class MessagesController < ApplicationController
    before_action :authenticate_request!
    before_action :set_conversation
    before_action :require_participant!

    def index
      render json: { messages: @conversation.messages.order(:created_at).map { |m| MessageSerializer.new(m) } }
    end

    def create
      message = @conversation.messages.new(body: params[:body], sender: current_account.profileable)
      if message.save
        @conversation.touch
        render json: { message: MessageSerializer.new(message) }, status: :created
      else
        render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_conversation = @conversation = Conversation.find(params[:conversation_id])

    def require_participant!
      render json: { error: "Forbidden" }, status: :forbidden unless @conversation.participant?(current_account)
    end
  end
end
