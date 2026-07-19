module Api
  class AuthController < ApplicationController
    before_action :authenticate_request!, only: :me

    PROFILE_CLASS = { "intern" => Intern, "company" => Company }.freeze

    def register
      klass = PROFILE_CLASS[params[:role]]
      return render json: { error: "invalid role" }, status: :unprocessable_entity unless klass

      profile = klass.new(profile_params)
      profile.build_account(email: params[:email], password: params[:password], role: params[:role])

      if profile.save
        token = JsonWebToken.encode(account_id: profile.account.id)
        render json: { token:, account: AccountSerializer.new(profile.account) }, status: :created
      else
        # has_one autosave already copies the account's errors onto the profile,
        # so concatenating account.errors here would repeat every message.
        render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def login
      account = Account.find_by(email: params[:email]&.strip&.downcase)
      if account&.authenticate(params[:password])
        render json: { token: JsonWebToken.encode(account_id: account.id), account: AccountSerializer.new(account) }
      else
        render json: { error: "Invalid credentials" }, status: :unauthorized
      end
    end

    def me
      render json: { account: AccountSerializer.new(current_account) }
    end

    private

    def profile_params
      permitted = params[:role] == "company" ?
        %i[name industry description website] :
        %i[name university major graduation_year skills bio]
      params.require(:profile).permit(*permitted)
    end
  end
end
