@AGENTS.md

# Knowledge Goose — Instructions for ClaudeCode

## Project Overview

Knowledge Goose is a competitor analysis and visualization tool for an independent cafe in Vancouver. It is a single-tenant Next.js application where authenticated users (`admin` and `staff`) record observation data about competitor stores and visualize side-by-side comparisons.

This is a 3-day MVP, built as part of an experiment in shipping a working product without writing implementation code by hand. ClaudeCode is the primary code generator; the human focuses on requirements, design, and review.

For the full requirements and rationale, read `docs/prd.md` first.

## Communication

- The user may communicate in **Japanese**. Follow their language for conversational replies
- Code, identifiers, comments, and commit messages should be in **English**
- User-facing text in the application UI is **English only** for MVP (i18n with Japanese + Korean is planned post-MVP)

## Main Commands

| Command                | Purpose                                         |
| ---------------------- | ----------------------------------------------- |
| `pnpm dev`             | Start the development server                    |
| `pnpm build`           | Production build                                |
| `pnpm start`           | Run production server                           |
| `pnpm lint`            | Run ESLint                                      |
| `pnpm format`          | Run Prettier                                    |
| `pnpm typecheck`       | Type-check without emitting files               |
| `pnpm db:generate`     | Generate Drizzle migrations from schema changes |
| `pnpm db:migrate`      | Apply pending migrations                        |
| `pnpm db:seed`         | Insert seed data                                |
| `pnpm db:studio`       | Open Drizzle Studio                             |
| `docker compose up -d` | Start local PostgreSQL container                |

After making changes, always run `pnpm lint`, `pnpm typecheck`, and tests (when present) before declaring a task complete.

## Directory Overview

- `app/` — Next.js App Router pages and layouts
- `components/` — React components (UI / feature-specific)
- `actions/` — Next.js Server Actions (preferred over API Routes)
- `db/` — Drizzle schema (`schema.ts`) and database client
- `lib/` — External service integrations (better-auth, Resend, Google Places) and utilities
- `schemas/` — Zod validation schemas
- `types/` — Shared TypeScript types
- `docs/` — Design documentation (English primary; `docs/ja/` for Japanese)
- `notes/` — Development blog entries (EN/JA pairs)
- `drizzle/` — Auto-generated migration files (committed)
- `.claude/` — ClaudeCode commands and skills

## Coding Conventions (Summary)

- **TypeScript strict mode**; no implicit `any`
- **Nullability**: Use `null` for entity types and DB-mapped fields. Use `undefined` only for optional function parameters and React props
- **File naming**: `kebab-case.ts` for files; `PascalCase.tsx` for React component files
- **Import order**: external packages → internal absolute paths (`@/...`) → relative paths
- **Server Actions are preferred** over API Routes. Only create `app/api/*` routes for: (1) better-auth catch-all, (2) Google Places API proxy
- **Validation lives in `schemas/`** as Zod schemas; types are inferred from those schemas in `types/`
- **Derived values are NOT persisted**: `estimated_revenue`, `day_of_week`, `time_band` are computed at display time

For the detailed convention rules, see `docs/conventions.md` (will be added in Phase 2).

## User Intent → Automated Behaviors

When the user expresses certain intents in natural conversation, perform the corresponding action automatically. **Do not ask for confirmation before executing these.**

### Blog Post Auto-Save

Trigger phrases (in either Japanese or English): "make this a blog post", "save this as a blog entry", "let's record this in the dev blog", "ブログにしたい", "記事として残したい", "開発ブログに書いて", or similar intents.

When triggered:

1. Save the **Japanese version** to `notes/<NN>_ja_blog.md` (zero-padded 2-digit number)
2. Save the **English translation** to `notes/<NN>_en_blog.md` in parallel
3. The serial number is `(max existing number) + 1`
4. After saving, display both file paths
5. Do not ask for confirmation before saving

### Documentation Translation Sync

When the user creates or updates a file under `docs/` (the English version):

1. Create or update the parallel `docs/ja/<filename>` (Japanese translation)
2. Maintain structural parity (same section count, same headings, same tables)
3. Translate naturally; avoid literal word-for-word translation
4. Add a language switcher line at the top:
   - English file: `> Available in: English | [日本語](./ja/<filename>)`
   - Japanese file: `> Available in: [English](../<filename>) | 日本語`
5. After updating, display both file paths
6. Do not ask for confirmation

When the user updates a file under `docs/ja/` (the Japanese version), perform the inverse: update the parallel English version under `docs/`.

## Common Pitfalls (Project-Specific)

- **Only ONE row** in `restaurants` may have `is_own_store = true` (enforce at the application layer)
- **`admin` role assignment** is performed by direct SQL only; new sign-ups always receive `staff`. Do not build an in-app role-management UI for the MVP
- **Popular Times is NOT available** via the official Google Places API. Do not attempt to scrape it (Terms of Service violation)
- **`gender_ratio_male + gender_ratio_female` must equal 100** in observation records — validate before save
- **The sum of `age_distribution` values must equal 100** — validate before save
- **`observer_id` is auto-populated** with the current authenticated user; do not accept it from form input
- **`day_of_week` and `time_band`** are derived from `observed_at`. Never accept them directly from the client
- **Currency is CAD only**; do not add currency conversion logic
- **Google Place IDs are unique** in `restaurants`; reject duplicate competitor additions with a clear error
- **Never expose `GOOGLE_PLACES_API_KEY` to the frontend**. All Places API calls go through Server Actions or `app/api/places/*`
- **`NEXT_PUBLIC_GOOGLE_MAPS_API_KEY`** is the public key for the Maps JS API only; ensure it has HTTP referrer restrictions in Google Cloud Console

## Reference Documentation

- Requirements: `docs/prd.md` (English) / `docs/ja/prd.md` (Japanese)
- Data Model: `docs/data-model.md` / `docs/ja/data-model.md`
- Workflow Checklist: `docs/workflow-checklist.md` / `docs/ja/workflow-checklist.md`
- Tech Stack: `docs/stack.md` (planned)
- Architecture: `docs/architecture.md` (planned)
- Coding Conventions (detailed): `docs/conventions.md` (planned)
- API Reference: `docs/api.md` (planned)
- Test Strategy: `docs/test-strategy.md` (planned)
- Deployment: `docs/deployment.md` (planned, Phase 6)

## Notes for ClaudeCode

- Keep this file SHORT. Detailed rules belong in `docs/conventions.md` and the other linked documents
- Always read `docs/prd.md` and `docs/data-model.md` before implementing a new feature
- When in doubt about a convention, ask the user before making sweeping decisions
- For multi-file changes that affect domain modeling, ensure `db/schema.ts`, `schemas/*.ts`, and `types/*.ts` stay in sync
