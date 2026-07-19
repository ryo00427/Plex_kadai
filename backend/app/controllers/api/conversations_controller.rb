module Api
  class ConversationsController < ApplicationController
    before_action :authenticate_request!

    def index
      convos = Conversation.where(scope_condition).includes(:company, :intern, :messages).order(updated_at: :desc)
      render json: { conversations: convos.map { |c| ConversationSerializer.new(c) } }
    end

    def create
      return render json: { error: "Forbidden" }, status: :forbidden unless current_account.company?

      convo = Conversation.find_or_create_by!(
        company_id: current_account.profileable_id, intern_id: params[:intern_id]
      )
      render json: { conversation: ConversationSerializer.new(convo) }, status: :created
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
