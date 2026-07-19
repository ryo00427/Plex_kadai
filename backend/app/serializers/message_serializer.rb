class MessageSerializer
  def initialize(message) = @message = message

  def as_json(*)
    @message.as_json(only: %i[id body sender_type sender_id read_at created_at])
  end
end
