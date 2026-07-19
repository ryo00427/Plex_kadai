FactoryBot.define do
  factory :account do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { :intern }
    profileable { association(:intern, with_account: false) }

    # role and profileable are separate attributes, so overriding role alone
    # yields an account whose role disagrees with its profile type — the exact
    # inconsistency Conversation#participant? guards against. Use this trait
    # instead of `role: :company` so both move together.
    trait :company do
      role { :company }
      profileable { association(:company, with_account: false) }
    end
  end
end
