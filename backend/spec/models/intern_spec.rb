require "rails_helper"

RSpec.describe Intern, type: :model do
  it "name が必須" do
    expect(build(:intern, name: nil)).not_to be_valid
  end

  it "account と紐づく" do
    intern = create(:intern)
    expect(intern.account.role).to eq("intern")
  end
end
