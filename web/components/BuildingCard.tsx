import Link from "next/link";
import type { BuildingListItem } from "@/lib/types";
import { formatKes } from "@/lib/format";
import { VerifiedBadge } from "./VerifiedBadge";

export function BuildingCard({ building }: { building: BuildingListItem }) {
  return (
    <Link href={`/building/${building.id}`} className="card">
      <h3>{building.name || "Unnamed building"}</h3>
      <div className="meta">{building.estate}</div>
      <div className="price">from {formatKes(building.min_rent_kes)}/mo</div>
      <div className="chips">
        {building.unit_kinds.map((kind) => (
          <span key={kind} className="chip">
            {kind}
          </span>
        ))}
      </div>
      <div style={{ marginTop: 10 }}>
        <VerifiedBadge days={building.verified_days_ago} />
      </div>
    </Link>
  );
}
