class JobPostingSerializer
  def initialize(posting) = @posting = posting

  def as_json(*)
    @posting.as_json(only: %i[id title description requirements location employment_type status])
      .merge("company" => { "id" => @posting.company_id, "name" => @posting.company.name })
  end
end
