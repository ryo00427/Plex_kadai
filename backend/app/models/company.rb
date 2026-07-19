class Company < ApplicationRecord
  # See the note in Intern: without autosave a failing account is skipped
  # silently and registration reports success while leaving no account behind.
  has_one :account, as: :profileable, dependent: :destroy, autosave: true
  has_many :job_postings, dependent: :destroy
  has_many :conversations, dependent: :destroy

  validates :name, presence: true
end
