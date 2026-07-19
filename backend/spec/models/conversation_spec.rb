require "rails_helper"

RSpec.describe Conversation, type: :model do
  it "同じ company と intern の組は一意" do
    company = create(:company)
    intern = create(:intern)
    create(:conversation, company:, intern:)
    dup = build(:conversation, company:, intern:)
    expect(dup).not_to be_valid
  end

  it "参加者の account を判定できる" do
    convo = create(:conversation)
    expect(convo.participant?(convo.company.account)).to be true
    expect(convo.participant?(create(:intern).account)).to be false
  end
end
