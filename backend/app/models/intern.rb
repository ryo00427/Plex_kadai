class Intern < ApplicationRecord
  # autosave: true is load-bearing, not decoration. Without it a has_one whose
  # associated record fails validation is skipped silently: Intern#save returns
  # true, the intern row persists with no account, and the caller sees success.
  # AuthController#register then issues a JWT encoding a nil account_id, so the
  # user appears registered but can never authenticate. autosave makes the
  # account's errors propagate onto the intern and the whole save fail.
  has_one :account, as: :profileable, dependent: :destroy, autosave: true
  has_many :conversations, dependent: :destroy

  validates :name, presence: true
end
