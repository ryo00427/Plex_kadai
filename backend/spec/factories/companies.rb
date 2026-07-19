FactoryBot.define do
  factory :company do
    name { "ダミー株式会社" }
    industry { "IT" }
    description { "ソフトウェア開発" }
    website { "https://example.com" }

    # See the note in the interns factory.
    transient { with_account { true } }

    after(:build) do |company, evaluator|
      if evaluator.with_account
        company.build_account(
          email: "company#{rand(1_000_000)}@example.com", password: "password123", role: :company
        )
      end
    end
  end
end
