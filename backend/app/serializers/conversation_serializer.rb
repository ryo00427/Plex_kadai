class ConversationSerializer
  def initialize(conversation) = @conversation = conversation

  def as_json(*)
    # Use the already-loaded messages association (preloaded via .includes(:messages)
    # in ConversationsController#index) instead of chaining .order/.first, which would
    # re-query the DB per conversation and reintroduce an N+1.
    last = @conversation.messages.to_a.max_by(&:created_at)
    {
      id: @conversation.id,
      company: { id: @conversation.company_id, name: @conversation.company.name },
      intern: { id: @conversation.intern_id, name: @conversation.intern.name },
      last_message: last && MessageSerializer.new(last)
    }
  end
end
