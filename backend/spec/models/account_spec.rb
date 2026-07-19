require "rails_helper"

RSpec.describe Account, type: :model do
  it "メールは必須で一意" do
    create(:account, email: "a@example.com")
    dup = build(:account, email: "a@example.com")
    expect(dup).not_to be_valid
  end

  it "パスワードを認証できる" do
    account = create(:account, password: "secret123")
    expect(account.authenticate("secret123")).to be_truthy
    expect(account.authenticate("wrong")).to be_falsey
  end

  it "role enum を持つ" do
    expect(build(:account, role: :company).company?).to be true
  end

  it "メールは前後の空白を除去して小文字化して保存する" do
    account = create(:account, email: " Mixed.Case@Example.com ")
    expect(account.email).to eq("mixed.case@example.com")
  end
end
