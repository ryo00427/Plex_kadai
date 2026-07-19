class JsonWebToken
  # No hardcoded fallback secret: a public literal committed to the repo would let
  # anyone forge a token for any account_id whenever JWT_SECRET is unset (e.g. a
  # misconfigured deploy). Rails' own secret_key_base is generated per-application,
  # kept out of the repo, and always present, so it is a safe fallback that still
  # requires zero manual configuration in fresh environments.
  SECRET = ENV.fetch("JWT_SECRET") { Rails.application.secret_key_base }
  ALGORITHM = "HS256"

  def self.encode(payload, exp = 7.days.from_now)
    JWT.encode(payload.merge(exp: exp.to_i), SECRET, ALGORITHM)
  end

  def self.decode(token)
    body = JWT.decode(token, SECRET, true, algorithms: [ ALGORITHM ]).first
    ActiveSupport::HashWithIndifferentAccess.new(body)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
