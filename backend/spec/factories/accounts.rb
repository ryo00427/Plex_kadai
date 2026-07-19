FactoryBot.define do
  factory :account do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { :intern }
  end
end
