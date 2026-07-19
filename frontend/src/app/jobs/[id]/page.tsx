"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import { useAuth } from "@/lib/auth";
import { useApi } from "@/lib/hooks";
import { StatusChip, LoadingState, ErrorState } from "@/components/PageState";
import type { JobPosting } from "@/types";

export default function JobDetailPage() {
  const { token, account, loading: authLoading } = useAuth();
  const { id } = useParams<{ id: string }>();
  // Wait for the stored token to hydrate before fetching: a draft is only
  // visible to the owning company, so firing the request while token is still
  // null would 404 the company's own posting.
  const { data, error, loading } = useApi<{ job_posting: JobPosting }>(
    `/job_postings/${id}`,
    token,
    !authLoading
  );

  const job = data?.job_posting;
  const isOwner =
    account?.role === "company" && account.profile.id === job?.company.id;

  const backLink = (
    <Link
      href={isOwner ? "/company/jobs" : "/jobs"}
      className="text-sm text-muted hover:text-ai-700"
    >
      ← {isOwner ? "募集管理" : "募集一覧"}
    </Link>
  );

  if (loading || authLoading) {
    return (
      <div>
        {backLink}
        <div className="mt-4">
          <LoadingState />
        </div>
      </div>
    );
  }

  if (error || !job) {
    return (
      <div>
        {backLink}
        <div className="mt-4">
          <ErrorState message={error ?? "募集が見つかりませんでした。"} />
        </div>
      </div>
    );
  }

  return (
    <div>
      {backLink}

      <div className="mt-4 flex flex-wrap items-start justify-between gap-4">
        <div>
          <div className="flex items-center gap-3">
            <h1 className="text-2xl font-semibold tracking-tight">{job.title}</h1>
            {isOwner && <StatusChip status={job.status} />}
          </div>
          <p className="mt-1 text-sm text-muted">
            {[job.company.name, job.location, job.employment_type]
              .filter(Boolean)
              .join(" / ")}
          </p>
        </div>
        {isOwner && (
          <Link href={`/company/jobs/${job.id}/edit`} className="btn-primary">
            編集
          </Link>
        )}
      </div>

      <dl className="card mt-6 divide-y divide-line p-6">
        <div className="grid gap-1 py-3 first:pt-0 sm:grid-cols-[8rem_1fr]">
          <dt className="text-sm text-muted">仕事内容</dt>
          <dd className="whitespace-pre-wrap text-ink">{job.description || "未登録"}</dd>
        </div>
        <div className="grid gap-1 py-3 sm:grid-cols-[8rem_1fr]">
          <dt className="text-sm text-muted">応募要件</dt>
          <dd className="whitespace-pre-wrap text-ink">{job.requirements || "未登録"}</dd>
        </div>
        <div className="grid gap-1 py-3 sm:grid-cols-[8rem_1fr]">
          <dt className="text-sm text-muted">勤務地</dt>
          <dd className="text-ink">{job.location || "未登録"}</dd>
        </div>
        <div className="grid gap-1 py-3 last:pb-0 sm:grid-cols-[8rem_1fr]">
          <dt className="text-sm text-muted">雇用形態</dt>
          <dd className="text-ink">{job.employment_type || "未登録"}</dd>
        </div>
      </dl>
    </div>
  );
}
