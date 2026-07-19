require "rails_helper"

RSpec.describe "Conversations", type: :request do
  def auth_header(account) = { "Authorization" => "Bearer #{JsonWebToken.encode(account_id: account.id)}" }

  it "企業がインターンとの会話を開始できる" do
    company = create(:company)
    intern = create(:intern)
    post "/api/conversations", params: { intern_id: intern.id }, headers: auth_header(company.account), as: :json
    expect(response).to have_http_status(:created)
    expect(company.conversations.count).to eq(1)
  end

  it "会話開始は冪等（重複作成しない）" do
    company = create(:company)
    intern = create(:intern)
    convo = create(:conversation, company:, intern:)
    post "/api/conversations", params: { intern_id: intern.id }, headers: auth_header(company.account), as: :json
    expect(JSON.parse(response.body)["conversation"]["id"]).to eq(convo.id)
    expect(company.conversations.count).to eq(1)
  end

  it "参加者はメッセージを送受信できる" do
    convo = create(:conversation)
    post "/api/conversations/#{convo.id}/messages",
      params: { body: "面談しませんか" }, headers: auth_header(convo.company.account), as: :json
    expect(response).to have_http_status(:created)

    get "/api/conversations/#{convo.id}/messages", headers: auth_header(convo.intern.account)
    expect(JSON.parse(response.body)["messages"].first["body"]).to eq("面談しませんか")
  end

  it "非参加者はメッセージを閲覧できない (403)" do
    convo = create(:conversation)
    outsider = create(:intern)
    get "/api/conversations/#{convo.id}/messages", headers: auth_header(outsider.account)
    expect(response).to have_http_status(:forbidden)
  end

  it "非参加者はメッセージを投稿できない (403)" do
    convo = create(:conversation)
    outsider = create(:intern)
    post "/api/conversations/#{convo.id}/messages",
      params: { body: "無関係な投稿" }, headers: auth_header(outsider.account), as: :json
    expect(response).to have_http_status(:forbidden)
  end

  it "インターンは会話を開始できない (403)" do
    intern = create(:intern)
    other_intern = create(:intern)
    post "/api/conversations", params: { intern_id: other_intern.id }, headers: auth_header(intern.account), as: :json
    expect(response).to have_http_status(:forbidden)
  end

  it "トークンなしで会話一覧にアクセスすると 401" do
    get "/api/conversations"
    expect(response).to have_http_status(:unauthorized)
  end

  it "不正なトークンで会話一覧にアクセスすると 401" do
    get "/api/conversations", headers: { "Authorization" => "Bearer not-a-real-token" }
    expect(response).to have_http_status(:unauthorized)
  end

  it "存在しないインターンとの会話開始は 404" do
    company = create(:company)
    post "/api/conversations", params: { intern_id: 0 }, headers: auth_header(company.account), as: :json
    expect(response).to have_http_status(:not_found)
  end

  it "相手のメッセージを既読にできる" do
    convo = create(:conversation)
    post "/api/conversations/#{convo.id}/messages",
      params: { body: "面談しませんか" }, headers: auth_header(convo.company.account), as: :json

    post "/api/conversations/#{convo.id}/read", headers: auth_header(convo.intern.account), as: :json
    expect(response).to have_http_status(:no_content)
    expect(convo.messages.reload.first.read_at).to be_present
  end

  it "自分が送ったメッセージは既読にしない" do
    convo = create(:conversation)
    post "/api/conversations/#{convo.id}/messages",
      params: { body: "面談しませんか" }, headers: auth_header(convo.company.account), as: :json

    post "/api/conversations/#{convo.id}/read", headers: auth_header(convo.company.account), as: :json
    # Asserting the status too: without it this example passes even when the
    # endpoint does nothing at all (or 404s), since read_at is nil either way.
    expect(response).to have_http_status(:no_content)
    expect(convo.messages.reload.first.read_at).to be_nil
  end

  it "非参加者は既読にできない (403)" do
    convo = create(:conversation)
    outsider = create(:intern)
    post "/api/conversations/#{convo.id}/read", headers: auth_header(outsider.account), as: :json
    expect(response).to have_http_status(:forbidden)
  end

  it "会話一覧に未読件数が含まれる" do
    convo = create(:conversation)
    post "/api/conversations/#{convo.id}/messages",
      params: { body: "面談しませんか" }, headers: auth_header(convo.company.account), as: :json

    get "/api/conversations", headers: auth_header(convo.intern.account)
    expect(JSON.parse(response.body)["conversations"].first["unread_count"]).to eq(1)

    get "/api/conversations", headers: auth_header(convo.company.account)
    expect(JSON.parse(response.body)["conversations"].first["unread_count"]).to eq(0)
  end
end
