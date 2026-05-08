# /refactor — Refactor

## Principles

- **Behaviour must not change** — add or update tests first if they don't exist
- **One concern per refactor** — do not mix restructuring with new features
- **Keep the diff small and reviewable** — the user reads every diff

## Common Patterns in This Project

### Extract a Server Action

Move business logic out of a component into `actions/<domain>.ts`:

```
// Before: logic inside a component
// After:
actions/restaurants.ts   ← pure function, uses db and zod
components/…             ← calls the action via useTransition or form action
```

### Split a Large Component

Components over ~150 lines should be split. Extract sub-components into the same `components/<feature>/` directory and keep the parent as an orchestrator.

### Normalise Duplicate Types

If the same shape appears in multiple files, extract it into `types/domain.ts` and infer from the Zod schema in `schemas/`:

```ts
// schemas/restaurant.ts
export const restaurantSchema = z.object({ ... });

// types/domain.ts
export type Restaurant = z.infer<typeof restaurantSchema>;
```

### Move a Magic Value to a Constant

Strings like `'admin'` or `'solo_work'` that appear more than twice should live in `constants/labels.ts` as typed constants.

## After Every Refactor

```bash
pnpm typecheck
pnpm lint
pnpm test       # if tests exist
```

All three must pass. Report results to the user before marking done.
