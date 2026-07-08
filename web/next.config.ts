import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  reactStrictMode: true,
  // Emit a self-contained server bundle (.next/standalone) so the prod Docker
  // image ships only the files it needs — no full node_modules, no source.
  output: "standalone",
  // The API base is read at request time so the same build runs against any env.
  env: {},
};

export default nextConfig;
