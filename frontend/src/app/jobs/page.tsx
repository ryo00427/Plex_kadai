"use client";

import { useApi } from "@/lib/hooks";
import { PageHeader, LoadingState, EmptyState } from "@/components/PageState";
import type { JobPosting } from "@/types";

export default function JobsPage() {
  const { data, loading } = useApi<{ job_postings: JobPosting[] }>("/job_postings", null);

  const jobs = data?.job_postings ?? [];

  return (
    <div>
      <PageHeader title="募集一覧" />

      {loading ? (
        <LoadingState />
      ) : jobs.length === 0 ? (
        <EmptyState message="公開中の募集はまだありません。" />
      ) : (
        <ul className="space-y-3">
          {jobs.map((job) => (
            <li key={job.id} className="card p-5">
              <p className="font-medium text-ai-900">{job.title}</p>
              <p className="mt-1 text-sm text-muted">
                {job.company.name} / {job.location} / {job.employment_type}
              </p>
              {job.description && (
                <p className="mt-3 text-sm text-ink">{job.description}</p>
              )}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
