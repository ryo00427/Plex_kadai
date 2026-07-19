"use client";

import { useState } from "react";
import Link from "next/link";
import { useAuth } from "@/lib/auth";
import { useApi } from "@/lib/hooks";
import { apiFetch } from "@/lib/api";
import {
  PageHeader,
  LoadingState,
  EmptyState,
  ErrorState,
  StatusChip,
} from "@/components/PageState";
import type { JobPosting } from "@/types";

export default function CompanyJobsPage() {
  const { token } = useAuth();
  const { data, loading } = useApi<{ job_postings: JobPosting[] }>(
    "/companies/me/job_postings",
    token,
    !!token
  );
  // useApi has no refetch, so drop deleted rows locally rather than holding a
  // second copy of the list that could drift from the server response.
  const [deletedIds, setDeletedIds] = useState<number[]>([]);
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [error, setError] = useState("");

  const jobs = (data?.job_postings ?? []).filter((j) => !deletedIds.includes(j.id));

  async function remove(job: JobPosting) {
    if (!confirm(`「${job.title}」を削除します。取り消せません。`)) return;
    setError("");
    setDeletingId(job.id);
    try {
      await apiFetch(`/job_postings/${job.id}`, { method: "DELETE", token });
      setDeletedIds((ids) => [...ids, job.id]);
    } catch (err) {
      setError(err instanceof Error ? err.message : "削除に失敗しました");
    } finally {
      setDeletingId(null);
    }
  }

  return (
    <div>
      <PageHeader
        title="募集管理"
        action={
          <Link href="/company/jobs/new" className="btn-primary">
            募集を作成
          </Link>
        }
      />

      {error && (
        <div className="mb-4">
          <ErrorState message={error} />
        </div>
      )}

      {loading ? (
        <LoadingState />
      ) : jobs.length === 0 ? (
        <EmptyState
          message="まだ募集がありません。"
          actionHref="/company/jobs/new"
          actionLabel="募集を作成"
        />
      ) : (
        <ul className="space-y-3">
          {jobs.map((job) => (
            <li key={job.id} className="card p-5">
              <div className="flex flex-wrap items-start justify-between gap-4">
                <div>
                  <div className="flex items-center gap-3">
                    <p className="font-medium text-ai-900">{job.title}</p>
                    <StatusChip status={job.status} />
                  </div>
                  <p className="mt-1 text-sm text-muted">
                    {[job.location, job.employment_type].filter(Boolean).join(" / ")}
                  </p>
                </div>
                <div className="flex gap-2">
                  <Link href={`/jobs/${job.id}`} className="btn-quiet">
                    詳細
                  </Link>
                  <Link href={`/company/jobs/${job.id}/edit`} className="btn-quiet">
                    編集
                  </Link>
                  <button
                    onClick={() => remove(job)}
                    disabled={deletingId === job.id}
                    className="btn-quiet text-shu-600"
                  >
                    {deletingId === job.id ? "削除中" : "削除"}
                  </button>
                </div>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
