class Conversation < ApplicationRecord
  belongs_to :company
  belongs_to :intern
  has_many :messages, dependent: :destroy

  validates :company_id, uniqueness: { scope: :intern_id }

  def participant?(account)
    return false unless account

    (account.company? && account.profileable_id == company_id) ||
      (account.intern? && account.profileable_id == intern_id)
  end
end
