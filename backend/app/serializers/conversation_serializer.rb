class ConversationSerializer
  def initialize(conversation, viewer: nil)
    @conversation = conversation
    @viewer = viewer
  end

  def as_json(*)
    # Use the already-loaded messages association (preloaded via .includes(:messages)
    # in ConversationsController#index) instead of chaining .order/.first/.where,
    # which would re-query the DB per conversation and reintroduce an N+1.
    messages = @conversation.messages.to_a
    {
      id: @conversation.id,
      company: { id: @conversation.company_id, name: @conversation.company.name },
      intern: { id: @conversation.intern_id, name: @conversation.intern.name },
      unread_count: unread_count(messages),
      last_message: messages.max_by(&:created_at)&.then { |m| MessageSerializer.new(m) }
    }
  end

  private

  # Messages the viewer has not read yet. Messages the viewer sent are never
  # counted: read_at tracks the recipient's state, not the sender's.
  def unread_count(messages)
    return 0 unless @viewer

    messages.count do |m|
      m.read_at.nil? && !(m.sender_type == @viewer.class.name && m.sender_id == @viewer.id)
    end
  end
end
