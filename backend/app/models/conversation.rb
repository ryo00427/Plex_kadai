class Conversation < ApplicationRecord
  belongs_to :company
  belongs_to :intern
  has_many :messages, dependent: :destroy

  validates :company_id, uniqueness: { scope: :intern_id }

  # Compares profileable_type as well as the id. role and profileable_type are
  # not constrained to agree at the database level, so an id-only comparison
  # would let a mismatched account reach another party's conversation.
  def participant?(account)
    return false unless account

    (account.profileable_type == "Company" && account.profileable_id == company_id) ||
      (account.profileable_type == "Intern" && account.profileable_id == intern_id)
  end
end
