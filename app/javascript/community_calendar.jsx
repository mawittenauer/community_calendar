import React, { useEffect, useMemo, useState } from "react";
import { createRoot } from "react-dom/client";

import { useCalendarApp, ScheduleXCalendar } from "@schedule-x/react";
import {
  createViewDay,
  createViewWeek,
  createViewMonthGrid,
  createViewMonthAgenda,
} from "@schedule-x/calendar";

import { createEventsServicePlugin } from "@schedule-x/events-service";

import "temporal-polyfill/global";
import "@schedule-x/theme-default/dist/index.css";

/**
 * Rails API endpoints (from our earlier backend spec):
 *  - GET /api/v1/categories
 *  - GET /api/v1/tags
 *  - GET /api/v1/events?start=...&end=...&calendarIds=...&tagIds=...&status=...&q=...
 */

const API_BASE = "/api/v1";
const DEFAULT_TZ = "America/New_York"; // adjust if you want; can also be dynamic later

// A small, repeatable palette so categories get consistent-ish colors.
// Schedule-X requires a calendars config with a colorName + colors. :contentReference[oaicite:3]{index=3}
const COLOR_PALETTE = [
  {
    lightColors: { main: "#1c7df9", container: "#d2e7ff", onContainer: "#002859" },
    darkColors: { main: "#c0dfff", onContainer: "#dee6ff", container: "#426aa2" },
  },
  {
    lightColors: { main: "#f91c45", container: "#ffd2dc", onContainer: "#59000d" },
    darkColors: { main: "#ffc0cc", onContainer: "#ffdee6", container: "#a24258" },
  },
  {
    lightColors: { main: "#1cf9b0", container: "#dafff0", onContainer: "#004d3d" },
    darkColors: { main: "#c0fff5", onContainer: "#e6fff5", container: "#42a297" },
  },
  {
    lightColors: { main: "#f9d71c", container: "#fff5aa", onContainer: "#594800" },
    darkColors: { main: "#fff5c0", onContainer: "#fff5de", container: "#a29742" },
  },
];

// Convert Rails API event times (ISO strings with offset) to Temporal.ZonedDateTime.
// Schedule-X expects Temporal.PlainDate or Temporal.ZonedDateTime. :contentReference[oaicite:4]{index=4}
function toTemporalZdt(isoString, tz = DEFAULT_TZ) {
  // If already has [Zone], use it directly
  if (isoString.includes("[")) return Temporal.ZonedDateTime.from(isoString);

  // Append zone if missing; Rails returns ISO offset like 2026-02-01T10:00:00-05:00
  return Temporal.ZonedDateTime.from(`${isoString}[${tz}]`);
}

function buildQuery(params) {
  const parts = [];
  Object.entries(params).forEach(([k, v]) => {
    if (v === undefined || v === null) return;
    if (Array.isArray(v)) {
      if (v.length === 0) return;
      parts.push(`${encodeURIComponent(k)}=${encodeURIComponent(v.join(","))}`);
      return;
    }
    if (typeof v === "string" && v.trim() === "") return;
    // Don't URL-encode date strings (start/end) to preserve colons
    const encodedValue = (k === 'start' || k === 'end') ? v : encodeURIComponent(String(v));
    parts.push(`${encodeURIComponent(k)}=${encodedValue}`);
  });
  return parts.join("&");
}

async function fetchJson(path) {
  const res = await fetch(path, { headers: { Accept: "application/json" } });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`Request failed (${res.status}): ${text || path}`);
  }
  return res.json();
}

