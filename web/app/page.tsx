import Link from "next/link";
import { fetchEstates } from "@/lib/api";

export const revalidate = 60;

export default async function HomePage() {
  const estates = await fetchEstates();
  const total = estates.reduce((sum, e) => sum + e.active_building_count, 0);

  return (
    <>
      <h1>Verified vacant houses in Kenya</h1>
      <p className="lede">
        {total} vacant {total === 1 ? "unit" : "units"} verified across{" "}
        {estates.length} estates. Every listing shows how recently we checked.
      </p>

      <Link href="/map" className="btn">
        Open the map →
      </Link>

      <h2 style={{ marginTop: 32 }}>Browse by estate</h2>
      <div className="grid">
        {estates.map((estate) => (
          <Link
            key={estate.slug}
            href={`/vacant-houses/${estate.slug}`}
            className="card"
          >
            <h3>{estate.name}</h3>
            <div className="meta">
              {estate.active_building_count} vacant{" "}
              {estate.active_building_count === 1 ? "building" : "buildings"}
            </div>
          </Link>
        ))}
      </div>
    </>
  );
}
