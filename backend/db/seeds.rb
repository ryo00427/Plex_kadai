[Message, Conversation, JobPosting, Account, Intern, Company].each(&:delete_all)

company = Company.create!(
  name: "プレックス",
  industry: "IT / 人材",
  description: <<~TEXT.strip,
    インターン生と企業をつなぐスカウトサービス「Scout」を開発・運営しています。
    エンジニア10名ほどの組織で、企画から実装・運用までを少人数で回しています。
  TEXT
  website: "https://example.com"
)
company.create_account!(email: "company@example.com", password: "password123", role: :company)

# Varied profiles so the intern list and detail screens show meaningful differences
# (university, major, skills) rather than three identical rows.
intern_attrs = [
  {
    name: "山田太郎",
    university: "東京工業大学",
    major: "情報工学科",
    graduation_year: 2027,
    skills: "Ruby, Ruby on Rails, PostgreSQL, Docker",
    bio: <<~TEXT.strip
      大学ではデータベース設計を専攻しています。個人開発で書籍管理アプリを Rails で作り、
      認証まわりとテスト(RSpec)を一通り自分で書きました。
      サーバーサイドを中心に、設計から任せてもらえる環境で力をつけたいです。
    TEXT
  },
  {
    name: "佐藤花子",
    university: "早稲田大学",
    major: "基幹理工学部 情報理工学科",
    graduation_year: 2026,
    skills: "TypeScript, React, Next.js, Figma",
    bio: <<~TEXT.strip
      フロントエンドとデザインの両方に関心があります。学園祭の公式サイトを Next.js で作り直し、
      Lighthouse のスコアを 62 から 94 まで改善しました。
      アクセシビリティを考慮した UI 実装を得意としています。
    TEXT
  },
  {
    name: "鈴木一郎",
    university: "京都大学",
    major: "理学部 数学科",
    graduation_year: 2028,
    skills: "Python, pandas, scikit-learn, SQL",
    bio: <<~TEXT.strip
      統計とデータ分析が専門で、研究室では時系列データの異常検知を扱っています。
      Web 開発の実務経験はまだありませんが、SQL とデータ処理は日常的に書いています。
      分析結果をプロダクトの意思決定につなげる仕事に興味があります。
    TEXT
  }
]

interns = intern_attrs.map.with_index do |attrs, i|
  intern = Intern.create!(**attrs)
  intern.create_account!(email: "intern#{i + 1}@example.com", password: "password123", role: :intern)
  intern
end

company.job_postings.create!(
  title: "【サマーインターン】Rails でのバックエンド開発",
  description: <<~TEXT.strip,
    自社スカウトサービス「Scout」のバックエンド開発を、社員エンジニアとペアで担当していただきます。

    具体的には、募集管理まわりの API 追加、既存エンドポイントのパフォーマンス改善、
    RSpec でのテスト拡充などを想定しています。
    設計レビューにも参加していただき、「なぜその設計にしたか」を説明する経験を積んでもらいます。

    期間は8月から9月の2か月間、週3日以上での稼働を想定しています。
  TEXT
  requirements: <<~TEXT.strip,
    【必須】
    ・何らかの言語で Web アプリケーションを個人開発した経験
    ・Git を使った共同開発の基本的な理解(ブランチ、プルリクエスト)
    ・週3日以上、2か月間継続して稼働できる方

    【歓迎】
    ・Ruby on Rails での開発経験
    ・RSpec などを用いた自動テストの作成経験
    ・SQL でのパフォーマンスチューニング経験
  TEXT
  location: "東京都渋谷区(週1日出社、他リモート可)",
  employment_type: "長期インターン(時給1,500円〜2,000円)",
  status: :published
)

company.job_postings.create!(
  title: "【冬季インターン】フロントエンド開発(公開準備中)",
  description: <<~TEXT.strip,
    Next.js (App Router) と TypeScript を用いた、スカウト画面のリニューアルを担当していただきます。

    デザイナーが用意した Figma をもとに、コンポーネント設計から実装まで進めてもらう想定です。
    条件と期間を調整中のため、現在は下書きとして保存しています。
  TEXT
  requirements: <<~TEXT.strip,
    【必須】
    ・HTML / CSS / JavaScript の基礎的な理解
    ・React を用いた開発経験(規模は問いません)

    【歓迎】
    ・TypeScript での開発経験
    ・Figma からの UI 実装経験
  TEXT
  location: "東京都渋谷区(フルリモート可)",
  employment_type: "長期インターン(条件調整中)",
  status: :draft
)

convo = Conversation.create!(company:, intern: interns.first)
convo.messages.create!(
  sender: company,
  body: <<~TEXT.strip
    山田さん、はじめまして。株式会社プレックスの採用担当です。

    個人開発で認証やテストまで書き切っているプロフィールを拝見し、ぜひ一度お話ししたくご連絡しました。
    サマーインターンでは Rails の API 開発を社員とペアで進めていただく想定です。

    もしご興味があれば、まずは30分ほどカジュアルにお話しできればと思います。いかがでしょうか。
  TEXT
)
convo.messages.create!(
  sender: interns.first,
  body: <<~TEXT.strip
    ご連絡ありがとうございます、山田です。

    サマーインターンの募集を拝見しました。設計レビューに参加できる点にとても興味があります。
    ぜひ一度お話しさせてください。今週であれば水曜と金曜の午後が空いております。
  TEXT
)

puts "Seeded: companies=#{Company.count} interns=#{Intern.count} postings=#{JobPosting.count}"
