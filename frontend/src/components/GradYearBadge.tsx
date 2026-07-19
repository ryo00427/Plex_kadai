/**
 * Graduation-year badge, e.g. 27卒.
 *
 * "27卒" is how Japanese new-grad recruiting actually refers to a cohort, and
 * it is the first thing a recruiter scans a candidate list for — so it is set
 * as a structural element (mono, oversized numerals) rather than body text.
 */
export function GradYearBadge({
  year,
  size = "md",
}: {
  year?: number | null;
  size?: "sm" | "md";
}) {
  if (!year) return null;

  const shortYear = String(year).slice(-2);
  const isSmall = size === "sm";

  return (
    <span
      className={`inline-flex shrink-0 items-baseline rounded bg-ai-100 text-ai-700 ${
        isSmall ? "px-1.5 py-0.5" : "px-2 py-1"
      }`}
      title={`${year}年卒業予定`}
    >
      <span
        className={`font-mono font-semibold tabular-nums leading-none ${
          isSmall ? "text-sm" : "text-lg"
        }`}
      >
        {shortYear}
      </span>
      <span className={`ml-0.5 leading-none ${isSmall ? "text-[10px]" : "text-xs"}`}>
        卒
      </span>
    </span>
  );
}
