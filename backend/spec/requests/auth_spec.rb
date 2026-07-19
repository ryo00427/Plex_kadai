require "rails_helper"

RSpec.describe "Auth", type: :request do
  it "インターンを登録してトークンを返す" do
    post "/api/auth/register", params: {
      role: "intern", email: "new@example.com", password: "password123",
      profile: { name: "新人", university: "A大学" }
    }, as: :json
    expect(response).to have_http_status(:created)
    body = JSON.parse(response.body)
    expect(body["token"]).to be_present
    expect(body["account"]["role"]).to eq("intern")
    expect(body["account"]["profile"]["name"]).to eq("新人")
  end

  it "正しい資格情報でログインできる" do
    intern = create(:intern)
    post "/api/auth/login", params: { email: intern.account.email, password: "password123" }, as: :json
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["token"]).to be_present
  end

  it "誤ったパスワードは 401" do
    intern = create(:intern)
    post "/api/auth/login", params: { email: intern.account.email, password: "wrong" }, as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it "トークンで /api/me を取得できる" do
    intern = create(:intern)
    token = JsonWebToken.encode(account_id: intern.account.id)
    get "/api/me", headers: { "Authorization" => "Bearer #{token}" }
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["account"]["email"]).to eq(intern.account.email)
  end

  it "登録時と大文字小文字が異なるメールでもログインできる" do
    intern = create(:intern)
    post "/api/auth/login",
      params: { email: intern.account.email.upcase, password: "password123" }, as: :json
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["token"]).to be_present
  end

  it "トークンなしで /api/me にアクセスすると 401" do
    get "/api/me"
    expect(response).to have_http_status(:unauthorized)
  end

  it "不正なトークンで /api/me にアクセスすると 401" do
    get "/api/me", headers: { "Authorization" => "Bearer garbage.invalid.token" }
    expect(response).to have_http_status(:unauthorized)
  end

  it "登録したアカウントはプロフィールに紐づく" do
    post "/api/auth/register", params: {
      role: "intern", email: "newbie@example.com", password: "password123",
      profile: { name: "新人", university: "A大学" }
    }, as: :json

    expect(response).to have_http_status(:created)
    account = Account.find_by(email: "newbie@example.com")
    expect(account.profileable).to be_a(Intern)
    expect(account.profileable.name).to eq("新人")
  end

  it "ログイン試行が連続すると 429 を返す", :throttled do
    create(:intern).account.update!(email: "victim@example.com")

    6.times do
      post "/api/auth/login",
        params: { email: "victim@example.com", password: "wrong-password" },
        headers: { "REMOTE_ADDR" => "1.2.3.4" }, as: :json
    end

    expect(response).to have_http_status(:too_many_requests)
  end

  it "制限内のログイン試行は通常どおり処理される", :throttled do
    create(:intern).account.update!(email: "ok@example.com")

    post "/api/auth/login",
      params: { email: "ok@example.com", password: "password123" },
      headers: { "REMOTE_ADDR" => "5.6.7.8" }, as: :json

    expect(response).to have_http_status(:ok)
  end

  it "重複メールでの登録エラーは重複して返らない" do
    create(:intern).account.update!(email: "taken@example.com")

    post "/api/auth/register", params: {
      role: "intern", email: "taken@example.com", password: "password123",
      profile: { name: "後発" }
    }, as: :json

    expect(response).to have_http_status(:unprocessable_entity)
    errors = JSON.parse(response.body)["errors"]
    expect(errors).to eq(errors.uniq)
  end

  it "重複メールでの登録はプロフィール行を残さない" do
    create(:intern).account.update!(email: "taken2@example.com")

    expect {
      post "/api/auth/register", params: {
        role: "intern", email: "taken2@example.com", password: "password123",
        profile: { name: "後発" }
      }, as: :json
    }.not_to change(Intern, :count)

    expect(response).to have_http_status(:unprocessable_entity)
  end
end
