import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { fetchEstate, fetchEstates } from "@/lib/api";
import { BuildingCard } from "@/components/BuildingCard";

export const revalidate = 60;

// Pre-render an SSG page per estate; ISR keeps them fresh (60s) afterwards.
export async function generateStaticParams() {
  const estates = await fetchEstates();
  return estates.map((e) => ({ estate: e.slug }));
}

type Params = { params: Promise<{ estate: string }> };

export async function generateMetadata({ params }: Params): Promise<Metadata> {
  const { estate: slug } = await params;
  const data = await fetchEstate(slug);
  if (!data) return { title: "Estate not found" };
  const name = data.estate.name;
  const count = data.estate.active_building_count;
  return {
    title: `Vacant houses in ${name}`,
    description: `${count} verified vacant buildings in ${name}, Nairobi. Live vacancy with a 'verified X days ago' badge on every listing.`,
    alternates: { canonical: `/vacant-houses/${slug}` },
  };
}

export default async function EstatePage({ params }: Params) {
  const { estate: slug } = await params;
  const data = await fetchEstate(slug);
  if (!data) notFound();

  const { estate, buildings } = data;

  // ItemList structured data so search engines index the listings.
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: `Vacant houses in ${estate.name}`,
    numberOfItems: buildings.length,
    itemListElement: buildings.map((b, i) => ({
      "@type": "ListItem",
      position: i + 1,
      name: b.name || "Building",
      url: `/building/${b.id}`,
    })),
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <h1>Vacant houses in {estate.name}</h1>
      <p className="lede">
        {buildings.length} verified vacant{" "}
        {buildings.length === 1 ? "building" : "buildings"}, freshest first.
      </p>

      {buildings.length === 0 ? (
        <div className="notice">
          No verified vacancies in {estate.name} right now. Listings appear here
          the moment an agent verifies a vacancy — and disappear when they go
          stale.
        </div>
      ) : (
        <div className="grid">
          {buildings.map((b) => (
            <BuildingCard key={b.id} building={b} />
          ))}
        </div>
      )}
    </>
  );
}
