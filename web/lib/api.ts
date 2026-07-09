import type {
  BuildingDetail,
  ContactReveal,
  EstateDetail,
  EstateSummary,
  ViewportResponse,
} from "./types";

// Server-side calls reach Django directly; the browser uses the public base.
export const SERVER_BASE = process.env.API_BASE ?? "http://localhost:8000/api/v1";
export const PUBLIC_BASE =
  process.env.NEXT_PUBLIC_API_BASE ?? "http://localhost:8000/api/v1";

async function getJSON<T>(url: string, revalidate: number): Promise<T> {
  const res = await fetch(url, { next: { revalidate } });
  if (!res.ok) {
    throw new Error(`API ${res.status} for ${url}`);
  }
  return (await res.json()) as T;
}

// Revalidate every 60s so SSR pages stay in step with the freshness engine.
export async function fetchEstates(): Promise<EstateSummary[]> {
  const data = await getJSON<{ results: EstateSummary[] }>(
    `${SERVER_BASE}/estates/`,
    60,
  );
  return data.results;
}

export async function fetchEstate(slug: string): Promise<EstateDetail | null> {
  const res = await fetch(`${SERVER_BASE}/estates/${slug}/`, {
    next: { revalidate: 60 },
  });
  if (res.status === 404) return null;
  if (!res.ok) throw new Error(`API ${res.status} for estate ${slug}`);
  return (await res.json()) as EstateDetail;
}

export async function fetchBuilding(id: string): Promise<BuildingDetail | null> {
  const res = await fetch(`${SERVER_BASE}/buildings/${id}/`, {
    next: { revalidate: 60 },
  });
  if (res.status === 404) return null;
  if (!res.ok) throw new Error(`API ${res.status} for building ${id}`);
  return (await res.json()) as BuildingDetail;
}

// Reveal the caretaker contact — records a Lead. Routed through our own
// same-origin route handler (app/api/buildings/[id]/contact) which forwards to
// Django server-side, so the browser never makes a cross-origin write (no CORS
// preflight) and the Lead-writing call stays server-side for the future auth gate.
export async function revealContact(
  id: string,
  unitTypeId?: number,
): Promise<ContactReveal> {
  const res = await fetch(`/api/buildings/${id}/contact/`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(unitTypeId ? { unit_type: unitTypeId } : {}),
  });
  if (!res.ok) throw new Error(`contact ${res.status}`);
  return (await res.json()) as ContactReveal;
}

export async function fetchViewport(
  bbox: { w: number; s: number; e: number; n: number },
  zoom: number,
): Promise<ViewportResponse> {
  const q = new URLSearchParams({
    w: String(bbox.w),
    s: String(bbox.s),
    e: String(bbox.e),
    n: String(bbox.n),
    zoom: String(zoom),
  });
  const res = await fetch(`${PUBLIC_BASE}/map/viewport/?${q}`);
  if (!res.ok) throw new Error(`viewport ${res.status}`);
  return (await res.json()) as ViewportResponse;
}
