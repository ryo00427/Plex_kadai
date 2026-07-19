FactoryBot.define do
  factory :job_posting do
    association :company
    title { "サマーインターン募集" }
    description { "Web 開発の実務" }
    requirements { "Ruby または TypeScript" }
    location { "東京" }
    employment_type { "インターン" }
    status { :published }
  end
end
