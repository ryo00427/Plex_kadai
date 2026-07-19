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

  it "role と profileable_type がずれたアカウントは参加者と判定しない" do
    convo = create(:conversation)
    # role says "company" and the id matches the conversation's company_id, but
    # the profile is an Intern. Comparing ids alone would wrongly grant access,
    # so participant? must also check profileable_type.
    impostor = Account.new(role: :company, profileable_type: "Intern", profileable_id: convo.company_id)

    expect(convo.participant?(impostor)).to be false
  end
end
