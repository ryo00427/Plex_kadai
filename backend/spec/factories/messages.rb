FactoryBot.define do
  factory :message do
    association :conversation
    body { "はじめまして、スカウトです" }
    sender { conversation.company }
  end
end
