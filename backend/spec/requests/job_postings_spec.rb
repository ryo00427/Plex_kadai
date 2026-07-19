require "rails_helper"

RSpec.describe "JobPostings", type: :request do
  def auth_header(account) = { "Authorization" => "Bearer #{JsonWebToken.encode(account_id: account.id)}" }

  it "公開募集を認証なしで一覧できる" do
    create(:job_posting, status: :published, title: "公開求人")
    create(:job_posting, status: :draft, title: "下書き")
    get "/api/job_postings"
    titles = JSON.parse(response.body)["job_postings"].map { |j| j["title"] }
    expect(titles).to include("公開求人")
    expect(titles).not_to include("下書き")
  end

  it "企業は自社の募集を作成できる" do
    company = create(:company)
    post "/api/companies/me/job_postings",
      params: { job_posting: { title: "新規", description: "説明" } },
      headers: auth_header(company.account), as: :json
    expect(response).to have_http_status(:created)
    expect(company.job_postings.count).to eq(1)
  end

  it "他社の募集は更新できない (403)" do
    owner = create(:company)
    other = create(:company)
    posting = create(:job_posting, company: owner)
    patch "/api/job_postings/#{posting.id}",
      params: { job_posting: { title: "改ざん" } },
      headers: auth_header(other.account), as: :json
    expect(response).to have_http_status(:forbidden)
  end

  it "存在しない募集の取得は 404 を JSON で返す" do
    get "/api/job_postings/999999"
    expect(response).to have_http_status(:not_found)
    expect(JSON.parse(response.body)["error"]).to eq("Not Found")
  end

  it "公開済み募集は認証なしで取得できる (200)" do
    posting = create(:job_posting, status: :published)
    get "/api/job_postings/#{posting.id}"
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["job_posting"]["id"]).to eq(posting.id)
  end

  it "下書きは公開されていないため誰も取得できない (404)" do
    owner = create(:company)
    posting = create(:job_posting, company: owner, status: :draft)
    get "/api/job_postings/#{posting.id}"
    expect(response).to have_http_status(:not_found)
  end

  it "下書きの所有企業自身は取得できる (200)" do
    owner = create(:company)
    posting = create(:job_posting, company: owner, status: :draft)
    get "/api/job_postings/#{posting.id}", headers: auth_header(owner.account)
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["job_posting"]["id"]).to eq(posting.id)
  end

  it "GET /api/companies/me/job_postings で自社の下書きと公開分を取得できる" do
    owner = create(:company)
    published = create(:job_posting, company: owner, status: :published)
    draft = create(:job_posting, company: owner, status: :draft)
    get "/api/companies/me/job_postings", headers: auth_header(owner.account)
    expect(response).to have_http_status(:ok)
    ids = JSON.parse(response.body)["job_postings"].map { |j| j["id"] }
    expect(ids).to contain_exactly(published.id, draft.id)
  end

  it "GET /api/companies/me/job_postings は他社の募集を含まない" do
    owner = create(:company)
    other = create(:company)
    create(:job_posting, company: other, status: :published)
    get "/api/companies/me/job_postings", headers: auth_header(owner.account)
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["job_postings"]).to eq([])
  end

  it "インターンは GET /api/companies/me/job_postings を 403 で拒否される" do
    intern = create(:intern)
    get "/api/companies/me/job_postings", headers: auth_header(intern.account)
    expect(response).to have_http_status(:forbidden)
  end

  it "インターンは募集を作成できない (403)" do
    intern = create(:intern)
    post "/api/companies/me/job_postings",
      params: { job_posting: { title: "新規" } },
      headers: auth_header(intern.account), as: :json
    expect(response).to have_http_status(:forbidden)
  end

  it "role と profileable_type がずれたアカウントは他社の募集を編集できない" do
    owner = create(:company)
    posting = create(:job_posting, company: owner, title: "元のタイトル")
    # A row that predates the role/profileable_type validation: role claims
    # company and profileable_id happens to match the owning company, but the
    # profile is actually an Intern. Trusting role alone would grant ownership.
    impostor = create(:intern)
    impostor.account.update_columns(role: 1, profileable_type: "Intern", profileable_id: owner.id)

    patch "/api/job_postings/#{posting.id}",
      params: { job_posting: { title: "乗っ取り" } },
      headers: auth_header(impostor.account), as: :json

    expect(response).to have_http_status(:forbidden)
    expect(posting.reload.title).to eq("元のタイトル")
  end
end
