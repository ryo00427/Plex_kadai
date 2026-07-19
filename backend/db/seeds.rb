[Message, Conversation, JobPosting, Account, Intern, Company].each(&:delete_all)

company = Company.create!(name: "プレックス", industry: "IT", description: "スカウトサービス運営", website: "https://example.com")
company.create_account!(email: "company@example.com", password: "password123", role: :company)

interns = ["山田太郎", "佐藤花子", "鈴木一郎"].map.with_index do |name, i|
  intern = Intern.create!(name:, university: "サンプル大学", major: "情報工学",
                          graduation_year: 2027, skills: "Ruby, TypeScript", bio: "#{name}です")
  intern.create_account!(email: "intern#{i + 1}@example.com", password: "password123", role: :intern)
  intern
end

company.job_postings.create!(title: "サマーインターン", description: "Web 開発", requirements: "Ruby か TS",
                             location: "東京", employment_type: "インターン", status: :published)
company.job_postings.create!(title: "冬季インターン(下書き)", description: "準備中", status: :draft)

convo = Conversation.create!(company:, intern: interns.first)
convo.messages.create!(sender: company, body: "はじめまして、スカウトです")
convo.messages.create!(sender: interns.first, body: "ご連絡ありがとうございます")

puts "Seeded: companies=#{Company.count} interns=#{Intern.count} postings=#{JobPosting.count}"
