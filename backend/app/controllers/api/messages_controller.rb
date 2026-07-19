module Api
  class MessagesController < ApplicationController
    include ConversationParticipation

    before_action :authenticate_request!
    before_action :set_conversation
    before_action :require_participant!

    def index
      messages, meta = paginate(@conversation.messages.order(:created_at))
      render json: { messages: messages.map { |m| MessageSerializer.new(m) }, meta: }
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
  end
end
