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

**Frontend** (`src/`): Vue 3 + Vite SPA. Uses `<RouterView>` in `App.vue`. Routes are defined in `src/router/index.js`:
- `/` → `LandingPage.vue` (`home`)
- `/signup` → `SignUp.vue`, `/login` → `Login.vue`, `/auth/callback` → `AuthCallback.vue`
- `/dashboard` → `Dashboard.vue` (auth-guarded via `router.beforeEach`)
- `/character/:id` → `CharacterSheet.vue` — the `:id` param is the character's Supabase UUID
- `/character/:id/edit` → `EditCharacter.vue`

Auth state is provided by the `useAuth` composable (`src/composables/useAuth.js`); the router guard uses `supabase.auth.getSession()` directly.

**Backend** (`server/`): Express.js running inside a Cloudflare Worker via `@cloudflare/vite-plugin`. Entry is `server/index.js`. Routes live under `/api`. The `/api/seed` route is deprecated as the project has moved to Supabase instead of Cloudflare D1.

**Database**: Two database layers co-exist:
- **Cloudflare D1** DEPRECATED. (SQLite) for the Worker backend — seeded via `POST /api/seed/*` endpoints. This has been deprecated in favor of Supabase.
- **Supabase** (PostgreSQL) for client-side persistence and worker backend — configured in `src/lib/supabaseClient.js` using `VITE_SUPABASE_URL` / `VITE_SUPABASE_ANON_KEY` env vars

Schema for both is documented in `schemas/` (JSON) and `postgresSchema.sql`. `postgresSchema.sql` is the primary source for schemas now that the project is using Supabase instead of Cloudflare D1. Seed data lives in `seeds/*.json` and `seeds/seed-dev.js`.

## UI Component System

`src/volt/` is a custom component library wrapping PrimeVue in "unstyled" mode, styled entirely with TailwindCSS via `tailwindcss-primeui`. These components (Button, Card, Panel, Accordion, DataTable, Popover, etc.) are the building blocks for all UI. Use Volt components instead of raw PrimeVue or HTML where equivalents exist.

PrimeVue is configured in `src/main.js` with `Aura` theme preset. TailwindCSS v4 is integrated via `@tailwindcss/vite` (no `tailwind.config.js` — config is in CSS).

Volt components are added on demand with the `volt-vue` CLI (`npx volt-vue add <Component>`), which copies the wrapper source into `src/volt/`. Form inputs (`InputText`, `InputNumber`, `Select`, `Textarea`, `ToggleSwitch`, `AutoComplete`), `Dialog`, and `DataTable` were added this way. **Severity is per-component, not a prop**: use `SecondaryButton` / `DangerButton` / `ContrastButton` rather than `severity="..."` on the base `Button`. `Column` is imported directly from `primevue/column` (Volt only wraps `DataTable`).

**State convention:** components hold state in a single `reactive({ ... })` object (one property per value) rather than multiple `ref()`s — see `charData`/`form`/`dataState`/`talentState`/`invState`. Async fetch/write flows surface progress through `src/components/LoadingState.vue` (props `isError`, `errorMessage`), driven by an `isLoaded`/`isError` or `busy` flag on that reactive object.

## Character Data Management

The character sheet/editor compose three layers: the `characters` row (scalar fields), and child "instance" tables joined by `character_id`.

- **CharacterSheet.vue** (`/character/:id`) displays a character and is interactive for inventory. It loads the character row, talent instances, and inventory instances in a single `Promise.all`.
- **EditCharacter.vue** (`/character/:id/edit`) edits the character's *setup* fields only — runtime/state fields (`current*`, `*Stress`, `blessings`, `curses`, `doom`) and `id`/`owner`/`campaign` are intentionally excluded; `owner` is set from the logged-in user on save.

