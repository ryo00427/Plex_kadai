require "rails_helper"

RSpec.describe "Pagination", type: :request do
  def auth_header(account) = { "Authorization" => "Bearer #{JsonWebToken.encode(account_id: account.id)}" }

  it "既定では 20 件までを返し meta を含む" do
    company = create(:company)
    25.times { create(:intern) }

    get "/api/interns", headers: auth_header(company.account)
    body = JSON.parse(response.body)

    expect(body["interns"].size).to eq(20)
    expect(body["meta"]).to eq(
      "page" => 1, "per" => 20, "total_count" => 25, "total_pages" => 2
    )
  end

  it "page と per を指定できる" do
    company = create(:company)
    25.times { create(:intern) }

    get "/api/interns", params: { page: 2, per: 10 }, headers: auth_header(company.account)
    body = JSON.parse(response.body)

    expect(body["interns"].size).to eq(10)
    expect(body["meta"]["page"]).to eq(2)
    expect(body["meta"]["total_pages"]).to eq(3)
  end

  it "per は上限 100 に丸められる" do
    company = create(:company)
    create(:intern)

    get "/api/interns", params: { per: 5000 }, headers: auth_header(company.account)
    expect(JSON.parse(response.body)["meta"]["per"]).to eq(100)
  end

  it "不正な page / per は既定値に丸められる" do
    company = create(:company)
    create(:intern)

    get "/api/interns", params: { page: 0, per: -1 }, headers: auth_header(company.account)
    meta = JSON.parse(response.body)["meta"]
    expect(meta["page"]).to eq(1)
    expect(meta["per"]).to eq(20)
  end

  it "募集一覧もページネーションされる" do
    company = create(:company)
    25.times { create(:job_posting, company:, status: :published) }

    get "/api/job_postings"
    body = JSON.parse(response.body)
    expect(body["job_postings"].size).to eq(20)
    expect(body["meta"]["total_count"]).to eq(25)
  end

  it "メッセージ一覧もページネーションされる" do
    convo = create(:conversation)
    25.times { |n| create(:message, conversation: convo, sender: convo.company, body: "本文#{n}") }

    get "/api/conversations/#{convo.id}/messages", headers: auth_header(convo.intern.account)
    body = JSON.parse(response.body)
    expect(body["messages"].size).to eq(20)
    expect(body["meta"]["total_count"]).to eq(25)
  end

  it "会話一覧もページネーションされる" do
    intern = create(:intern)
    25.times { create(:conversation, intern:) }

    get "/api/conversations", headers: auth_header(intern.account)
    body = JSON.parse(response.body)
    expect(body["conversations"].size).to eq(20)
    expect(body["meta"]["total_count"]).to eq(25)
  end
end
