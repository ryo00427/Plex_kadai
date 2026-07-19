require "rails_helper"

RSpec.describe Message, type: :model do
  it "body が必須" do
    expect(build(:message, body: nil)).not_to be_valid
  end

  it "sender を持つ" do
    msg = create(:message)
    expect(msg.sender).to be_present
  end
end
