class Company < ApplicationRecord
  has_one :account, as: :profileable, dependent: :destroy
  has_many :job_postings, dependent: :destroy
  has_many :conversations, dependent: :destroy

  validates :name, presence: true
end
