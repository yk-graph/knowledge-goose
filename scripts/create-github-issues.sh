#!/usr/bin/env bash
# scripts/create-github-issues.sh
#
# Creates all GitHub Issues for the Knowledge Goose MVP.
#
# Prerequisites:
#   gh CLI installed and authenticated (gh auth login)
#   Run from the repository root
#
# Usage:
#   bash scripts/create-github-issues.sh

set -euo pipefail

echo "🏷️  Creating labels..."

# || true prevents the script from failing if a label already exists
gh label create "epic:auth"           --color "#0075ca" --description "Authentication and authorization" 2>/dev/null || true
gh label create "epic:restaurants"    --color "#e4e669" --description "Restaurant master data" 2>/dev/null || true
gh label create "epic:observations"   --color "#cae2f5" --description "Observation records" 2>/dev/null || true
gh label create "epic:visualization"  --color "#d93f0b" --description "Map, chart, comparison table" 2>/dev/null || true
gh label create "epic:infrastructure" --color "#0e8a16" --description "Tooling, setup, seed data" 2>/dev/null || true
gh label create "priority:mvp"        --color "#b60205" --description "Required for MVP release" 2>/dev/null || true

echo "✅ Labels ready"

echo ""
echo "🎯 Creating milestone..."

gh api repos/:owner/:repo/milestones \
  --method POST \
  -f title="MVP" \
  -f description="3-day MVP — all acceptance criteria in docs/prd.md must be satisfied" \
  -f state="open" 2>/dev/null || echo "   (milestone may already exist)"

echo "✅ Milestone ready"

echo ""
echo "📋 Creating issues..."

# Helper — creates one issue and prints its URL
issue() {
  local title="$1"; local labels="$2"; local body="$3"
  local url
  url=$(gh issue create \
    --title "$title" \
    --label "$labels" \
    --milestone "MVP" \
    --body "$body")
  echo "  ✅ $url  |  $title"
}

# ─────────────────────────────────────────────
# 1. App shell
# ─────────────────────────────────────────────
issue \
"feat: app shell — sidebar, header, and protected route layout" \
"epic:infrastructure,priority:mvp" \
"## Overview
Set up the application shell that all authenticated pages share.
This is the foundation — implement before any feature pages.

