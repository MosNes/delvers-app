# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
npm run dev        # Vite dev server
npm run build      # Production build
npm run preview    # Build + preview via Wrangler (Cloudflare Workers)
npm run deploy     # Build + deploy to Cloudflare Workers
```

No test runner is configured. No lint script is defined.

## Architecture

This is a full-stack SPA for a tabletop RPG companion app (Delvers). It runs as a Cloudflare Worker with a Vue 3 frontend and an Express backend served from the same Worker.

**Frontend** (`src/`): Vue 3 + Vite SPA. The app currently mounts `CharacterSheet.vue` directly for testing — `<RouterView>` is commented out in `App.vue`. The single route (`/`) is defined in `src/router/index.js`.

**Backend** (`server/`): Express.js running inside a Cloudflare Worker via `@cloudflare/vite-plugin`. Entry is `server/index.js`. Routes live under `/api`. The `/api/seed` route is deprecated as the project has moved to Supabase instead of Cloudflare D1.

**Database**: Two database layers co-exist:
- **Cloudflare D1** DEPRECATED. (SQLite) for the Worker backend — seeded via `POST /api/seed/*` endpoints. This has been deprecated in favor of Supabase.
- **Supabase** (PostgreSQL) for client-side persistence and worker backend — configured in `src/lib/supabaseClient.js` using `VITE_SUPABASE_URL` / `VITE_SUPABASE_ANON_KEY` env vars

Schema for both is documented in `schemas/` (JSON) and `postgresSchema.sql`. `postgresSchema.sql` is the primary source for schemas now that the project is using Supabase instead of Cloudflare D1. Seed data lives in `seeds/*.json` and `seeds/seed-dev.js`.

## UI Component System

`src/volt/` is a custom component library wrapping PrimeVue in "unstyled" mode, styled entirely with TailwindCSS via `tailwindcss-primeui`. These components (Button, Card, Panel, Accordion, DataTable, Popover, etc.) are the building blocks for all UI. Use Volt components instead of raw PrimeVue or HTML where equivalents exist.

PrimeVue is configured in `src/main.js` with `Aura` theme preset. TailwindCSS v4 is integrated via `@tailwindcss/vite` (no `tailwind.config.js` — config is in CSS).

## Path Aliases

`@/` resolves to `src/`. Configured in both `jsconfig.json` and `vite.config.js`.

## Environment Variables

All client-side env vars must be prefixed `VITE_`. Currently used:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

Cloudflare bindings (D1, KV, etc.) are accessed through the Worker `env` object, not via `import.meta.env`.

## Data Model

The RPG domain includes: characters, attributes (Body/Speed/Mind/Spirit), skills, talents, paths, advances, domains, fighting styles, rituals, armor, weapons, gear, artifacts, and curios. JSON schemas for each type are in `schemas/`. The character sheet data shape is in `schemas/characterSheet.json` and `seeds/test_character.json`.
