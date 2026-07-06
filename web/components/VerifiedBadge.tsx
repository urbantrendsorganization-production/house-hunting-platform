import { freshnessTone, verifiedLabel } from "@/lib/format";

export function VerifiedBadge({ days }: { days: number | null }) {
  const tone = freshnessTone(days);
  return <span className={`badge ${tone}`}>{verifiedLabel(days)}</span>;
}
