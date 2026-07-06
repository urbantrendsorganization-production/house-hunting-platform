import type { MetadataRoute } from "next";
import { fetchEstates } from "@/lib/api";

const SITE = process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000";

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  let estateUrls: MetadataRoute.Sitemap = [];
  try {
    const estates = await fetchEstates();
    estateUrls = estates.map((e) => ({
      url: `${SITE}/vacant-houses/${e.slug}`,
      changeFrequency: "daily",
      priority: 0.8,
    }));
  } catch {
    // Sitemap should still build if the API is unreachable at build time.
  }
  return [
    { url: SITE, changeFrequency: "daily", priority: 1 },
    { url: `${SITE}/map`, changeFrequency: "daily", priority: 0.7 },
    ...estateUrls,
  ];
}
