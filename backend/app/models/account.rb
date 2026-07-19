class Account < ApplicationRecord
  has_secure_password
  belongs_to :profileable, polymorphic: true, optional: true

  enum :role, { intern: 0, company: 1 }

  # Normalize email before validation so uniqueness and later case-sensitive lookups
  # (e.g. AuthController#login's find_by(email:)) agree on the same canonical value.
  before_validation :normalize_email

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true

  private

  def normalize_email
    self.email = email.strip.downcase if email.present?
  end
end