## Acceptance checklist
- [ ] Route groups: \`app/(auth)/\` for login/signup, \`app/(app)/\` for protected pages
- [ ] Sidebar navigation linking to: Map, Time Series, Compare, Competitors, Own Store
- [ ] Header with user avatar and role badge + dropdown (Sign out)
- [ ] Middleware: unauthenticated requests to \`(app)/*\` redirect to \`/login\`
- [ ] \`pnpm typecheck && pnpm lint\` pass

## Dependencies
None — implement first."

# ─────────────────────────────────────────────
# 2. better-auth server config
# ─────────────────────────────────────────────
issue \
"feat: configure better-auth with Drizzle PostgreSQL adapter" \
"epic:auth,priority:mvp" \
"## Overview
Wire up better-auth on the server side. This is required before any auth UI
can be built.

Ref: US-A1 (backend portion)

## Acceptance checklist
- [ ] \`lib/auth/config.ts\` — server-side better-auth config with:
  - Email + password provider
  - Google OAuth provider
  - Drizzle adapter pointing to \`db/client.ts\`
  - Resend for transactional emails (verify + reset)
- [ ] \`app/api/auth/[...all]/route.ts\` — better-auth catch-all route
- [ ] \`lib/auth/client.ts\` — client-side helpers
- [ ] \`lib/auth/permissions.ts\` — \`isAdmin()\` / \`isStaff()\` helpers
- [ ] DB schema aligns with better-auth Drizzle adapter expectations; run \`pnpm db:generate && pnpm db:migrate\` if columns change
- [ ] \`pnpm typecheck && pnpm lint\` pass

## Dependencies
#1 (app shell)"

# ─────────────────────────────────────────────
# 3. Auth pages
# ─────────────────────────────────────────────
issue \
"feat: auth pages — signup, login, verify-email" \
"epic:auth,priority:mvp" \
"## Overview
Build the user-facing authentication screens.

Ref: US-A1, US-A2

## Acceptance checklist
- [ ] \`/signup\` — email + password form; Google OAuth button; Resend verification email sent on submit
- [ ] \`/login\` — email + password form; Google OAuth button; error shown on bad credentials
- [ ] \`/verify-email\` — activation link landing page; unverified accounts cannot access \`(app)/*\`
- [ ] Google OAuth callback handled by better-auth (skips email verification)
- [ ] New accounts receive \`staff\` role automatically
- [ ] \`pnpm typecheck && pnpm lint\` pass

## Dependencies
#2 (better-auth config)"

# ─────────────────────────────────────────────
# 4. Password reset
# ─────────────────────────────────────────────
issue \
"feat: password reset flow with Resend" \
"epic:auth,priority:mvp" \
"## Overview
Let users who forget their password recover via email.

Ref: US-A3

## Acceptance checklist
- [ ] \`/forgot-password\` — email input; same success message for registered and unregistered emails (enumeration prevention)
- [ ] Resend sends reset link; link expires after 1 hour
- [ ] \`/reset-password\` — new password form (8+ chars, letters + digits); redirects to \`/login\` on success
- [ ] Google OAuth users see a message directing them to Google account settings
- [ ] \`pnpm typecheck && pnpm lint\` pass

## Dependencies
#2 (better-auth config)"

# ─────────────────────────────────────────────
# 5. Own store
# ─────────────────────────────────────────────
issue \
"feat: own store — register and edit (admin only)" \
"epic:restaurants,priority:mvp" \
"## Overview
Admin can register and edit the single own-store record that serves as the
baseline for all comparisons.

Ref: US-B1

## Acceptance checklist
- [ ] \`/own-store\` — view page (all roles)
- [ ] \`/own-store/edit\` — edit page (admin only; staff redirected)
- [ ] Google Place ID lookup auto-fills: name, address, coordinates, hours, rating, photos
- [ ] Manual fields: \`average_price\` (CAD, required), \`seat_count\`, \`menu_count\`, \`seat_composition\` (counter/table/sofa/patio)
- [ ] SNS handles: Instagram, Twitter, TikTok (optional)
- [ ] Only ONE own-store record allowed; show error if a second is attempted
- [ ] \`pnpm typecheck && pnpm lint\` pass

## Dependencies
#3 (auth pages — admin role required)"

# ─────────────────────────────────────────────
# 6. Google Places proxy + competitor search
# ─────────────────────────────────────────────
issue \
"feat: Google Places proxy and competitor add (one-click)" \
"epic:restaurants,priority:mvp" \
"## Overview
Admin can search nearby cafes via Google Places and add them as competitors
with one click.

Ref: US-C1

## Acceptance checklist
- [ ] \`app/api/places/search/route.ts\` — server-side proxy; GOOGLE_PLACES_API_KEY never reaches the client
- [ ] Search is biased to Vancouver (\`locationBias\` parameter)
- [ ] Search results list: name, address, rating, photo thumbnail
- [ ] One-click add auto-populates all \`google_*\` fields in \`restaurants\`
- [ ] Duplicate \`google_place_id\` is rejected with a clear error message
- [ ] \`pnpm typecheck && pnpm lint\` pass

## Dependencies
#3 (auth — admin role)"

# ─────────────────────────────────────────────
# 7. Competitor manual edit
# ─────────────────────────────────────────────
issue \
"feat: competitor manual field edit form (admin only)" \
"epic:restaurants,priority:mvp" \
"## Overview
Admin can fill in or update fields that Google Places cannot provide.

Ref: US-C2

## Acceptance checklist
- [ ] \`/competitors/[id]/edit\` — admin only
- [ ] Editable: \`average_price\` (required), \`seat_count\`, \`menu_count\`, \`seat_composition\`, SNS handles, notes
- [ ] 'Re-sync Google data' button refreshes all \`google_*\` fields from Places API
- [ ] \`pnpm typecheck && pnpm lint\` pass

## Dependencies
#6 (competitor add)"

# ─────────────────────────────────────────────
# 8. Observation input
# ─────────────────────────────────────────────
issue \
"feat: observation input form (admin and staff)" \
"epic:observations,priority:mvp" \
"## Overview
Both admin and staff can record a timed observation of any store (own or competitor).

Ref: US-D1

## Acceptance checklist
- [ ] Store selector (own store + all competitors)
- [ ] Required fields: observed_at, duration_minutes, customer_count, gender ratio, age distribution, usage_scene, weather
- [ ] Validation: gender_ratio_male + gender_ratio_female must equal 100
- [ ] Validation: sum of age distribution fields must equal 100
- [ ] On save: observer_id auto-set from session; day_of_week and time_band derived from observed_at; google snapshot fields recorded
- [ ] \`pnpm typecheck && pnpm lint\` pass

## Dependencies
#3 (auth), #5 or #6 (at least one store must exist)"

# ─────────────────────────────────────────────
# 9. Map view
# ─────────────────────────────────────────────
issue \
"feat: map view — pins for own store and competitors" \
"epic:visualization,priority:mvp" \
"## Overview
Authenticated users can see all stores on a Google Map with distinct icons.

Ref: US-E1

## Acceptance checklist
- [ ] Google Maps JavaScript API loaded via NEXT_PUBLIC_GOOGLE_MAPS_API_KEY (HTTP referrer restricted)
- [ ] Own store: distinct pin color/icon vs competitors
- [ ] Initial view auto zoom-fits all pins
- [ ] Empty state shown with add-store CTA when no stores exist
- [ ] \`pnpm typecheck && pnpm lint\` pass

## Dependencies
#5 (own store), #6 (competitors)"

# ─────────────────────────────────────────────
# 10. Map pin detail
# ─────────────────────────────────────────────
issue \
"feat: map — store detail panel on pin click" \
"epic:visualization,priority:mvp" \
"## Overview
Clicking a pin opens a side panel with store details and a CTA to add the
store to the comparison table.

Ref: US-E2

## Acceptance checklist
- [ ] Side panel shows: name, address, business_hours, google_rating, google_review_count, average_price, seat_count, and at least one photo
- [ ] 'Add to comparison' button links to the comparison table with this store pre-selected
- [ ] Panel closes on outside click or ESC
- [ ] \`pnpm typecheck && pnpm lint\` pass

## Dependencies
#9 (map view)"

# ─────────────────────────────────────────────
# 11. Comparison table
# ─────────────────────────────────────────────
issue \
"feat: comparison table — own store vs up to 3 competitors" \
"epic:visualization,priority:mvp" \
"## Overview
Authenticated users can select up to 4 stores total and compare them
item by item.

Ref: US-G1

## Acceptance checklist
- [ ] Store selector: own store (always shown) + up to 3 competitors (max 4 total)
- [ ] Comparison items: average_price, seat_count, menu_count, seat_composition, business_hours, google_rating, google_review_count, google_categories
- [ ] Visual emphasis on differences (color / arrow / highlight)
- [ ] \`pnpm typecheck && pnpm lint\` pass

## Dependencies
#5 (own store), #7 (competitors with manual fields)"

# ─────────────────────────────────────────────
# 12. Time series chart
# ─────────────────────────────────────────────
issue \
"feat: time series chart — customer count and estimated revenue" \
"epic:visualization,priority:mvp" \
"## Overview
Authenticated users can compare observation trends across up to 4 stores.

Ref: US-F1

## Acceptance checklist
- [ ] Recharts line chart; own store + up to 3 competitors (max 4 total)
- [ ] Period switcher: last 1 week / 1 month / 3 months / custom
- [ ] Metric toggle: customer_count vs estimated_revenue (= average_price × customer_count, computed at display time — NOT stored)
- [ ] Periods with no data shown as gaps, not zero
- [ ] Legend distinguishes own store from competitors visually
- [ ] \`pnpm typecheck && pnpm lint\` pass

## Dependencies
#8 (observations exist), #13 (seed data with enough records)"

# ─────────────────────────────────────────────
# 13. Seed data completion
# ─────────────────────────────────────────────
issue \
"chore: complete seed data with admin user and observation records" \
"epic:infrastructure,priority:mvp" \
"## Overview
Complete \`db/seed.ts\` so the demo environment is data-rich enough to make
all three visualizations meaningful.

## Acceptance checklist
- [ ] Seed one admin user (update role to 'admin' via SQL after seeding)
- [ ] Seed observation records: ≥20 records spread across ≥2 months for own store and all 3 competitors
- [ ] Observations cover multiple time_band values (morning / lunch / cafe / dinner)
- [ ] Observations cover both weekdays and weekends
- [ ] \`pnpm db:seed\` runs without errors
- [ ] After seeding, time series chart shows meaningful curves (not a flat line)

## Dependencies
#3 (user IDs available), #8 (observation schema finalised)"

echo ""
echo "🎉 All issues created!"
echo ""
echo "Next steps:"
echo "  1. Open GitHub Issues: gh issue list"
echo "  2. Create a Project board (optional): https://github.com/orgs/<org>/projects"
echo "  3. Start with Issue #1 in ClaudeCode"