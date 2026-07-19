class ApplicationController < ActionController::API
  include Authenticatable
  include Paginatable

  # Ensure ActiveRecord::RecordNotFound (raised by e.g. Intern.find, JobPosting.find,
  # Conversation.find) always renders a JSON body instead of Rails' default HTML/plain
  # response, so API clients can rely on a consistent JSON contract for 404s.
  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Not Found" }, status: :not_found
  end
end
