FactoryBot.define do
  factory :intern do
    name { "山田太郎" }
    university { "東京大学" }
    major { "情報工学" }
    graduation_year { 2027 }
    skills { "Ruby, TypeScript" }
    bio { "Web 開発が好きです" }

    # The accounts factory needs a profile that does not already own an account,
    # otherwise building one would leave two accounts pointing at the same profile.
    transient { with_account { true } }

    after(:build) do |intern, evaluator|
      if evaluator.with_account
        intern.build_account(
          email: "intern#{rand(1_000_000)}@example.com", password: "password123", role: :intern
        )
      end
    end
  end
end
