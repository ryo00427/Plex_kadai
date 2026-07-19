# Shared guard for controllers that act on a single conversation. The id lives
# under a different param key depending on the route: :conversation_id when
# messages are nested under the conversation, :id when the conversation itself
# is the target.
module ConversationParticipation
  extend ActiveSupport::Concern

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id] || params[:id])
  end

  def require_participant!
    return if @conversation.participant?(current_account)

    render json: { error: "Forbidden" }, status: :forbidden
  end
end
