import { NextResponse } from "next/server";
import { SERVER_BASE } from "@/lib/api";

// Same-origin proxy for the contact reveal. The browser POSTs here (no CORS),
// and we forward to Django server-side over the trusted API base. Keeps the
// Lead-writing call off the public cross-origin surface.
export async function POST(
  request: Request,
  { params }: { params: Promise<{ id: string }> },
) {
  const { id } = await params;
  const body = await request.text();

  const res = await fetch(`${SERVER_BASE}/buildings/${id}/contact/`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: body || "{}",
    cache: "no-store",
  });

  const data = await res.json().catch(() => ({}));
  return NextResponse.json(data, { status: res.status });
}
