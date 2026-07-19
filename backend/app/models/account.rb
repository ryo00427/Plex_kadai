class Account < ApplicationRecord
  has_secure_password
  belongs_to :profileable, polymorphic: true

  enum :role, { intern: 0, company: 1 }

  # role and profileable_type both encode "what kind of account is this", so they
  # can disagree. Eight authorization sites across the controllers branch on role
  # (current_account.company?) and then use profileable_id — an account whose role
  # said company while its profile was an Intern could reach another company's
  # records. Rather than re-checking the type at each of those sites, keep the two
  # columns in agreement here so role implies profileable_type everywhere.
  PROFILE_TYPE_FOR_ROLE = { "intern" => "Intern", "company" => "Company" }.freeze

  # Normalize email before validation so uniqueness and later case-sensitive lookups
  # (e.g. AuthController#login's find_by(email:)) agree on the same canonical value.
  before_validation :normalize_email

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true
  validate :role_matches_profile_type

  private

  def role_matches_profile_type
    return if role.blank? || profileable_type.blank?

    expected = PROFILE_TYPE_FOR_ROLE[role]
    return if profileable_type == expected

    errors.add(:profileable_type, "must be #{expected} when role is #{role}")
  end

  def normalize_email
    self.email = email.strip.downcase if email.present?
  end
end
