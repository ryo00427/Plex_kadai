class InternSerializer
  def initialize(intern) = @intern = intern

  def as_json(*)
    @intern.as_json(only: %i[id name university major graduation_year skills bio])
  end
end
