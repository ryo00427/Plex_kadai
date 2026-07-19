"use client";

import { useState, useCallback, useEffect } from "react";
import Link from "next/link";
import { useParams } from "next/navigation";
import { useAuth } from "@/lib/auth";
import { apiFetch } from "@/lib/api";
import { ErrorState } from "@/components/PageState";
import type { Message } from "@/types";

/** Format a message timestamp as HH:MM, guarding against an invalid date. */
function formatTime(iso: string): string {
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return "";
  return date.toLocaleTimeString("ja-JP", { hour: "2-digit", minute: "2-digit" });
}

export default function ThreadPage() {
  const { token, account } = useAuth();
  const { id } = useParams<{ id: string }>();
  const [messages, setMessages] = useState<Message[]>([]);
  const [body, setBody] = useState("");
  const [error, setError] = useState("");

  const load = useCallback(async () => {
    try {
      const res = await apiFetch<{ messages: Message[] }>(`/conversations/${id}/messages`, { token });
      setMessages(res.messages);
    } catch (err) {
      setError(err instanceof Error ? err.message : "メッセージの取得に失敗しました");
    }
  }, [id, token]);

  useEffect(() => { if (token) load(); }, [token, load]);

  async function send(e: React.FormEvent) {
    e.preventDefault();
    if (!body.trim()) return;
    setError("");
    try {
      await apiFetch(`/conversations/${id}/messages`, { method: "POST", token, body: { body } });
      setBody("");
      await load();
    } catch (err) {
      setError(err instanceof Error ? err.message : "送信に失敗しました");
    }
  }

  const myType = account?.role === "company" ? "Company" : "Intern";

  return (
    <div>
      <Link href="/messages" className="text-sm text-muted hover:text-ai-700">
        ← メッセージ一覧
      </Link>

      <div className="mt-4 max-h-[60vh] space-y-3 overflow-y-auto pr-1">
        {messages.length === 0 ? (
          <p className="py-10 text-center text-sm text-muted">
            まだメッセージがありません。最初のメッセージを送ってみましょう。
          </p>
        ) : (
          messages.map((m) => {
            const own = m.sender_type === myType;
            return (
              <div key={m.id} className={`flex flex-col ${own ? "items-end" : "items-start"}`}>
                <div
                  className={`max-w-[80%] whitespace-pre-wrap break-words rounded-lg px-4 py-2.5 ${
                    own ? "bg-ai-700 text-white" : "border border-line bg-surface"
                  }`}
                >
                  {m.body}
                </div>
                <span className="mt-1 font-mono text-[11px] text-muted">
                  {formatTime(m.created_at)}
                </span>
              </div>
            );
          })
        )}
      </div>

      {error && (
        <div className="mt-4">
          <ErrorState message={error} />
        </div>
      )}

      <form onSubmit={send} className="card mt-4 flex gap-2 p-3">
        <input
          value={body}
          onChange={(e) => setBody(e.target.value)}
          placeholder="メッセージを入力"
          className="field flex-1"
        />
        <button type="submit" disabled={!body.trim()} className="btn-scout">
          送信
        </button>
      </form>
    </div>
  );
}
