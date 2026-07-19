FactoryBot.define do
  factory :company do
    name { "ダミー株式会社" }
    industry { "IT" }
    description { "ソフトウェア開発" }
    website { "https://example.com" }
    after(:build) { |c| c.build_account(email: "company#{rand(1_000_000)}@example.com", password: "password123", role: :company) }
  end
end
