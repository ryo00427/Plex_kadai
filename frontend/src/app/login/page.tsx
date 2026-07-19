"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth";
import { ErrorState } from "@/components/PageState";

export default function LoginPage() {
  const { login } = useAuth();
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    try {
      await login(email, password);
      router.push("/");
    } catch {
      setError("メールまたはパスワードが違います");
    }
  }

  return (
    <div className="mx-auto max-w-sm">
      <h1 className="text-center text-2xl font-semibold tracking-tight">ログイン</h1>
      <div className="card mt-6 p-6">
        <form onSubmit={onSubmit} className="space-y-4">
          <div>
            <label htmlFor="login-email" className="mb-1 block text-sm font-medium">
              メールアドレス
            </label>
            <input
              id="login-email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              className="field"
            />
          </div>
          <div>
            <label htmlFor="login-password" className="mb-1 block text-sm font-medium">
              パスワード
            </label>
            <input
              id="login-password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="field"
            />
          </div>

          {error && <ErrorState message={error} />}

          <button type="submit" className="btn-primary w-full">
            ログイン
          </button>
        </form>
      </div>
      <p className="mt-4 text-center text-sm text-muted">
        アカウントをお持ちでない方は{" "}
        <Link href="/register" className="text-ai-700 hover:underline">
          登録
        </Link>
      </p>
    </div>
  );
}
