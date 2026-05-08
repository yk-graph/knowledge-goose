# /review — Self-Review Checklist

Review all current changes against the criteria below. Report results to the user and highlight any issues found.

## TypeScript and Code Quality

- [ ] No `any` types introduced
- [ ] Nullable entity fields use `null`, not `undefined`
- [ ] File names are `kebab-case`; React component files are `PascalCase.tsx`
- [ ] Import order: external packages → `@/...` absolute → relative

## Security

- [ ] `GOOGLE_PLACES_API_KEY` is not referenced anywhere in `app/` or `components/`
- [ ] All user input is validated with Zod before being processed or persisted
- [ ] `observer_id` is taken from the auth session, not from form input
- [ ] No secrets or API keys are hardcoded

## Data Integrity

- [ ] Only ONE row with `is_own_store = true` can exist (enforced at app layer)
- [ ] `gender_ratio_male + gender_ratio_female = 100` is validated before save
- [ ] Sum of age distribution fields = 100 is validated before save
- [ ] `estimated_revenue` is computed at display time — not stored in DB
- [ ] `day_of_week` and `time_band` are derived from `observed_at` — not accepted from client

## Architecture

- [ ] Business logic lives in `actions/`, not inside components
- [ ] Zod schemas live in `schemas/`, TypeScript types are inferred from them in `types/`
- [ ] No new `app/api/*` routes added unless for better-auth or Google Places proxy

## Passing Checks

Run the following and confirm both pass:

```bash
pnpm typecheck
pnpm lint
```

## Output Format

Report as:

- ✅ Check name — passed
- ⚠️ Check name — minor issue (describe)
- ❌ Check name — must fix (describe)

Fix all ❌ items before reporting completion.