function FiltersBar({
  categories,
  tags,
  selectedCalendarIds,
  setSelectedCalendarIds,
  selectedTagIds,
  setSelectedTagIds,
  status,
  setStatus,
  q,
  setQ,
  onApply,
}) {
  return (
    <div style={{ display: "grid", gap: 12, marginBottom: 12 }}>
      <div style={{ display: "flex", gap: 12, flexWrap: "wrap", alignItems: "flex-end" }}>
        <div style={{ minWidth: 240 }}>
          <label style={{ display: "block", fontSize: 12, marginBottom: 4 }}>Category</label>
          <select
            multiple
            value={selectedCalendarIds}
            onChange={(e) => {
              const values = Array.from(e.target.selectedOptions).map((o) => o.value);
              setSelectedCalendarIds(values);
            }}
            style={{ width: "100%", minHeight: 96 }}
          >
            {categories.map((c) => (
              <option key={c.slug} value={c.slug}>
                {c.name}
              </option>
            ))}
          </select>
          <div style={{ fontSize: 12, opacity: 0.7, marginTop: 4 }}>
            Tip: hold ⌘/Ctrl to multi-select
          </div>
        </div>

        <div style={{ minWidth: 240 }}>
          <label style={{ display: "block", fontSize: 12, marginBottom: 4 }}>Tags</label>
          <select
            multiple
            value={selectedTagIds}
            onChange={(e) => {
              const values = Array.from(e.target.selectedOptions).map((o) => o.value);
              setSelectedTagIds(values);
            }}
            style={{ width: "100%", minHeight: 96 }}
          >
            {tags.map((t) => (
              <option key={t.slug} value={t.slug}>
                {t.name}
              </option>
            ))}
          </select>
        </div>

        <div style={{ minWidth: 160 }}>
          <label style={{ display: "block", fontSize: 12, marginBottom: 4 }}>Status</label>
          <select value={status} onChange={(e) => setStatus(e.target.value)} style={{ width: "100%" }}>
            <option value="">All</option>
            <option value="scheduled">Scheduled</option>
            <option value="canceled">Canceled</option>
            <option value="postponed">Postponed</option>
          </select>
        </div>

        <div style={{ flex: 1, minWidth: 220 }}>
          <label style={{ display: "block", fontSize: 12, marginBottom: 4 }}>Search</label>
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="title/description…"
            style={{ width: "100%" }}
          />
        </div>

        <button onClick={onApply} style={{ padding: "8px 12px" }}>
          Apply filters
        </button>
      </div>
    </div>
  );
}

function ScheduleXWithData() {
  // Lookup data
  const [categories, setCategories] = useState([]);
  const [tags, setTags] = useState([]);

  // Filter state (maps directly to your Rails API query params)
  const [selectedCalendarIds, setSelectedCalendarIds] = useState([]); // category slugs => calendarIds
  const [selectedTagIds, setSelectedTagIds] = useState([]); // tag slugs => tagIds
  const [status, setStatus] = useState("");
  const [q, setQ] = useState("");

  // Keep track of the current visible range so we can re-fetch when filters change.
  const [currentRange, setCurrentRange] = useState(null);

  // Schedule-X event service plugin (lets us call set(events)). :contentReference[oaicite:5]{index=5}
  const [eventsService] = useState(() => createEventsServicePlugin());

  // Load categories/tags once
  useEffect(() => {
    (async () => {
      const [catData, tagData] = await Promise.all([
        fetchJson(`${API_BASE}/categories`),
        fetchJson(`${API_BASE}/tags`),
      ]);
      setCategories(catData.categories || []);
      setTags(tagData.tags || []);
    })().catch((err) => {
      // eslint-disable-next-line no-console
      console.error(err);
      alert(`Failed to load categories/tags: ${err.message}`);
    });
  }, []);

  // Build Schedule-X calendars config from categories.
  // Each key must match event.calendarId (we use Category.slug). :contentReference[oaicite:6]{index=6}
  const calendarsConfig = useMemo(() => {
    const cfg = {};
    categories.forEach((c, idx) => {
      const palette = COLOR_PALETTE[idx % COLOR_PALETTE.length];
      cfg[c.slug] = {
        colorName: c.slug.replace(/[^a-z]/g, ""), // colorName must be lowercase chars. :contentReference[oaicite:7]{index=7}
        ...palette,
      };
    });
    return cfg;
  }, [categories]);

async function loadEventsForRange(range) {
  const normalized = normalizeRangeForApi(range, DEFAULT_TZ);
  if (!normalized) {
    console.error("No normalized range; refusing to call API", range);
    return;
  }

  const query = buildQuery({
    start: normalized.start,
    end: normalized.end,
    calendarIds: selectedCalendarIds,
    tagIds: selectedTagIds,
    status,
    q,
  });

  console.log("Fetching events with:", normalized, query);

  const data = await fetchJson(`${API_BASE}/events?${query}`);
  const apiEvents = data.events || [];

  const sxEvents = apiEvents.map((e) => ({
    id: e.id,
    calendarId: e.calendarId,
    title: e.title,
    description: e.description,
    location: e.location,
    people: e.people || [],
    start: toTemporalZdt(e.start, DEFAULT_TZ),
    end: toTemporalZdt(e.end, DEFAULT_TZ),
    meta: e.meta,
  }));

  eventsService.set(sxEvents);
}


  // IMPORTANT: we create the calendar app once categories are loaded so calendars config is correct.
  // The React docs show this exact pattern with useCalendarApp + ScheduleXCalendar. :contentReference[oaicite:11]{index=11}
  const calendarApp = useCalendarApp({
    views: [createViewDay(), createViewWeek(), createViewMonthGrid(), createViewMonthAgenda()],
    events: [],
    calendars: calendarsConfig,
    plugins: [eventsService],
    callbacks: {
      // Called when navigating to new day/week/month; ideal for backend fetches. :contentReference[oaicite:12]{index=12}
      onRangeUpdate: (range) => {
        setCurrentRange(range);
        loadEventsForRange(range).catch((err) => {
          // eslint-disable-next-line no-console
          console.error(err);
        });
      },
    },
  });

  // If you change filters, reload using the last known visible range.
  async function applyFilters() {
    if (!currentRange) return;
    await loadEventsForRange(currentRange);
  }

  return (
    <div>
      <FiltersBar
        categories={categories}
        tags={tags}
        selectedCalendarIds={selectedCalendarIds}
        setSelectedCalendarIds={setSelectedCalendarIds}
        selectedTagIds={selectedTagIds}
        setSelectedTagIds={setSelectedTagIds}
        status={status}
        setStatus={setStatus}
        q={q}
        setQ={setQ}
        onApply={applyFilters}
      />

      {/* Schedule-X needs this wrapper to have a defined height/width. :contentReference[oaicite:13]{index=13} */}
      <div className="sx-react-calendar-wrapper">
        <ScheduleXCalendar calendarApp={calendarApp} />
      </div>
    </div>
  );
}

