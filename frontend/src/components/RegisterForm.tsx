"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth";
import type { Role } from "@/types";
import { ErrorState } from "@/components/PageState";

export function RegisterForm() {
  const { register } = useAuth();
  const router = useRouter();
  const [role, setRole] = useState<Role>("intern");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [name, setName] = useState("");
  const [error, setError] = useState("");

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    try {
      await register({ role, email, password, profile: { name } });
      router.push(role === "company" ? "/interns" : "/jobs");
    } catch (err) {
      setError(err instanceof Error ? err.message : "登録に失敗しました");
    }
  }

  const nameLabel = role === "company" ? "会社名" : "氏名";

  return (
    <form onSubmit={onSubmit} className="space-y-4">
      <div>
        <label htmlFor="register-role" className="mb-1 block text-sm font-medium">
          ロール
        </label>
        <select
          id="register-role"
          value={role}
          onChange={(e) => setRole(e.target.value as Role)}
          className="field"
        >
          <option value="intern">インターン生</option>
          <option value="company">企業</option>
        </select>
      </div>
      <div>
        <label htmlFor="register-name" className="mb-1 block text-sm font-medium">
          {nameLabel}
        </label>
        <input
          id="register-name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          required
          className="field"
        />
      </div>
      <div>
        <label htmlFor="register-email" className="mb-1 block text-sm font-medium">
          メール
        </label>
        <input
          id="register-email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
          className="field"
        />
      </div>
      <div>
        <label htmlFor="register-password" className="mb-1 block text-sm font-medium">
          パスワード
        </label>
        <input
          id="register-password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
          minLength={8}
          className="field"
        />
      </div>

      {error && <ErrorState message={error} />}

      <button type="submit" className="btn-primary w-full">
        登録
      </button>
    </form>
  );
}
