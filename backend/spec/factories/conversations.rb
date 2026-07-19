FactoryBot.define do
  factory :conversation do
    association :company
    association :intern
  end
end
