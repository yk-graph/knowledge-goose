import {
  boolean,
  integer,
  pgEnum,
  pgTable,
  real,
  text,
  timestamp,
  uuid,
  varchar,
  jsonb,
  index,
  unique,
} from 'drizzle-orm/pg-core'

// =====================================================
// Enums
// =====================================================

export const userRoleEnum = pgEnum('user_role', ['admin', 'staff'])

export const usageSceneEnum = pgEnum('usage_scene', [
  'casual_meal',
  'business',
  'date',
  'family',
  'friends_group',
  'solo_work',
  'celebration',
  'late_night',
])

export const weatherEnum = pgEnum('weather', [
  'sunny',
  'cloudy',
  'rain',
  'snow',
])

export const dayOfWeekEnum = pgEnum('day_of_week', [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
])

export const timeBandEnum = pgEnum('time_band', [
  'morning', // 06:00-11:00
  'lunch', // 11:00-14:00
  'cafe', // 14:00-17:00
  'dinner', // 17:00-22:00
  'late_night', // 22:00-
])

// =====================================================
// Users
// NOTE: Columns will be expanded when better-auth is
// configured. The `role` column is our custom addition;
// all other columns follow better-auth's Drizzle adapter
// requirements. Run `npx @better-auth/cli generate` if
// the auth migration diverges from this definition.
// =====================================================

export const users = pgTable('users', {
  // better-auth uses text (not uuid) for user IDs
  id: text('id').primaryKey(),
  email: text('email').notNull().unique(),
  email_verified: boolean('email_verified').notNull().default(false),
  name: text('name').notNull(),
  image: text('image'),

  // Custom field (not from better-auth core)
  role: userRoleEnum('role').notNull().default('staff'),

  created_at: timestamp('created_at', { withTimezone: true })
    .defaultNow()
    .notNull(),
  updated_at: timestamp('updated_at', { withTimezone: true })
    .defaultNow()
    .notNull(),
})

// =====================================================
// Restaurants (store master)
// =====================================================

export const restaurants = pgTable(
  'restaurants',
  {
    id: uuid('id').primaryKey().defaultRandom(),

    // Constraint: only ONE row may have is_own_store = true (enforced at app layer)
    is_own_store: boolean('is_own_store').notNull().default(false),

    // Identity
    name: varchar('name', { length: 255 }).notNull(),
    address: text('address').notNull(),
    latitude: real('latitude').notNull(),
    longitude: real('longitude').notNull(),
    google_place_id: varchar('google_place_id', { length: 255 }),

    // Auto-fetched from Google Places API (google_* prefix)
    google_rating: real('google_rating'),
    google_review_count: integer('google_review_count'),
    // 0=FREE, 1=INEXPENSIVE, 2=MODERATE, 3=EXPENSIVE, 4=VERY_EXPENSIVE
    google_price_level: integer('google_price_level'),
    // JSONB: BusinessHours is nested (per-day time ranges) — appropriate use of JSONB
    google_business_hours: jsonb(
      'google_business_hours',
    ).$type<BusinessHours | null>(),
    google_photo_urls: text('google_photo_urls').array().notNull().default([]),
    google_phone_number: varchar('google_phone_number', { length: 50 }),
    google_website_url: text('google_website_url'),
    google_categories: text('google_categories').array().notNull().default([]),
    google_synced_at: timestamp('google_synced_at', { withTimezone: true }),

    // Manual fields (CAD currency, required for estimated revenue calculation)
    average_price: real('average_price').notNull(),

    seat_count: integer('seat_count').notNull().default(0),
    menu_count: integer('menu_count').notNull().default(0),

    // Seat composition (individual columns — flat structure, potentially filtered)
    counter_seats: integer('counter_seats').notNull().default(0),
    table_seats: integer('table_seats').notNull().default(0),
    sofa_seats: integer('sofa_seats').notNull().default(0),
    patio_seats: integer('patio_seats').notNull().default(0),

    // SNS
    instagram_handle: varchar('instagram_handle', { length: 100 }),
    twitter_handle: varchar('twitter_handle', { length: 100 }),
    tiktok_handle: varchar('tiktok_handle', { length: 100 }),

    notes: text('notes').notNull().default(''),
    created_at: timestamp('created_at', { withTimezone: true })
      .defaultNow()
      .notNull(),
    updated_at: timestamp('updated_at', { withTimezone: true })
      .defaultNow()
      .notNull(),
  },
  (t) => [
    index('restaurants_is_own_store_idx').on(t.is_own_store),
    unique('restaurants_google_place_id_unique').on(t.google_place_id),
  ],
)

