import Link from "next/link";

/** Shared page chrome so every screen has the same heading rhythm. */
export function PageHeader({
  title,
  description,
  action,
}: {
  title: string;
  description?: string;
  action?: React.ReactNode;
}) {
  return (
    <div className="mb-6 flex flex-wrap items-start justify-between gap-4">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">{title}</h1>
        {description && <p className="mt-1 text-sm text-muted">{description}</p>}
      </div>
      {action}
    </div>
  );
}

export function LoadingState({ label = "読み込んでいます" }: { label?: string }) {
  return (
    <div className="card p-8 text-center text-sm text-muted" role="status">
      {label}
    </div>
  );
}

export function ErrorState({ message }: { message: string }) {
  return (
    <div
      className="rounded-lg border border-shu-500/30 bg-shu-100 p-4 text-sm text-shu-600"
      role="alert"
    >
      {message}
    </div>
  );
}

/** An empty screen should tell the user what to do next, not just say "no data". */
export function EmptyState({
  message,
  actionHref,
  actionLabel,
}: {
  message: string;
  actionHref?: string;
  actionLabel?: string;
}) {
  return (
    <div className="card p-10 text-center">
      <p className="text-sm text-muted">{message}</p>
      {actionHref && actionLabel && (
        <Link href={actionHref} className="btn-primary mt-4">
          {actionLabel}
        </Link>
      )}
    </div>
  );
}

/** Draft vs published, used on the company's own job listings. */
export function StatusChip({ status }: { status: "draft" | "published" }) {
  const published = status === "published";
  return (
    <span
      className={`inline-flex items-center rounded px-2 py-0.5 text-xs font-medium ${
        published ? "bg-wakaba-100 text-wakaba-600" : "bg-shu-100 text-shu-600"
      }`}
    >
      {published ? "公開中" : "下書き"}
    </span>
  );
}
