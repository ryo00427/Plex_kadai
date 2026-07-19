require "rails_helper"

RSpec.describe JsonWebToken do
  it "エンコードしたトークンをデコードできる" do
    token = described_class.encode(account_id: 42)
    payload = described_class.decode(token)
    expect(payload[:account_id]).to eq(42)
  end

  it "不正なトークンは nil を返す" do
    expect(described_class.decode("garbage")).to be_nil
  end

  it "期限切れトークンは nil を返す" do
    token = described_class.encode({ account_id: 1 }, 1.hour.ago)
    expect(described_class.decode(token)).to be_nil
  end
end
