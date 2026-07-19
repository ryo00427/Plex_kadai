require "rails_helper"

RSpec.describe Company, type: :model do
  it "name が必須" do
    expect(build(:company, name: nil)).not_to be_valid
  end

  it "account と紐づく" do
    company = create(:company)
    expect(company.account.role).to eq("company")
  end
end
