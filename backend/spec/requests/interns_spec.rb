require "rails_helper"

RSpec.describe "Interns", type: :request do
  def auth_header(account) = { "Authorization" => "Bearer #{JsonWebToken.encode(account_id: account.id)}" }

  it "企業はインターン一覧を取得できる" do
    create(:intern, name: "候補A")
    company = create(:company)
    get "/api/interns", headers: auth_header(company.account)
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["interns"].map { |i| i["name"] }).to include("候補A")
  end

  it "インターンは一覧取得を 403 で拒否される" do
    intern = create(:intern)
    get "/api/interns", headers: auth_header(intern.account)
    expect(response).to have_http_status(:forbidden)
  end

  it "本人は自分のプロフィールを更新できる" do
    intern = create(:intern)
    patch "/api/interns/me", params: { intern: { bio: "更新後" } }, headers: auth_header(intern.account), as: :json
    expect(response).to have_http_status(:ok)
    expect(intern.reload.bio).to eq("更新後")
  end

  it "企業はインターンのプロフィールを更新できない (403)" do
    company = create(:company)
    patch "/api/interns/me", params: { intern: { bio: "改ざん" } }, headers: auth_header(company.account), as: :json
    expect(response).to have_http_status(:forbidden)
  end

  it "存在しないインターンの取得は 404 を JSON で返す" do
    company = create(:company)
    get "/api/interns/999999", headers: auth_header(company.account)
    expect(response).to have_http_status(:not_found)
    expect(JSON.parse(response.body)["error"]).to eq("Not Found")
  end
end
