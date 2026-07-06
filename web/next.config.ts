import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  reactStrictMode: true,
  // The API base is read at request time so the same build runs against any env.
  env: {},
};

export default nextConfig;
