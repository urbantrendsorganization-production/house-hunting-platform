export interface EstateSummary {
  name: string;
  slug: string;
  lng: number;
  lat: number;
  active_building_count: number;
}

export interface UnitType {
  id: number;
  kind: string;
  kind_display: string;
  rent_kes: number;
  deposit_kes: number | null;
  amenities: Record<string, unknown>;
}

export interface BuildingMarker {
  id: string;
  name: string;
  estate: string;
  lng: number;
  lat: number;
  verified_days_ago: number | null;
  is_demoted: boolean;
}

export interface BuildingListItem extends BuildingMarker {
  min_rent_kes: number | null;
  unit_kinds: string[];
}

export interface BuildingDetail extends BuildingMarker {
  floors: number | null;
  parking: boolean;
  water_notes: string;
  power_notes: string;
  security_notes: string;
  caretaker_name: string;
  unit_types: UnitType[];
}

export interface EstateDetail {
  estate: EstateSummary;
  buildings: BuildingListItem[];
}

export interface ViewportResponse {
  mode: "markers" | "clusters";
  count: number;
  markers?: BuildingMarker[];
  clusters?: { lng: number; lat: number; count: number }[];
  capped?: boolean;
}
