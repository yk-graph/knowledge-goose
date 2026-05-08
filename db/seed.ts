/**
 * Seed Script
 *
 * Inserts development data into the local database.
 * Runs via: pnpm db:seed
 *
 * Strategy:
 * - Idempotent (safe to run multiple times)
 * - Does NOT run in production
 * - Provides enough data to make all three visualizations useful:
 *   MAP (≥4 locations), time series (≥2 months of observations), comparison table
 */

import { config } from 'dotenv'

// Load .env.local before importing db client
config({ path: '.env.local' })

import { db } from './client'
import { restaurants } from './schema'

async function seed() {
  console.log('🌱 Seeding database...')

  // --------------------------------------------------
  // 1. Own store (Blenz Coffee, hypothetical Vancouver)
  // --------------------------------------------------
  const ownStoreData = {
    is_own_store: true,
    name: 'Our Cafe (Vancouver)',
    address: '123 Granville St, Vancouver, BC V6C 1T2',
    latitude: 49.2827,
    longitude: -123.1207,
    average_price: 8.5, // CAD
    seat_count: 40,
    menu_count: 25,
    counter_seats: 8,
    table_seats: 24,
    sofa_seats: 8,
    patio_seats: 0,
    notes: 'Own store — reference baseline for all comparisons',
  }

  // --------------------------------------------------
  // 2. Competitor stores
  // --------------------------------------------------
  const competitorData = [
    {
      is_own_store: false,
      name: 'Competitor A',
      address: '456 Robson St, Vancouver, BC',
      latitude: 49.281,
      longitude: -123.128,
      google_rating: 4.3,
      google_review_count: 312,
      average_price: 7.0,
      seat_count: 55,
      menu_count: 30,
      counter_seats: 10,
      table_seats: 35,
      sofa_seats: 10,
      patio_seats: 0,
    },
    {
      is_own_store: false,
      name: 'Competitor B',
      address: '789 Davie St, Vancouver, BC',
      latitude: 49.276,
      longitude: -123.133,
      google_rating: 4.6,
      google_review_count: 780,
      average_price: 12.0,
      seat_count: 30,
      menu_count: 18,
      counter_seats: 6,
      table_seats: 14,
      sofa_seats: 10,
      patio_seats: 0,
    },
    {
      is_own_store: false,
      name: 'Competitor C',
      address: '321 Broadway, Vancouver, BC',
      latitude: 49.263,
      longitude: -123.116,
      google_rating: 4.1,
      google_review_count: 145,
      average_price: 8.0,
      seat_count: 38,
      menu_count: 22,
      counter_seats: 8,
      table_seats: 22,
      sofa_seats: 8,
      patio_seats: 0,
    },
  ]

  // --------------------------------------------------
  // Insert restaurants (skip if already exist)
  // --------------------------------------------------
  await db
    .insert(restaurants)
    .values([ownStoreData, ...competitorData])
    .onConflictDoNothing()

  console.log('✅ Restaurants seeded')

  // --------------------------------------------------
  // TODO: Insert users (seed admin user)
  // NOTE: This requires better-auth to be configured first.
  //       The user's ID format depends on better-auth's adapter.
  //       Add user seeding in Phase — auth setup.
  // --------------------------------------------------
  console.log('⏭️  Users skipped — add after better-auth setup')

  // --------------------------------------------------
  // TODO: Insert observations
  // NOTE: Requires user IDs (observer_id) — add after auth seed.
  //       Target: 2 months of data (≥20 records) to make time
  //       series chart meaningful.
  // --------------------------------------------------
  console.log('⏭️  Observations skipped — add after user seed')

  console.log('\n🎉 Seed complete')
  process.exit(0)
}

seed().catch((err) => {
  console.error('❌ Seed failed:', err)
  process.exit(1)
})
