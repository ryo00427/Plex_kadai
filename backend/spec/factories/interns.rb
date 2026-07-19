FactoryBot.define do
  factory :intern do
    name { "山田太郎" }
    university { "東京大学" }
    major { "情報工学" }
    graduation_year { 2027 }
    skills { "Ruby, TypeScript" }
    bio { "Web 開発が好きです" }
    after(:build) { |i| i.build_account(email: "intern#{rand(1_000_000)}@example.com", password: "password123", role: :intern) }
  end
end
