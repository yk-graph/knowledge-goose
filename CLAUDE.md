@AGENTS.md

# Knowledge Goose — Instructions for ClaudeCode

## Project Overview

Knowledge Goose is a competitor analysis and visualization tool for an independent cafe in Vancouver. It is a single-tenant Next.js application where authenticated users (`admin` and `staff`) record observation data about competitor stores and visualize side-by-side comparisons.

This is a 3-day MVP. ClaudeCode is the primary code generator; the human focuses on requirements, design, and review — not writing implementation code.

For the full requirements and rationale, read `docs/prd.md` first.

## Communication

- The user may communicate in **Japanese**. Follow their language for conversational replies
- Code, identifiers, comments, and commit messages must be in **English**
- User-facing UI text is **English only** for MVP (Japanese + Korean i18n is planned post-MVP)

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
- `notes/` — Development blog entries (EN/JA pairs, `NN_en_blog.md` / `NN_ja_blog.md`)
- `drizzle/` — Auto-generated migration files (committed to git)
- `.claude/` — ClaudeCode commands and skills

For the full architectural breakdown, see `docs/architecture.md`.

## Coding Conventions (Summary)

- **TypeScript strict mode** — no implicit `any`
- **Nullability** — use `null` for entity types and DB-mapped fields; use `undefined` only for optional function parameters and React props
- **File naming** — `kebab-case.ts` for files; `PascalCase.tsx` for React component files
- **Import order** — external packages → internal absolute paths (`@/...`) → relative paths
- **Server Actions are preferred** over API Routes. Only create `app/api/*` for: (1) better-auth catch-all, (2) Google Places proxy
- **Validation lives in `schemas/`** as Zod validation schemas; types are inferred from those schemas in `types/`
- **Derived values are NOT persisted** — `estimated_revenue`, `day_of_week`, `time_band` are computed at display time

For detailed rules, see `docs/conventions.md`.

## Library Documentation and Tooling

When you need information about a library's API or current best practices, query the appropriate MCP server rather than relying on training data alone. The `package.json` is the source of truth for installed versions.

| MCP Server | Use for |
| --- | --- |
| `context7` | Drizzle ORM, Tailwind CSS, Recharts, react-hook-form, Next.js, shadcn/ui, and any library not covered by a dedicated server |
| `zod` | Zod schema validation — official Zod × Inkeep MCP endpoint |
| `better-auth` | better-auth auth setup, diagnostics, configuration |
| `playwright` | Browser automation, visual verification, E2E testing |

When using Context7, note in your response which library and version you queried (e.g., "Per Context7 docs for drizzle-orm v0.45.x..."). This allows the user to verify the source.

## When Documentation Sources Conflict

If an MCP server response contradicts your training data, or there are suspicious signs (the API does not compile, the example does not match the installed version in `package.json`), do the following:

1. State the discrepancy explicitly to the user
2. Cross-check by reading `node_modules/<package>/README.md` or the package's official GitHub repository
3. Do not proceed with a guess — ask the user for confirmation before committing code

Be especially cautious with:

- **Drizzle ORM** — rapidly evolving; syntax can change between minor versions
- **Tailwind CSS** — v3 to v4 had significant breaking changes; always verify class names
- **Zod** — v3 vs v4 API differences exist

## User Intent → Automated Behaviors

When the user expresses certain intents, perform the action automatically. **Do not ask for confirmation before executing these.**

### Blog Post Auto-Save

Trigger phrases (Japanese or English): "make this a blog post", "save this as a blog entry", "let's record this in the dev blog", "ブログにしたい", "記事として残したい", "開発ブログに書いて", or similar.

When triggered:

1. Save the **Japanese version** to `notes/<NN>_ja_blog.md` (zero-padded 2-digit number)
2. Save the **English translation** to `notes/<NN>_en_blog.md` in parallel
3. Serial number = (max existing number) + 1
4. Display both file paths after saving
5. No prior confirmation needed

### Documentation Translation Sync

When a file under `docs/` (English) is created or updated:

1. Create or update the parallel `docs/ja/<filename>` (Japanese translation)
2. Maintain structural parity (same sections, headings, tables)
3. Translate naturally — avoid literal word-for-word translation
4. Add a language switcher at the top of both files:
   - English: `> Available in: English | [日本語](./ja/<filename>)`
   - Japanese: `> Available in: [English](../<filename>) | 日本語`
5. Display both file paths after saving
6. No prior confirmation needed

When a file under `docs/ja/` (Japanese) is updated, perform the inverse: update the corresponding English file under `docs/`.

## Common Pitfalls (Project-Specific)

- **Only ONE row** with `is_own_store = true` in `restaurants` — enforce at app layer
- **`admin` role** is assigned via direct SQL only; new sign-ups always receive `staff`; do not build a role-management UI for MVP
- **Popular Times is NOT available** via the Google Places API — do not scrape it (ToS violation)
- **`gender_ratio_male + gender_ratio_female` must equal 100** — validate before save
- **Sum of `age_distribution` values must equal 100** — validate before save
- **`observer_id`** is auto-populated with the authenticated user; never accept it from form input
- **`day_of_week` and `time_band`** are derived from `observed_at`; never accept from client
- **Currency is CAD only** — do not add currency conversion logic
- **`google_place_id` must be unique** in `restaurants` — reject duplicate competitor additions with a clear error
- **Never expose `GOOGLE_PLACES_API_KEY`** to the frontend — all Places API calls go through Server Actions or `app/api/places/*`
- **`NEXT_PUBLIC_GOOGLE_MAPS_API_KEY`** must have HTTP referrer restrictions set in Google Cloud Console

## Reference Documentation

| Document | Path |
| --- | --- |
| Requirements (PRD) | `docs/prd.md` / `docs/ja/prd.md` |
| Data Model | `docs/data-model.md` / `docs/ja/data-model.md` |
| Workflow Checklist | `docs/workflow-checklist.md` / `docs/ja/workflow-checklist.md` |
| Tech Stack | `docs/stack.md` (planned) |
| Architecture | `docs/architecture.md` (planned) |
| Coding Conventions (detailed) | `docs/conventions.md` (planned) |
| API Reference | `docs/api.md` (planned) |
| Test Strategy | `docs/test-strategy.md` (planned) |
| Deployment | `docs/deployment.md` (planned, Phase 6) |

## Notes for ClaudeCode

- Keep this file concise — detailed rules belong in `docs/conventions.md`
- Always read `docs/prd.md` and `docs/data-model.md` before implementing a new feature
- When in doubt about a convention, ask the user before making sweeping decisions
- For multi-file changes affecting domain modeling, keep `db/schema.ts`, `schemas/*.ts`, and `types/*.ts` in sync