**Instance + selector-modal pattern** (talents and inventory follow the same shape):
- A Volt `DataTable` lists the character's instances (joined to the definition table where an FK exists).
- A selector modal (`src/components/TalentSelector.vue`, `src/components/InventorySelector.vue`) wraps Volt `Dialog` + a filterable, multi-select `DataTable` of available definitions, with Save (insert instances) / Cancel; it emits `saved` so the parent refetches.
- **Talents** are managed on **EditCharacter** (add via modal, per-row remove); shown read-only on the sheet. `talent_instances.talent_name` → `talents.name` (FK, so Supabase joins directly).
- **Inventory** is managed on the **CharacterSheet** itself (add via modal, per-row remove). Items live across five tables (`gear`/`armor`/`weapons`/`curios`/`artifacts`); the modal uses a type picker. `inventory_instances` has **no FK** to those tables — `baseItem` stores the item's `id` and `displayName` is denormalized to the item name, so the on-sheet table needs no cross-table join.

**Out of scope** in the current instance DataTable implementation (deferred):
- *Talents:* picklist talents (`hasPicklist`) — instances created with `value` null; no per-row edit of `value`. The legacy `characters.talents` text column is left in the DB but no longer written.
- *Inventory:* equip toggle (`isEquipped` always false on create), stack counts (`stackValue`), and all override columns (`dmgOverride`, `descriptionOverride`, `slotOverride`, `specialOverride`); only one `itemType` per Save session; no richer per-row detail (slots/description) since there's no FK to resolve `baseItem`.

## Path Aliases

`@/` resolves to `src/`. Configured in both `jsconfig.json` and `vite.config.js`.

## Environment Variables

All client-side env vars must be prefixed `VITE_`. Currently used:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_PUBLISHABLE_KEY`

Cloudflare bindings (D1, KV, etc.) are accessed through the Worker `env` object, not via `import.meta.env`.

## Data Model

The RPG domain includes: characters, attributes (Body/Speed/Mind/Spirit), skills, talents, paths, advances, domains, fighting styles, rituals, armor, weapons, gear, artifacts, and curios. JSON schemas for each type are in `schemas/`. The character sheet data shape is in `schemas/characterSheet.json` and `seeds/test_character.json`.

### Inventory Instances Data Model
Inventory Instances contains a jsonb column called item_config.
item_config allows a user to customize the item for their character:
- Rename the item
- Customize the Slots and Damage dice
- Add custom description

item_config object schema:
{
    name: string. custom name, defaults to baseItem name
    dmg: string. damage dice, defaults to baseItem damage if baseItem is a weapon, otherwise set to null
    description: string. custom description, defaults to baseItem description
    effect: string. custom effect, defaults to baseItem effect. If baseItem does not specify, set to null.
    stackValue: int. custom stack value, defaults to baseItem stack value. Minimum 1.
    armor: int. custom armor value, defaults to baseItem value. Minimum 0.
    hasClock: boolean. custom hasClock value, defaults to baseItem value. If baseItem does does not specify, set to false.
    clockValue: int. custom clockValue, defaults to baseItem value. If baseItem does not specify, set to 0.
    slots: int. custom slot value, defaults to baseItem value. If baseItem does not specify, set to 0.
}

## Talent Instances Data Model
Talent Instances contains a jsonb column called 'value'.
value allows a user to customize the talent by selecting picklist values (if applicable) or adding advances to the talent.
The front end app reads the JSON object and displays values from it in the UI.

value object schema:
{
    type: enum. Minor, Major, or Pinnacle
    path_name: string. Name of the Path associated with the Talent
    flavorText: string. Flavor text associated with the Talent. Defaults to Talent Flavor Text.
    description: string. description of the Talent. Defaults to Talent Description.
    hasPicklist: boolean. Whether the talent has an associated picklist.
    selectedValue: string. The value selected from the picklist
    picklistHasObj: boolean. Whether the picklist values are an array of objects
    picklistValues: array. An array of strings or objects.
    advances: array. An array of advances selected for this Talent. Defaults to an empty array.
}