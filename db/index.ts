// Re-export db client
export { db } from './client'
export type { Db } from './client'

// Re-export schema tables
export {
  users,
  sessions,
  accounts,
  verifications,
  restaurants,
  observations,
} from './schema'

// Re-export enums
export {
  userRoleEnum,
  usageSceneEnum,
  weatherEnum,
  dayOfWeekEnum,
  timeBandEnum,
} from './schema'

// Re-export inferred types
export type {
  User,
  NewUser,
  Session,
  NewSession,
  Account,
  NewAccount,
  Verification,
  NewVerification,
  Restaurant,
  NewRestaurant,
  Observation,
  NewObservation,
  TimeRange,
  BusinessHours,
} from './schema'
