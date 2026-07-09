"use client";

import { useState } from "react";
import { revealContact } from "@/lib/api";

export function ContactReveal({
  buildingId,
  caretakerName,
}: {
  buildingId: string;
  caretakerName: string;
}) {
  const [phone, setPhone] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(false);

  async function reveal() {
    setLoading(true);
    setError(false);
    try {
      const data = await revealContact(buildingId);
      setPhone(data.caretaker_phone || "Not on file");
    } catch {
      setError(true);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="notice">
      <div>Caretaker: {caretakerName || "—"}</div>
      {phone ? (
        <div className="price">
          <a href={`tel:${phone}`}>{phone}</a>
        </div>
      ) : (
        <button className="btn" onClick={reveal} disabled={loading}>
          {loading ? "Revealing…" : "Show caretaker contact"}
        </button>
      )}
      {error && <div className="meta">Could not load contact. Try again.</div>}
    </div>
  );
}
