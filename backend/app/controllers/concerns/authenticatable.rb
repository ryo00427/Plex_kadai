module Authenticatable
  extend ActiveSupport::Concern

  def current_account
    return @current_account if defined?(@current_account)

    header = request.headers["Authorization"]
    token = header&.split(" ")&.last
    payload = token && JsonWebToken.decode(token)
    @current_account = payload && Account.find_by(id: payload[:account_id])
  end

  def authenticate_request!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_account
  end
end
