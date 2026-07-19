"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useRouter, useParams } from "next/navigation";
import { useAuth } from "@/lib/auth";
import { useApi } from "@/lib/hooks";
import { apiFetch } from "@/lib/api";
import { PageHeader, LoadingState, ErrorState } from "@/components/PageState";
import type { JobPosting } from "@/types";

export default function EditJobPage() {
  const { token, loading: authLoading } = useAuth();
  const router = useRouter();
  const { id } = useParams<{ id: string }>();
  const { data, error: loadError, loading } = useApi<{ job_posting: JobPosting }>(
    `/job_postings/${id}`,
    token,
    !authLoading
  );

  const [form, setForm] = useState({
    title: "",
    description: "",
    requirements: "",
    location: "",
    employment_type: "",
    status: "published",
  });
  const [error, setError] = useState("");
  const [saving, setSaving] = useState(false);

  // Seed the form once the posting arrives. The API omits blank optional
  // fields, so fall back to "" to keep every input controlled.
  useEffect(() => {
    const job = data?.job_posting;
    if (!job) return;
    setForm({
      title: job.title,
      description: job.description ?? "",
      requirements: job.requirements ?? "",
      location: job.location ?? "",
      employment_type: job.employment_type ?? "",
      status: job.status,
    });
  }, [data]);

  function update(key: string, value: string) {
    setForm((f) => ({ ...f, [key]: value }));
  }

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setSaving(true);
    try {
      await apiFetch(`/job_postings/${id}`, {
        method: "PATCH",
        token,
        body: { job_posting: form },
      });
      router.push("/company/jobs");
    } catch (err) {
      setError(err instanceof Error ? err.message : "更新に失敗しました");
    } finally {
      setSaving(false);
    }
  }

  if (loading || authLoading) {
    return (
      <div>
        <PageHeader title="募集を編集" />
        <LoadingState />
      </div>
    );
  }

  if (loadError || !data) {
    return (
      <div>
        <PageHeader title="募集を編集" />
        <ErrorState message={loadError ?? "募集が見つかりませんでした。"} />
      </div>
    );
  }

  return (
    <div>
      <PageHeader title="募集を編集" />
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
          <div>
            <label htmlFor="job-status" className="mb-1 block text-sm font-medium">
              公開状態
            </label>
            <select
              id="job-status"
              value={form.status}
              onChange={(e) => update("status", e.target.value)}
              className="field"
            >
              <option value="published">公開中</option>
              <option value="draft">下書き</option>
            </select>
          </div>

          {error && <ErrorState message={error} />}

          <div className="flex gap-3">
            <button type="submit" className="btn-primary" disabled={saving}>
              {saving ? "保存しています" : "保存する"}
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
