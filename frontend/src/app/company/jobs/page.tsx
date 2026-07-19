"use client";

import Link from "next/link";
import { useAuth } from "@/lib/auth";
import { useApi } from "@/lib/hooks";
import {
  PageHeader,
  LoadingState,
  EmptyState,
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

  const jobs = data?.job_postings ?? [];

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
              <div className="flex items-center gap-3">
                <p className="font-medium text-ai-900">{job.title}</p>
                <StatusChip status={job.status} />
              </div>
              <p className="mt-1 text-sm text-muted">
                {job.location} / {job.employment_type}
              </p>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
