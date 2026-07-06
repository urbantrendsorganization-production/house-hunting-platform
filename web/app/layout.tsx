import type { Metadata } from "next";
import Link from "next/link";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "Keja — verified vacant houses in Kenya",
    template: "%s · Keja",
  },
  description:
    "Find verified vacant houses near you in Kenya. Real gate-level pins, live vacancy, and a 'verified X days ago' freshness badge on every listing.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <header className="header">
          <div className="container">
            <Link href="/" className="logo">
              Keja
            </Link>
            <nav className="nav">
              <Link href="/map">Map</Link>
            </nav>
          </div>
        </header>
        <main className="container">{children}</main>
      </body>
    </html>
  );
}
