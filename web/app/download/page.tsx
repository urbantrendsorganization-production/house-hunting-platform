import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Download the Keja apps",
  description:
    "Get the Keja consumer app to search verified vacant houses in Kenya, or the Keja Agent app for field agents to capture and upload vacant units.",
};

// Distribution links are env-driven so the page can ship before the artifacts
// exist. Consumer app → Google Play (public). Agent app → direct APK (an
// internal, device-bound field tool; not a Play Store listing).
const PLAY_STORE_URL = process.env.NEXT_PUBLIC_PLAY_STORE_URL ?? "";
const CONSUMER_APK_URL = process.env.NEXT_PUBLIC_CONSUMER_APK_URL ?? "";
const AGENT_APK_URL = process.env.NEXT_PUBLIC_AGENT_APK_URL ?? "";

export default function DownloadPage() {
  return (
    <>
      <h1>Get Keja</h1>
      <p className="lede">
        Two apps power Keja: one for people searching for a house, one for the
        field agents who verify vacant units on the ground.
      </p>

      <div className="grid">
        {/* Consumer app — public, Google Play */}
        <div className="card">
          <span className="badge">For house hunters</span>
          <h3 style={{ marginTop: 12 }}>Keja</h3>
          <p className="meta">
            Open the map, see verified vacant houses around you, and check how
            recently each one was confirmed. Free on Google Play.
          </p>

          {PLAY_STORE_URL ? (
            <a className="btn" href={PLAY_STORE_URL}>
              Get it on Google Play →
            </a>
          ) : (
            <p className="notice" style={{ marginTop: 12 }}>
              Coming soon to Google Play. Set{" "}
              <code>NEXT_PUBLIC_PLAY_STORE_URL</code> once the listing is live.
            </p>
          )}

          {CONSUMER_APK_URL && (
            <p style={{ marginTop: 12 }}>
              <a href={CONSUMER_APK_URL}>Or download the APK directly</a> (early
              access, before Play Store approval).
            </p>
          )}
        </div>

        {/* Agent app — internal, direct APK */}
        <div className="card">
          <span className="badge">For field agents</span>
          <h3 style={{ marginTop: 12 }}>Keja Agent</h3>
          <p className="meta">
            Stand at a building gate, pin its exact location, record vacant units
            per type, and sync — even offline. For authorised agents only; your
            device is bound to your account on first sign-in.
          </p>

          {AGENT_APK_URL ? (
            <a className="btn" href={AGENT_APK_URL}>
              Download Keja Agent (.apk) →
            </a>
          ) : (
            <p className="notice" style={{ marginTop: 12 }}>
              Download not published yet. Host the signed agent APK (GitHub
              Release or object storage) and set{" "}
              <code>NEXT_PUBLIC_AGENT_APK_URL</code>.
            </p>
          )}

          <p className="meta" style={{ marginTop: 12 }}>
            The agent app is distributed directly, not via Google Play — it is an
            internal capture tool, not a public listing.
          </p>
        </div>
      </div>

      <div className="notice" style={{ marginTop: 24 }}>
        <strong>Installing the agent APK:</strong> on the agent’s phone, enable
        “Install unknown apps” for the browser, open the download link, then tap
        the downloaded file. Sign in with the phone number registered for that
        agent.
      </div>
    </>
  );
}
