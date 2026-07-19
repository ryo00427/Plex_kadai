"use client";

import Link from "next/link";
import { useAuth } from "@/lib/auth";
import { GradYearBadge } from "@/components/GradYearBadge";

/** Signed-out landing. The hero states the mechanic that makes this a scout
 *  service rather than a job board: the company reaches out first. */
function Landing() {
  return (
    <div className="space-y-12">
      <section className="pt-4">
        <p className="font-mono text-xs uppercase tracking-widest text-ai-500">
          Scout
        </p>
        <h1 className="mt-3 max-w-2xl text-4xl font-semibold tracking-tight sm:text-5xl">
          応募するのではなく、
          <br />
          声がかかる。
        </h1>
        <p className="mt-4 max-w-xl text-muted">
          プロフィールを登録しておくと、企業があなたを見つけてスカウトを送ります。
          学生は待っているあいだに何度も応募書類を書かなくて済み、企業は条件の合う学生に直接話しかけられます。
        </p>
        <div className="mt-7 flex flex-wrap gap-3">
          <Link href="/register" className="btn-primary">
            登録する
          </Link>
          <Link href="/jobs" className="btn-quiet">
            募集を見る
          </Link>
        </div>
      </section>

      {/* Show the artifact itself — a scout message — rather than describing it. */}
      <section>
        <h2 className="mb-3 text-sm font-medium text-muted">
          届くスカウトの例
        </h2>
        <div className="card max-w-xl overflow-hidden">
          <div className="flex items-center gap-3 border-b border-line bg-ai-50 px-5 py-3">
            <span className="font-medium text-ai-900">プレックス</span>
            <span className="text-xs text-muted">が</span>
            <GradYearBadge year={2027} size="sm" />
            <span className="text-xs text-muted">のあなたに</span>
          </div>
          <div className="px-5 py-4">
            <p className="text-sm leading-relaxed">
              はじめまして。プロフィールの「Ruby / TypeScript」を拝見してご連絡しました。
              夏のインターンで、実際にリリースまで持っていける開発チームを探しています。
            </p>
          </div>
        </div>
      </section>

      <section className="grid gap-4 sm:grid-cols-2">
        <div className="card p-5">
          <h3 className="font-medium">インターン生の方</h3>
          <p className="mt-1.5 text-sm text-muted">
            大学・専攻・スキルを登録すると、企業の検討対象に入ります。届いたスカウトにはそのまま返信できます。
          </p>
        </div>
        <div className="card p-5">
          <h3 className="font-medium">企業の方</h3>
          <p className="mt-1.5 text-sm text-muted">
            登録しているインターン生の一覧から、気になる学生に直接スカウトを送れます。募集の掲載も可能です。
          </p>
        </div>
      </section>
    </div>
  );
}

/** Signed-in home: a jump-off to the things this role actually does. */
function Dashboard({ role }: { role: "intern" | "company" }) {
  const destinations =
    role === "company"
      ? [
          {
            href: "/interns",
            title: "インターン生を探す",
            body: "登録している学生の一覧から、気になる相手にスカウトを送ります。",
          },
          {
            href: "/company/jobs",
            title: "募集管理",
            body: "掲載中の募集と下書きを確認し、新しい募集を作成します。",
          },
          {
            href: "/messages",
            title: "メッセージ",
            body: "スカウトした学生とのやり取りを確認します。",
          },
        ]
      : [
          {
            href: "/messages",
            title: "メッセージ",
            body: "企業から届いたスカウトを確認し、返信します。",
          },
          {
            href: "/jobs",
            title: "募集を見る",
            body: "公開中のインターン募集を一覧で確認します。",
          },
        ];

  return (
    <div>
      <h1 className="text-2xl font-semibold tracking-tight">
        {role === "company" ? "企業ダッシュボード" : "マイページ"}
      </h1>
      <div className="mt-6 grid gap-4 sm:grid-cols-2">
        {destinations.map((d) => (
          <Link
            key={d.href}
            href={d.href}
            className="card p-5 transition-shadow hover:shadow-lift"
          >
            <h2 className="font-medium text-ai-700">{d.title}</h2>
            <p className="mt-1.5 text-sm text-muted">{d.body}</p>
          </Link>
        ))}
      </div>
    </div>
  );
}

export default function Home() {
  const { account, loading } = useAuth();

  if (loading) return null;
  return account ? <Dashboard role={account.role} /> : <Landing />;
}
