# Login throttling. 5 attempts per minute per IP is generous enough that a user
# mistyping a password is never blocked, while making credential stuffing
# impractical.
Rack::Attack.throttle("logins/ip", limit: 5, period: 60.seconds) do |req|
  req.ip if req.post? && req.path == "/api/auth/login"
end

# An explicit store, because the default Rails cache is a null store in some
# environments, which would silently disable every throttle.
#
# MemoryStore is process-local. That is correct for the current deployment (one
# Puma process in one container: see config/puma.rb, which sets no workers, and
# docker-compose.yml, which runs a single backend service). It does NOT survive
# horizontal scaling: with N Puma workers or N containers each process keeps its
# own counter, so the effective limit becomes N x 5 per minute and a deploy
# resets every counter. Before running more than one process, switch this to a
# shared store (e.g. RedisCacheStore) or the throttle stops meaning what it says.
Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

Rack::Attack.throttled_responder = lambda do |_request|
  [ 429, { "Content-Type" => "application/json" }, [ { error: "Too Many Requests" }.to_json ] ]
end
