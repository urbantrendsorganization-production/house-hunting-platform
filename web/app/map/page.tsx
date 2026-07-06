import type { Metadata } from "next";
import { MapClient } from "./MapClient";

export const metadata: Metadata = {
  title: "Map — vacant houses near you",
  description: "Explore verified vacant houses across Nairobi on the live map.",
};

export default function MapPage() {
  return (
    <>
      <h1>Vacant houses near you</h1>
      <p className="lede">
        Pan and zoom — markers cluster server-side, and only listings verified
        within the last 30 days appear.
      </p>
      <MapClient />
    </>
  );
}
