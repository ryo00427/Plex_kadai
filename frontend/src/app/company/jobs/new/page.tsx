"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth";
import { apiFetch } from "@/lib/api";
import { PageHeader, ErrorState } from "@/components/PageState";

export default function NewJobPage() {
  const { token } = useAuth();
  const router = useRouter();
  const [form, setForm] = useState({
    title: "",
    description: "",
    requirements: "",
    location: "",
    employment_type: "",
    status: "published",
  });
  const [error, setError] = useState("");

  function update(key: string, value: string) {
    setForm((f) => ({ ...f, [key]: value }));
  }

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    try {
      await apiFetch("/companies/me/job_postings", {
        method: "POST",
        token,
        body: { job_posting: form },
      });
      router.push("/company/jobs");
    } catch (err) {
      setError(err instanceof Error ? err.message : "作成に失敗しました");
    }
  }

  return (
    <div>
      <PageHeader title="募集を作成" />
      <div className="card p-6">
        <form onSubmit={onSubmit} className="space-y-4">
          <div>
            <label htmlFor="job-title" className="mb-1 block text-sm font-medium">
              タイトル
            </label>
            <input
              id="job-title"
              value={form.title}
              onChange={(e) => update("title", e.target.value)}
              required
              className="field"
            />
          </div>
          <div>
            <label htmlFor="job-description" className="mb-1 block text-sm font-medium">
              仕事内容
            </label>
            <textarea
              id="job-description"
              value={form.description}
              onChange={(e) => update("description", e.target.value)}
              className="field"
            />
          </div>
          <div>
            <label htmlFor="job-requirements" className="mb-1 block text-sm font-medium">
              応募要件
            </label>
            <textarea
              id="job-requirements"
              value={form.requirements}
              onChange={(e) => update("requirements", e.target.value)}
              className="field"
            />
          </div>
          <div>
            <label htmlFor="job-location" className="mb-1 block text-sm font-medium">
              勤務地
            </label>
            <input
              id="job-location"
              value={form.location}
              onChange={(e) => update("location", e.target.value)}
              className="field"
            />
          </div>
          <div>
            <label htmlFor="job-employment-type" className="mb-1 block text-sm font-medium">
              雇用形態
            </label>
            <input
              id="job-employment-type"
              value={form.employment_type}
              onChange={(e) => update("employment_type", e.target.value)}
              className="field"
            />
          </div>

          {error && <ErrorState message={error} />}

          <div className="flex gap-3">
            <button type="submit" className="btn-primary">
              掲載する
            </button>
            <Link href="/company/jobs" className="btn-quiet">
              キャンセル
            </Link>
          </div>
        </form>
      </div>
    </div>
  );
}
