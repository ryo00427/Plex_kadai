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
end
