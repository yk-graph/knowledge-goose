# /fix-tests — Fix Failing Tests

## Steps

1. Run the full test suite and capture all failures:
   ```bash
   pnpm test
   ```
2. For each failing test, identify the root cause:
   - **Implementation bug** → fix the implementation, not the test
   - **Stale mock / wrong assertion** → update the test to reflect current behaviour
   - **Missing test data** → add the required fixtures or mocks
3. Fix one test at a time and re-run to confirm it passes
4. After all individual fixes, run the full suite again:
   ```bash
   pnpm test
   ```
5. Run type-check and lint to ensure no regressions:
   ```bash
   pnpm typecheck && pnpm lint
   ```

## Rules

- **Never weaken assertions to make a test pass** (e.g. changing `toBe(100)` to `toBeLessThan(200)`)
- If a test is testing behaviour that no longer applies, ask the user before deleting it
- Prefer fixing the implementation over working around it in tests

## If No Tests Exist Yet

Report this to the user. Suggest which acceptance criteria from `docs/prd.md` should be covered first, prioritising:

1. Validation rules (`gender_ratio` sum, `age_distribution` sum, `is_own_store` uniqueness)
2. Server Actions (happy path + error cases)
3. Critical UI flows (auth, observation input)
