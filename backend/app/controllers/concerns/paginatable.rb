# Offset-based pagination shared by every index action.
#
# Offset rather than cursor: the candidate and job listings show "N of M", which
# needs a total_count that a cursor scheme cannot provide cheaply.
module Paginatable
  extend ActiveSupport::Concern

  DEFAULT_PER = 20
  # Caps how much a client can request in one call, so no caller can ask for an
  # unbounded result set.
  MAX_PER = 100

  private

  # Returns [paginated_scope, meta]. Callers render both so the response shape
  # stays consistent across controllers.
  def paginate(scope)
    page = pagination_page
    per = pagination_per
    total_count = scope.count

    [
      scope.limit(per).offset((page - 1) * per),
      { page:, per:, total_count:, total_pages: (total_count.to_f / per).ceil }
    ]
  end

  def pagination_page
    page = params[:page].to_i
    page.positive? ? page : 1
  end

  def pagination_per
    per = params[:per].to_i
    return DEFAULT_PER unless per.positive?

    [ per, MAX_PER ].min
  end
end
