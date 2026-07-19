require "rails_helper"

RSpec.describe JobPosting, type: :model do
  it "title が必須" do
    expect(build(:job_posting, title: nil)).not_to be_valid
  end

  it "company に属する" do
    expect(create(:job_posting).company).to be_a(Company)
  end
end
