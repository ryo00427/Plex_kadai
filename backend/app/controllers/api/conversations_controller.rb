module Api
  class ConversationsController < ApplicationController
    include ConversationParticipation

    before_action :authenticate_request!
    before_action :set_conversation, only: :read
    before_action :require_participant!, only: :read

    def index
      scope = Conversation.where(scope_condition).includes(:company, :intern, :messages).order(updated_at: :desc)
      convos, meta = paginate(scope)
      render json: {
        conversations: convos.map { |c| ConversationSerializer.new(c, viewer: current_account.profileable) },
        meta:
      }
    end

    def create
      return render json: { error: "Forbidden" }, status: :forbidden unless current_account.company?

      # Resolve the intern up front so an unknown id becomes a 404 via the
      # rescue_from in ApplicationController. Without this, the required
      # belongs_to :intern fails validation and Rails renders 422 "Intern must
      # exist" — which reads as "your payload was malformed" when the real
      # situation is that the referenced record does not exist.
      intern = Intern.find(params[:intern_id])
      convo = Conversation.find_or_create_by!(
        company_id: current_account.profileable_id, intern_id: intern.id
      )
      render json: {
        conversation: ConversationSerializer.new(convo, viewer: current_account.profileable)
      }, status: :created
    end

    # Marks every message the other party sent as read. Reading is an explicit
    # call rather than a side effect of GET /messages: a GET that mutates would
    # mark messages read on prefetch or retry.
    def read
      @conversation.messages
                   .where.not(sender: current_account.profileable)
                   .where(read_at: nil)
                   .update_all(read_at: Time.current)
      head :no_content
    end

    private

    def scope_condition
      if current_account.company?
        { company_id: current_account.profileable_id }
      else
        { intern_id: current_account.profileable_id }
      end
    end
  end
end
