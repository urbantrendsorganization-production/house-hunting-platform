export function formatKes(value: number | null): string {
  if (value == null) return "—";
  return "KES " + value.toLocaleString("en-KE");
}

export function verifiedLabel(days: number | null): string {
  if (days == null) return "Not yet verified";
  if (days === 0) return "Verified today";
  if (days === 1) return "Verified yesterday";
  return `Verified ${days} days ago`;
}

// Freshness rules mirror the API: >14d demoted, >30d hidden (won't appear here).
export function freshnessTone(days: number | null): "fresh" | "aging" | "stale" {
  if (days == null || days > 14) return "stale";
  if (days > 7) return "aging";
  return "fresh";
}