// =====================================================
// Observations (time-series records)
// =====================================================

export const observations = pgTable(
  'observations',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    restaurant_id: uuid('restaurant_id')
      .notNull()
      .references(() => restaurants.id, { onDelete: 'cascade' }),
    observer_id: text('observer_id')
      .notNull()
      .references(() => users.id, { onDelete: 'restrict' }),

    // When and how long the observation took place
    observed_at: timestamp('observed_at', { withTimezone: true }).notNull(),
    observation_duration_minutes: integer(
      'observation_duration_minutes',
    ).notNull(),

    // Customer count (primary metric for time-series chart)
    customer_count: integer('customer_count').notNull(),

    // Demographics (subjective; validated at app layer: male + female = 100)
    gender_ratio_male: integer('gender_ratio_male').notNull(), // 0-100 %
    gender_ratio_female: integer('gender_ratio_female').notNull(), // 0-100 %

    // Age distribution (individual columns; sum must equal 100 at app layer)
    age_under_20: integer('age_under_20').notNull().default(0),
    age_twenties: integer('age_twenties').notNull().default(0),
    age_thirties: integer('age_thirties').notNull().default(0),
    age_forties: integer('age_forties').notNull().default(0),
    age_fifties: integer('age_fifties').notNull().default(0),
    age_sixties_plus: integer('age_sixties_plus').notNull().default(0),

    // Usage and environment
    observed_usage_scene: usageSceneEnum('observed_usage_scene').notNull(),
    weather: weatherEnum('weather').notNull(),
    // day_of_week and time_band are DERIVED from observed_at (denormalized for query efficiency)
    day_of_week: dayOfWeekEnum('day_of_week').notNull(),
    time_band: timeBandEnum('time_band').notNull(),

    // Google data snapshot at the time of observation (intentional denormalization)
    // Allows correlation analysis: "did rating changes coincide with customer count changes?"
    google_rating_snapshot: real('google_rating_snapshot'),
    google_review_count_snapshot: integer('google_review_count_snapshot'),

    notes: text('notes').notNull().default(''),
    created_at: timestamp('created_at', { withTimezone: true })
      .defaultNow()
      .notNull(),
  },
  (t) => [
    // Time-series retrieval per store
    index('observations_restaurant_id_observed_at_idx').on(
      t.restaurant_id,
      t.observed_at,
    ),
    // Cross-store time-series analysis
    index('observations_observed_at_idx').on(t.observed_at),
  ],
)

// =====================================================
// TypeScript types (inferred from schema)
// =====================================================

export type User = typeof users.$inferSelect
export type NewUser = typeof users.$inferInsert
export type Restaurant = typeof restaurants.$inferSelect
export type NewRestaurant = typeof restaurants.$inferInsert
export type Observation = typeof observations.$inferSelect
export type NewObservation = typeof observations.$inferInsert

// =====================================================
// JSONB type definitions
// =====================================================

export interface TimeRange {
  open: string // "11:00"
  close: string // "22:00"
}

export interface BusinessHours {
  monday: TimeRange[] | null
  tuesday: TimeRange[] | null
  wednesday: TimeRange[] | null
  thursday: TimeRange[] | null
  friday: TimeRange[] | null
  saturday: TimeRange[] | null
  sunday: TimeRange[] | null
}
