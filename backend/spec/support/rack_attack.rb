# Throttle counters live in a process-wide store that persists for the whole
# rspec run, so without a reset one example's login attempts leak into the next
# and cause order-dependent failures (spec_helper sets config.order = :random).
#
# This resets before EVERY example rather than only tagged ones: the store is
# global, so a future spec that posts to the login endpoint without knowing
# about the throttle would otherwise push the shared counter over the limit and
# fail with a confusing 429 far from where the throttle is defined.
RSpec.configure do |config|
  config.before(:each) do
    Rack::Attack.cache.store.clear
  end
end
