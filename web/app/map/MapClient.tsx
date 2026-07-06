"use client";

import { useEffect, useRef, useState } from "react";
import { fetchViewport } from "@/lib/api";
import type { BuildingMarker } from "@/lib/types";

const MAPS_KEY = process.env.NEXT_PUBLIC_GOOGLE_MAPS_KEY;
// Nairobi.
const CENTER = { lat: -1.2185, lng: 36.8964 };

declare global {
  interface Window {
    google?: typeof google;
    __kejaMapInit?: () => void;
  }
}

function loadGoogleMaps(): Promise<void> {
  return new Promise((resolve, reject) => {
    if (window.google?.maps) return resolve();
    const existing = document.getElementById("gmaps");
    if (existing) {
      existing.addEventListener("load", () => resolve());
      return;
    }
    const s = document.createElement("script");
    s.id = "gmaps";
    s.src = `https://maps.googleapis.com/maps/api/js?key=${MAPS_KEY}&loading=async`;
    s.async = true;
    s.onload = () => resolve();
    s.onerror = () => reject(new Error("Google Maps failed to load"));
    document.head.appendChild(s);
  });
}

export function MapClient() {
  const ref = useRef<HTMLDivElement>(null);
  const [fallback, setFallback] = useState<BuildingMarker[] | null>(null);

  useEffect(() => {
    // No key configured → degrade to a server-data list so the page still works.
    if (!MAPS_KEY) {
      fetchViewport(
        { w: 36.7, s: -1.35, e: 36.95, n: -1.15 },
        16,
      )
        .then((r) => setFallback(r.markers ?? []))
        .catch(() => setFallback([]));
      return;
    }

    let map: google.maps.Map | null = null;
    let markers: google.maps.Marker[] = [];

    const refresh = async () => {
      if (!map) return;
      const b = map.getBounds();
      if (!b) return;
      const ne = b.getNorthEast();
      const sw = b.getSouthWest();
      const zoom = map.getZoom() ?? 15;
      const data = await fetchViewport(
        { w: sw.lng(), s: sw.lat(), e: ne.lng(), n: ne.lat() },
        zoom,
      );
      markers.forEach((m) => m.setMap(null));
      markers = [];
      if (data.mode === "markers") {
        for (const mk of data.markers ?? []) {
          markers.push(
            new google.maps.Marker({
              position: { lat: mk.lat, lng: mk.lng },
              map,
              title: mk.name,
            }),
          );
        }
      } else {
        for (const c of data.clusters ?? []) {
          markers.push(
            new google.maps.Marker({
              position: { lat: c.lat, lng: c.lng },
              map,
              label: String(c.count),
            }),
          );
        }
      }
    };

    loadGoogleMaps()
      .then(() => {
        if (!ref.current) return;
        map = new google.maps.Map(ref.current, { center: CENTER, zoom: 14 });
        let t: ReturnType<typeof setTimeout>;
        map.addListener("idle", () => {
          clearTimeout(t);
          t = setTimeout(refresh, 300); // debounce refetch on pan/zoom
        });
      })
      .catch(() => setFallback([]));
  }, []);

  if (!MAPS_KEY || fallback) {
    return (
      <div className="notice">
        <strong>Map preview</strong> — set{" "}
        <code>NEXT_PUBLIC_GOOGLE_MAPS_KEY</code> to render the interactive map.
        {fallback && (
          <ul>
            {fallback.slice(0, 20).map((m) => (
              <li key={m.id}>
                {m.name} ({m.lat.toFixed(4)}, {m.lng.toFixed(4)})
              </li>
            ))}
          </ul>
        )}
      </div>
    );
  }

  return <div className="map-shell" ref={ref} />;
}
