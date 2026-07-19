"use client";

import Link from "next/link";
import { useAuth } from "@/lib/auth";
import { useApi } from "@/lib/hooks";
import { PageHeader, LoadingState, EmptyState } from "@/components/PageState";
import type { Conversation } from "@/types";

export default function MessagesPage() {
  const { token, account } = useAuth();
  const { data, loading } = useApi<{ conversations: Conversation[] }>(
    "/conversations",
    token,
    !!token
  );

  const conversations = data?.conversations ?? [];
  const isCompany = account?.role === "company";

  return (
    <div>
      <PageHeader title="メッセージ" />

      {loading ? (
        <LoadingState />
      ) : conversations.length === 0 ? (
        <EmptyState
          message="まだ会話がありません。"
          actionHref={isCompany ? "/interns" : undefined}
          actionLabel={isCompany ? "インターン生を探す" : undefined}
        />
      ) : (
        <ul className="space-y-3">
          {conversations.map((c) => {
            const partner = isCompany ? c.intern.name : c.company.name;
            return (
              <li key={c.id}>
                <Link
                  href={`/messages/${c.id}`}
                  className="card flex flex-col gap-1 p-5 transition-shadow hover:shadow-lift"
                >
                  <p className="font-medium text-ai-900">{partner}</p>
                  <p
                    className={`truncate text-sm ${
                      c.last_message ? "text-muted" : "text-muted/70"
                    }`}
                  >
                    {c.last_message?.body ?? "まだメッセージがありません"}
                  </p>
                </Link>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
