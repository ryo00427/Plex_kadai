"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter, useParams } from "next/navigation";
import { useAuth } from "@/lib/auth";
import { useApi } from "@/lib/hooks";
import { apiFetch } from "@/lib/api";
import { GradYearBadge } from "@/components/GradYearBadge";
import { LoadingState, ErrorState } from "@/components/PageState";
import type { Intern, Conversation } from "@/types";

export default function InternDetailPage() {
  const { token } = useAuth();
  const router = useRouter();
  const { id } = useParams<{ id: string }>();
  const { data, loading } = useApi<{ intern: Intern }>(`/interns/${id}`, token, !!token);
  const [error, setError] = useState("");

  async function scout() {
    setError("");
    try {
      const res = await apiFetch<{ conversation: Conversation }>("/conversations", {
        method: "POST", token, body: { intern_id: Number(id) },
      });
      router.push(`/messages/${res.conversation.id}`);
    } catch (err) {
      setError(err instanceof Error ? err.message : "スカウトに失敗しました");
    }
  }

  const backLink = (
    <Link href="/interns" className="text-sm text-muted hover:text-ai-700">
      ← インターン生一覧
    </Link>
  );

  if (loading || !data) {
    return (
      <div>
        {backLink}
        <div className="mt-4">
          <LoadingState />
        </div>
      </div>
    );
  }

  const intern = data.intern;

  return (
    <div>
      {backLink}

      <div className="mt-4 flex items-center gap-3">
        <h1 className="text-2xl font-semibold tracking-tight">{intern.name}</h1>
        <GradYearBadge year={intern.graduation_year} />
      </div>

      <dl className="card mt-6 divide-y divide-line p-6">
        <div className="grid gap-1 py-3 first:pt-0 sm:grid-cols-[8rem_1fr]">
          <dt className="text-sm text-muted">大学</dt>
          <dd className="text-ink">{intern.university || "未登録"}</dd>
        </div>
        <div className="grid gap-1 py-3 sm:grid-cols-[8rem_1fr]">
          <dt className="text-sm text-muted">専攻</dt>
          <dd className="text-ink">{intern.major || "未登録"}</dd>
        </div>
        <div className="grid gap-1 py-3 sm:grid-cols-[8rem_1fr]">
          <dt className="text-sm text-muted">スキル</dt>
          <dd className="font-mono text-ai-500">{intern.skills || "未登録"}</dd>
        </div>
        <div className="grid gap-1 py-3 last:pb-0 sm:grid-cols-[8rem_1fr]">
          <dt className="text-sm text-muted">自己紹介</dt>
          <dd className="text-ink">{intern.bio || "未登録"}</dd>
        </div>
      </dl>

      {error && (
        <div className="mt-4">
          <ErrorState message={error} />
        </div>
      )}

      <button onClick={scout} className="btn-scout mt-6">
        スカウトする
      </button>
    </div>
  );
}
