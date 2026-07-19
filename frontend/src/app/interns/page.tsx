"use client";

import Link from "next/link";
import { useAuth } from "@/lib/auth";
import { useApi } from "@/lib/hooks";
import { GradYearBadge } from "@/components/GradYearBadge";
import {
  PageHeader,
  LoadingState,
  ErrorState,
  EmptyState,
} from "@/components/PageState";
import type { Intern } from "@/types";

export default function InternsPage() {
  const { token } = useAuth();
  const { data, loading, error } = useApi<{ interns: Intern[] }>(
    "/interns",
    token,
    !!token,
  );

  const interns = data?.interns ?? [];

  return (
    <div>
      <PageHeader
        title="インターン生を探す"
        description={
          loading || error
            ? undefined
            : `${interns.length}名が登録しています`
        }
      />

      {loading ? (
        <LoadingState />
      ) : error ? (
        <ErrorState message={error} />
      ) : interns.length === 0 ? (
        <EmptyState message="まだ登録しているインターン生がいません。" />
      ) : (
        <ul className="grid gap-3 sm:grid-cols-2">
          {interns.map((intern) => (
            <li key={intern.id}>
              <Link
                href={`/interns/${intern.id}`}
                className="card flex h-full gap-4 p-5 transition-shadow hover:shadow-lift"
              >
                <GradYearBadge year={intern.graduation_year} />
                <div className="min-w-0">
                  <p className="font-medium text-ai-900">{intern.name}</p>
                  <p className="mt-0.5 truncate text-sm text-muted">
                    {[intern.university, intern.major]
                      .filter(Boolean)
                      .join(" / ") || "所属未登録"}
                  </p>
                  {intern.skills && (
                    <p className="mt-2 font-mono text-xs text-ai-500">
                      {intern.skills}
                    </p>
                  )}
                </div>
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
