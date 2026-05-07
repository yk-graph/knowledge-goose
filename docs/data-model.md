# Data Model

> Available in: English | [日本語](./ja/data-model.md)

## Design Principles

- **Two-tier structure**: `restaurants` (store master, slow-changing data) + `observations` (time-series observation records)
- **Google-sourced fields are explicitly prefixed**: All Google Places API auto-fetched fields use the `google_*` prefix to make data sources visually distinct from manual fields
- **Snapshot the Google data at observation time**: A subset of Google fields is also stored on the `observations` table to enable retrospective analysis ("what was the rating at that point in time?")
- **Estimated revenue is a derived value**: Computed at display time as `restaurants.average_price * observations.customer_count`; not stored
- **Currency is CAD**: The product targets a Vancouver cafe
- **Use `null` for nullable fields**: Maps cleanly to SQL NULL, preserves keys in JSON serialization, and is the prevailing convention for entity types
- **Use `is_own_store` to distinguish own store from competitors**: Both managed in one table for unified querying

---

## restaurants table (store master)

```typescript
interface Restaurant {
  id: string // UUID
  is_own_store: boolean // Only one row may have this set to true (enforced at app level)

  // Identity
  name: string
  address: string
  latitude: number
  longitude: number
  google_place_id: string | null // null when no API linkage exists

  // Auto-fetched from Google Places API
  google_rating: number | null // 0.0 - 5.0
  google_review_count: number | null
  google_price_level: 0 | 1 | 2 | 3 | 4 | null // FREE - VERY_EXPENSIVE
  google_business_hours: BusinessHours | null
  google_photo_urls: string[]
  google_phone_number: string | null
  google_website_url: string | null
  google_categories: string[] // ['Cafe', 'Restaurant', ...]
  google_synced_at: string | null // ISO datetime; last sync time

  // Manual fields (required for revenue calculation and detailed comparisons)
  average_price: number // CAD; required
  seat_count: number
  menu_count: number
  seat_composition: SeatComposition

  // SNS
  instagram_handle: string | null
  twitter_handle: string | null
  tiktok_handle: string | null

  notes: string
  created_at: string
  updated_at: string
}

interface SeatComposition {
  counter: number
  table: number
  sofa: number
  patio: number
}

interface BusinessHours {
  monday: TimeRange[] | null // null indicates a closed day
  tuesday: TimeRange[] | null
  wednesday: TimeRange[] | null
  thursday: TimeRange[] | null
  friday: TimeRange[] | null
  saturday: TimeRange[] | null
  sunday: TimeRange[] | null
}

interface TimeRange {
  open: string // "11:00"
  close: string // "22:00"
}
```

---

## observations table (time-series observation records)

```typescript
interface Observation {
  id: string
  restaurant_id: string // FK -> Restaurant.id

  // Observation metadata
  observed_at: string // ISO datetime
  observation_duration_minutes: number
  observer_id: string // FK -> User.id (added when authentication is in place)

  // Customer activity (primary data for time series)
  customer_count: number

  // Customer demographics (subjective)
  gender_ratio_male: number // 0-100 (%)
  gender_ratio_female: number // 0-100 (%)
  age_distribution: AgeDistribution

  // Usage scene at the time of observation (subjective, single selection)
  observed_usage_scene: UsageScene

  // Environmental factors (for correlation with customer activity)
  weather: Weather
  day_of_week: DayOfWeek // Derived from observed_at (denormalized for query efficiency)
  time_band: TimeBand // Derived from observed_at

  // Google data snapshot
  google_rating_snapshot: number | null
  google_review_count_snapshot: number | null

  notes: string
  created_at: string
}

interface AgeDistribution {
  under_20: number // %
  twenties: number
  thirties: number
  forties: number
  fifties: number
  sixties_plus: number
}
```

---

## Enum Definitions

```typescript
type UsageScene =
  | 'casual_meal' // Everyday meal
  | 'business' // Business meeting
  | 'date' // Date
  | 'family' // Family gathering
  | 'friends_group' // Friend group
  | 'solo_work' // Solo work / cafe-style usage
  | 'celebration' // Special occasion
  | 'late_night' // Late-night usage

type Weather = 'sunny' | 'cloudy' | 'rain' | 'snow'

type DayOfWeek =
  | 'monday'
  | 'tuesday'
  | 'wednesday'
  | 'thursday'
  | 'friday'
  | 'saturday'
  | 'sunday'

type TimeBand =
  | 'morning' // 6:00-11:00
  | 'lunch' // 11:00-14:00
  | 'cafe' // 14:00-17:00
  | 'dinner' // 17:00-22:00
  | 'late_night' // 22:00 onward
```

---

## Derived Values (Not Persisted; Computed at Display Time)

| Value | Formula |
| --- | --- |
| `estimated_revenue` | `restaurant.average_price * observation.customer_count` |
| `day_of_week` | Derived from `observed_at` (stored redundantly to optimize aggregation queries) |
| `time_band` | Derived from `observed_at` (same rationale) |

---

## Validation Constraints

- Only **one row** with `is_own_store = true` may exist (enforced at the application layer)
- `gender_ratio_male + gender_ratio_female = 100` (only two values are tracked in MVP; non-binary will be considered later)
- The sum of `age_distribution` values must equal 100
- `google_place_id` must be unique when not null
- `customer_count >= 0`
- `observation_duration_minutes > 0`
- All values in `seat_composition` must be `>= 0`
- `seat_count >= sum(seat_composition values)` (total seats >= sum of breakdown)

### Authorization Constraints

- **At least one user with the `admin` role must exist** (enforced at the application layer)
- **Edit permission for observation records**: `admin` may edit any record; `staff` may edit only records where `observer_id = self`
- **Edit permission for master data**: `admin` only

---

## Recommended Indexes

- `restaurants(is_own_store)` — frequent lookups for the own store
- `restaurants(google_place_id)` — lookup during Google data updates
- `observations(restaurant_id, observed_at DESC)` — time-series retrieval per store
- `observations(observed_at)` — cross-store time-series analysis

---

## Why Snapshot Google Data on the Observation Record

`observations` carries `google_rating_snapshot` and `google_review_count_snapshot` for the following reasons:

- Google review counts and ratings **change over time**
- Recording the Google rating at the moment of observation enables **time-series correlation analysis**, e.g., "Did customer count rise during periods when the Google rating was rising?"
- The fields on the master side (`google_rating`, `google_review_count`) carry only the latest values; historical values are not preserved there

This is intentional denormalization.

---

## Why Currency Is Fixed at CAD

- The target store (own store) is located in Vancouver
- Multi-currency support is out of scope. If needed in the future, it can be extended by adding a `currency_code` field to `Restaurant`

---

## User Table (Authentication / Authorization)

```typescript
interface User {
  id: string // UUID
  email: string // unique
  display_name: string
  google_account_id: string | null // Google OAuth subject ID (only set when linked)
  role: UserRole
  created_at: string
  updated_at: string
}

type UserRole = 'admin' | 'staff'
```

- `admin` role assignment is performed by an implementer running a direct SQL update on the database; no role-management UI is provided in MVP
- New sign-ups are automatically assigned the `staff` role
