class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, polymorphic: true

  validates :body, presence: true
end
