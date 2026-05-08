# /feature — Implement a New Feature

## Before Starting

1. Identify the user story ID (e.g. `US-C1`) from the user's request
2. Read the full story and its acceptance criteria in `docs/prd.md`
3. Review the data model in `docs/data-model.md`
4. Consult the relevant MCP server for library-specific patterns (see CLAUDE.md)
5. Propose an implementation plan to the user before writing any code

## Implementation Order

Follow this sequence to avoid circular dependency issues:

```
schemas/<domain>.ts      ← Zod schema first
types/domain.ts          ← Infer types from Zod (if not already there)
db/schema.ts             ← Update if new columns are needed → pnpm db:generate
actions/<domain>.ts      ← Server Action (business logic + DB access)
components/<feature>/    ← UI components
app/(app)/<route>/       ← Page and layout
```

## Rules to Follow

- **Server Actions over API Routes** — only create `app/api/*` for: (1) better-auth catch-all, (2) Google Places proxy
- **No `any` types** — use proper types inferred from Zod schemas
- **`null` for nullable entity fields**, `undefined` only for optional params/props
- **`observer_id`** must be taken from the auth session — never accept from form input
- **`day_of_week` and `time_band`** must be derived from `observed_at` — never accept from client
- **`GOOGLE_PLACES_API_KEY`** must never appear in client-side code

## Acceptance Criteria Check

Before declaring the feature done, verify each checkbox in the PRD acceptance criteria for this story. Run:

```bash
pnpm typecheck
pnpm lint
```

Both must pass before reporting completion to the user.
