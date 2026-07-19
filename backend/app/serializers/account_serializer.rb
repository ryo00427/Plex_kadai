class AccountSerializer
  def initialize(account)
    @account = account
  end

  def as_json(*)
    profile = @account.profileable
    {
      id: @account.id,
      email: @account.email,
      role: @account.role,
      profile: profile && profile.as_json(except: %i[created_at updated_at])
    }
  end
end