// Mount helper — called by Rails view.
export function mountCommunityCalendar(domId = "community-calendar-root") {
  const el = document.getElementById(domId);
  if (!el) return;

  const root = createRoot(el);
  root.render(<ScheduleXWithData />);
}

function normalizeRangeForApi(range, tz = DEFAULT_TZ) {
  try {
    const toZdtAtMidnight = (v) => {
      if (!v) return null;

      // Case A: Temporal types
      if (v instanceof Temporal.ZonedDateTime) {
        // Use its date portion in the target tz at midnight
        const d = v.withTimeZone(tz).toPlainDate();
        return d.toZonedDateTime({ timeZone: tz, plainTime: Temporal.PlainTime.from("00:00") });
      }
      if (v instanceof Temporal.PlainDate) {
        return v.toZonedDateTime({ timeZone: tz, plainTime: Temporal.PlainTime.from("00:00") });
      }
      if (v instanceof Temporal.Instant) {
        const d = v.toZonedDateTimeISO(tz).toPlainDate();
        return d.toZonedDateTime({ timeZone: tz, plainTime: Temporal.PlainTime.from("00:00") });
      }

      // Case B: {year, month, day}
      if (typeof v === "object" && "year" in v && "month" in v && "day" in v) {
        const d = new Temporal.PlainDate(v.year, v.month, v.day);
        return d.toZonedDateTime({ timeZone: tz, plainTime: Temporal.PlainTime.from("00:00") });
      }

      // Case C: string input
      if (typeof v === "string") {
        const s = v.trim();

        // If it's a pure date: YYYY-MM-DD
        if (/^\d{4}-\d{2}-\d{2}$/.test(s)) {
          const d = Temporal.PlainDate.from(s);
          return d.toZonedDateTime({ timeZone: tz, plainTime: Temporal.PlainTime.from("00:00") });
        }

        // If it contains a bracketed zone like ...[America/New_York], Temporal can parse it:
        if (s.includes("[") && s.includes("]")) {
          const z = Temporal.ZonedDateTime.from(s);
          const d = z.withTimeZone(tz).toPlainDate();
          return d.toZonedDateTime({ timeZone: tz, plainTime: Temporal.PlainTime.from("00:00") });
        }

        // If it's an instant-like string (has Z or offset), parse as Instant
        if (s.endsWith("Z") || /[+-]\d{2}:\d{2}$/.test(s)) {
          const inst = Temporal.Instant.from(s);
          const d = inst.toZonedDateTimeISO(tz).toPlainDate();
          return d.toZonedDateTime({ timeZone: tz, plainTime: Temporal.PlainTime.from("00:00") });
        }

        // Last resort: try ZonedDateTime (some libs emit "2026-02-04T00:00:00")
        const z = Temporal.ZonedDateTime.from(`${s}[${tz}]`);
        const d = z.toPlainDate();
        return d.toZonedDateTime({ timeZone: tz, plainTime: Temporal.PlainTime.from("00:00") });
      }

      // Fallback attempt
      const d = Temporal.PlainDate.from(String(v));
      return d.toZonedDateTime({ timeZone: tz, plainTime: Temporal.PlainTime.from("00:00") });
    };

    const startZdt = toZdtAtMidnight(range.start);
    const endZdt = toZdtAtMidnight(range.end);
    if (!startZdt || !endZdt) return null;

    // IMPORTANT: send ISO8601 in UTC so Rails Time.iso8601 always works
    return {
      start: startZdt.toInstant().toString(), // -> "2026-02-01T05:00:00Z"
      end: endZdt.toInstant().toString(),
    };
  } catch (e) {
    console.error("normalizeRangeForApi failed", e, range);
    return null;
  }
}


