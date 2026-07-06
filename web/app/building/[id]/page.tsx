import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { fetchBuilding } from "@/lib/api";
import { formatKes, verifiedLabel } from "@/lib/format";
import { VerifiedBadge } from "@/components/VerifiedBadge";

export const revalidate = 60;

type Params = { params: Promise<{ id: string }> };

export async function generateMetadata({ params }: Params): Promise<Metadata> {
  const { id } = await params;
  const b = await fetchBuilding(id);
  if (!b) return { title: "Building not found" };
  return {
    title: `${b.name || "Vacant building"} in ${b.estate}`,
    description: `${b.name || "Building"} in ${b.estate}. ${verifiedLabel(
      b.verified_days_ago,
    )}.`,
  };
}

export default async function BuildingPage({ params }: Params) {
  const { id } = await params;
  const b = await fetchBuilding(id);
  if (!b) notFound();

  const mapsHref = `https://www.google.com/maps/dir/?api=1&destination=${b.lat},${b.lng}`;

  return (
    <>
      <div style={{ marginBottom: 8 }}>
        <Link href={`/vacant-houses/${b.estate.toLowerCase()}`} className="meta">
          ← {b.estate}
        </Link>
      </div>
      <h1>{b.name || "Vacant building"}</h1>
      <div style={{ margin: "6px 0 16px" }}>
        <VerifiedBadge days={b.verified_days_ago} />
      </div>

      <h2>Available units</h2>
      <div className="grid">
        {b.unit_types.map((u) => (
          <div key={u.id} className="card">
            <h3>{u.kind_display}</h3>
            <div className="price">{formatKes(u.rent_kes)}/mo</div>
            {u.deposit_kes != null && (
              <div className="meta">Deposit {formatKes(u.deposit_kes)}</div>
            )}
          </div>
        ))}
      </div>

      <h2 style={{ marginTop: 24 }}>About</h2>
      <div className="notice">
        <div>Floors: {b.floors ?? "—"}</div>
        <div>Parking: {b.parking ? "Yes" : "No"}</div>
        {b.water_notes && <div>Water: {b.water_notes}</div>}
        {b.power_notes && <div>Power: {b.power_notes}</div>}
        {b.security_notes && <div>Security: {b.security_notes}</div>}
      </div>

      <a className="btn" href={mapsHref} target="_blank" rel="noopener noreferrer">
        Directions on Google Maps →
      </a>
    </>
  );
}
