# Product Requirements Document: Cafe Competitor Analysis & Visualization Tool

> Available in: English | [日本語](./ja/prd.md)
>
> This document defines the product requirements. The rationale, alternatives considered, and trade-offs behind each design decision are recorded separately in the development blog (out of scope for this document).

---

## 1. Product Overview

**A competitor analysis and visualization tool that helps an independent cafe owner in Vancouver make data-driven customer acquisition decisions through structured comparison with neighboring competitors.**

### Who / What / How

- **For whom**: A single-store cafe owner operating in Vancouver
- **What problem**: Wanting to grow customer visits but lacking concrete inputs to decide what actions to take
- **How it solves the problem**: Centralizes information about neighboring competitor stores — store characteristics, observation records, Google public data — and provides visual comparison against the own store

### Product Positioning

- Single-tenant design (the target is one fixed store = the user's own cafe)
- Data collection is performed manually by field investigators (a separate role)
- The application's responsibility is limited to providing the **data input platform** and the **visualization tool**

### Out of Scope

- Field investigator dispatch and operational design
- Data quality assurance
- Multi-store expansion / multi-tenant support

### Core Features

- **Map view** — Pin competitor stores on a map, click for detailed information
- **Time series chart** — Trends in review count, customer count, and estimated revenue
- **Comparison table** — Item-by-item comparison between own store and selected competitors

---

## 2. Target Users

### Primary User: Cafe Owner / Manager

- **Role**: Owner or executive of the single-store cafe operating in Vancouver
- **Characteristics**:
  - Spends most working hours on day-to-day store operations; time available for analysis is limited
  - Does not have advanced data analysis expertise
  - Final decision-maker for management decisions
- **Devices**: PC (back office at the store, home)
- **Usage scenes**: Periodic analysis for management decisions (weekly to monthly), reviewing options when planning new initiatives
- **What they want**: Visualization that makes differences with competitors immediately visible; support for hypothesis-driven decision-making
- **What they cannot accept**: An experience that takes too long to gather information for a decision

### Secondary User: Field Investigator (Data Input)

- **Role**: A person commissioned by the owner to visit competitor stores and record observation data
- **Devices**: Smartphone (on site) / PC (later, batch input)
- **Usage scenes**: During or after a competitor store visit
- **MVP treatment**: Minimal UI investment. Some inconvenience is acceptable since they are working at the owner's request

### User Count Assumptions

- Primary: **1 user** (the owner)
- Secondary: A handful of users (the cafe's field investigators)
- Each user has an individual account and authenticates before using the app
- The data itself is for a single store (single-tenant design is preserved)

### Authentication and Authorization

- **Authentication required**: Unauthenticated users cannot access the app
- **Authentication methods**: Only the following two
  - Email + password
  - Google account (OAuth)
- **Not supported**: OAuth via Twitter / X, Facebook, GitHub, Apple, or other SNS providers
- **Authorization model**: Role-based, with two roles (`admin` / `staff`)

### Role Definitions

- **`admin`** (intended use: cafe owner / executive)
  - Edit own store master data
  - Add, edit, delete competitor master data
  - Input, edit, delete observation records (any record)
  - View all visualizations
  - View user list
- **`staff`** (intended use: field investigator)
  - Input observation records (own records are editable; others are read-only)
  - View all visualizations
  - Read-only on own store and competitor master data
  - Cannot view user list

### Initial Admin Setup

- All sign-ups receive the `staff` role
- The `admin` role is granted by an implementer running a direct SQL update on the database (no role-management UI in MVP)

### Design Implications

- The visualization must require near-zero learning cost (an inexperienced owner should be able to interpret it)
- Avoid jargon; design UI that is meaningful at a glance
- The input UI is function-first; visual polish is deprioritized
- Implementing authentication expands the MVP scope (allow 0.5 to 1 day of work for it)

---

## 3. User Stories

Format: `[ID] [Priority] As a <role>, I want to <action>, so that <reason>.`

Priority: **MVP** (included in the initial release) / **Deferred** (post-MVP)

### Epic A: Authentication

- **`US-A1` MVP** — As a user, I want to **sign up** with an email and password, or with a Google account, so that I can access the application (which requires authentication).
- **`US-A2` MVP** — As a user, I want to **sign in and sign out** of my registered account, so that I can manage my session and be distinguished from other users.
- **`US-A3` MVP** — As a user, I want to **reset my password via email** if I forget it, so that I can continue using my account without re-registering.

### Epic B: Own Store Master

- **`US-B1` MVP** — As an `admin`, I want to **register and edit** my own store information (basic info, Google Place ID linkage, manual fields like average price), so that comparisons have a baseline.

### Epic C: Competitor Master

- **`US-C1` MVP** — As an `admin`, I want to **search competitors via Google Places API and add them with one click**, so that I do not have to manually enter address, hours, photos, etc.
- **`US-C2` MVP** — As an `admin`, I want to **edit a competitor's manual fields** (average price, seat count, seat composition, SNS handles, etc.), so that I can supplement information not available from Google.
- **`US-C3` Deferred** — As an `admin`, I want to **delete a competitor** I no longer track, so that I can remove unwanted noise from comparisons.

### Epic D: Observation Records

- **`US-D1` MVP** — As a `staff` user, I want to **record observation data** (customer count, demographics, usage scene, weather, etc.) when visiting a competitor, so that we can track changes in customer activity over time.
- **`US-D2` Deferred** — As a `staff` user, I want to **edit my own observation records**, so that I can fix entry mistakes or add information.
- **`US-D3` Deferred** — As an `admin`, I want to **edit and delete any observation record**, so that I can take final responsibility for data quality.

### Epic E: Map Visualization

- **`US-E1` MVP** — As a user, I want to see the own store and competitor stores **as pins on a map**, so that I can grasp the geographic competitive situation at a glance.
- **`US-E2` MVP** — As a user, I want to **click a pin to see store details**, so that I can quickly access information for a specific store.

### Epic F: Time Series Chart

- **`US-F1` MVP** — As a user, I want to compare **trends in customer count and estimated revenue** between own store and competitors, so that I can read patterns of customer activity differences.
- **`US-F2` Deferred** — As a user, I want to view trends in **Google review count and rating** over time, so that I can track the relationship between rating changes and customer activity.

### Epic G: Comparison Table

- **`US-G1` MVP** — As a user, I want to see an **item-by-item comparison table** between own store and selected competitors, so that I can grasp differences in price, seat count, business hours, etc., at a glance.

### Summary

| Category  | Count  |
| --------- | ------ |
| MVP       | 10     |
| Deferred  | 4      |
| **Total** | **14** |

---

## 4. Acceptance Criteria

Acceptance criteria are defined for the **10 MVP stories only**; criteria for deferred stories are out of MVP scope.

### Epic A: Authentication

#### `US-A1` Sign Up

- [ ] Users can sign up with email + password
- [ ] Password must be **at least 8 characters** and contain both letters and digits
- [ ] Users can sign up with a Google account
- [ ] Sign-up with an already-registered email returns an error
- [ ] When signing up with email + password, a verification email is sent via Resend
- [ ] The account is activated only after the user clicks the activation link in the verification email
- [ ] Sign-in is rejected for accounts that have not completed activation (with an error message)
- [ ] Activation links expire after 24 hours
- [ ] A "resend verification email" feature is provided
- [ ] Email verification is skipped for Google account sign-ups
- [ ] On successful sign-up, the user is automatically assigned the **`staff`** role

#### `US-A2` Sign In / Sign Out

- [ ] Users can sign in with a registered email + password
- [ ] Users can sign in with a Google account
- [ ] On invalid credentials, an error message is shown near the input fields
- [ ] On sign-out, the session is invalidated and the user is redirected to the sign-in screen
- [ ] Accessing protected screens while not signed in redirects to the sign-in screen

#### `US-A3` Password Reset

- [ ] The sign-in screen has a "Forgot password" link
- [ ] On submitting an email address, a password reset email is sent via Resend
- [ ] An identical "email sent" response is shown for unregistered emails (to prevent enumeration attacks)
- [ ] The password reset link expires after 1 hour
- [ ] On the destination page, the user can set a new password (8+ characters, letters + digits)
- [ ] After completion, the user is redirected to the sign-in screen (no automatic sign-in)
- [ ] For users authenticated via Google, the system instead displays guidance to "change your password from your Google account settings"

### Epic B: Own Store Master

#### `US-B1` Register / Edit Own Store Master

- [ ] Only `admin` users can access the own store register / edit screen (`staff` are read-only)
- [ ] **Only one own store record (`is_own_store = true`) may exist**; an attempt to create a second returns an error
- [ ] Entering or searching for a Google Place ID displays a preview of fields fetched from the Google Places API
- [ ] Manual fields (`average_price`, `seat_count`, `menu_count`, `seat_composition`) can be entered
- [ ] Required fields (`name`, `address`, `average_price`) must be filled to save; otherwise the save is blocked
- [ ] On successful save, the data is reflected in the map, comparison table, and other visualizations as the "own store"

### Epic C: Competitor Master

#### `US-C1` Add Competitor via Google Places API (One-Click)

- [ ] Only `admin` users can access this screen
- [ ] A free-text store name input triggers a search; results are listed
- [ ] Search results are **biased toward the Vancouver area** (via `locationBias`)
- [ ] A search result can be added with one click
- [ ] On addition, Google data is auto-populated (name, address, location, hours, rating, review count, photos, price level, categories)
- [ ] Stores already added (same `google_place_id`) cannot be registered again (an error is shown)

#### `US-C2` Edit Competitor Manual Fields

- [ ] Only `admin` users can access the edit screen
- [ ] Manual fields (`average_price`, `seat_count`, `menu_count`, `seat_composition`, SNS handles) can be edited
- [ ] A "Re-sync Google data" button refetches the latest Google information
- [ ] If the required `average_price` is missing, save is blocked
- [ ] Save success is reflected in visualizations

### Epic D: Observation Records

#### `US-D1` Input Observation Record

- [ ] Authenticated users (both `admin` and `staff`) can access this screen
- [ ] The user selects a target store (own store or competitor) and records an observation
- [ ] Required fields: `observed_at`, `observation_duration_minutes`, `customer_count`, `gender_ratio_male`, `gender_ratio_female`, `age_distribution`, `observed_usage_scene`, `weather`
- [ ] If `gender_ratio_male + gender_ratio_female ≠ 100`, save is blocked
- [ ] If the sum of `age_distribution` ≠ 100, save is blocked
- [ ] On save, the **`observer_id` is automatically linked to the currently signed-in user**
- [ ] On save, **`day_of_week` and `time_band` are automatically derived from `observed_at`**
- [ ] On save, the **Google snapshot fields (`google_rating_snapshot`, `google_review_count_snapshot`) are recorded with the current Google values**

### Epic E: Map Visualization

#### `US-E1` Display Competitor Map

- [ ] Authenticated users can access this screen
- [ ] The own store is displayed with a **dedicated pin color / icon** for emphasis
- [ ] Competitor stores are displayed with a different pin color / icon
- [ ] The initial map view **automatically zooms to fit all pins**
- [ ] If no stores are registered, an appropriate message and link to add stores is shown

#### `US-E2` Display Store Detail on Pin Click

- [ ] Clicking a pin opens a popup or side panel
- [ ] At minimum, the detail includes: `name`, `address`, `business_hours`, `google_rating`, `google_review_count`, `average_price`, `seat_count`, and at least one photo
- [ ] The detail offers an "Add to comparison" action (a path to `US-G1`)

### Epic F: Time Series Chart

#### `US-F1` Time Series Chart of Customer Count and Estimated Revenue

- [ ] Authenticated users can access this screen
- [ ] The user can select the own store + 1 to 3 competitor stores (max 4) for comparison
- [ ] A time range switcher is provided (last 1 week / 1 month / 3 months / custom range)
- [ ] A metric switcher is provided (customer count / estimated revenue toggle)
- [ ] Periods with no data are displayed as blanks (not as zero, to avoid misinterpretation)
- [ ] A legend is shown so own store and competitors are visually distinguishable

### Epic G: Comparison Table

#### `US-G1` Item-by-Item Comparison Table

- [ ] Authenticated users can access this screen
- [ ] The user can select the own store + 1 to 3 competitor stores (max 4) for comparison
- [ ] At minimum, comparison items include: `average_price`, `seat_count`, `menu_count`, `seat_composition`, `business_hours`, `google_rating`, `google_review_count`, `google_categories`
- [ ] Differences between own store and competitors are visually emphasized (color / arrow / highlight)
- [ ] An item-selection UI is provided to add/remove columns (a fixed set is acceptable for MVP)

---

## 5. Out of Scope (MVP)

Items explicitly excluded from the MVP, organized into three categories.

- **A. Deferred features** — Features that are valuable and may be added after MVP release
- **B. Out of product direction** — Items intentionally excluded by product design philosophy from the outset
- **C. Deferred non-functional requirements** — Performance and operational refinements, deferred to post-MVP

### A. Deferred Features

| Item | Related ID / Reference |
| --- | --- |
| Delete competitor | `US-C3` |
| Edit observation record (staff: own records) | `US-D2` |
| Edit / delete observation record (admin: any) | `US-D3` |
| Time series chart of Google review count / rating | `US-F2` |
| CSV export of comparison table | Acceptance criteria discussion |
| User management UI (invite / change role / delete) | Auth discussion (`admin` is set via direct SQL) |
| User-customizable comparison columns (MVP uses a fixed set) | `US-G1` |
| Radar chart visualization | Visualization selection |
| Bulk import of historical data (CSV) | — |

### B. Out of Product Direction

Items intentionally excluded by the product's design philosophy. **Permanently out of scope.**

- **Data collection operations**
  - Field investigator dispatch / hiring / training
  - Observation data quality assurance processes
  - Automated data collection (including Popular Times scraping; not exposed via the official Google API)
- **Platform expansion**
  - Multi-tenant support (multiple owners on the same instance)
  - Multi-store expansion (own store is fixed at one)
  - Multi-currency support (CAD only)
  - Native mobile apps (iOS / Android)
- **Authentication providers**
  - OAuth via Twitter / X, Facebook, GitHub, Apple, or other SNS providers (only email + Google)

### C. Deferred Non-Functional Requirements

- Real-time sync (WebSocket / Server-Sent Events)
- Offline support / PWA
- Push notifications
- Advanced performance optimization (CDN strategy, edge caching, etc.)
- SEO (not needed because of the auth requirement, noted for clarity)
- Audit log UI (logs are stored in DB but not surfaced in UI)
- Backup and restore (an operational concern for later)

### Top Post-MVP Priorities

After the 3-day MVP is shipped, the following are the highest-priority candidates for additional development. They reflect strong real-world need and add credibility ("a roadmap shaped by real users") to the portfolio.

- **Internationalization (Japanese + Korean UI)**
  - **Background**: The target store's owner is Korean. Field investigators may include Japanese native speakers
  - **Estimated effort**: ~1 day to introduce the i18n framework and externalize all UI strings
- **Excel / spreadsheet export**
  - **Background**: Management meetings traditionally rely on Excel / Google Sheets for consolidating information; copy-paste is inefficient
  - **Estimated effort**: ~0.5 day to output xlsx for comparison tables and observation data
  - **Distinguished from the MVP-deferred plain CSV export** in (A) — this is a polished, formatted export

---

## 6. Release Criteria / Definition of Done

Hard requirements for declaring the MVP "released" within the 3-day window. The MVP is not considered complete unless all of these are satisfied.

### Functional

- [ ] All 10 MVP user stories are implemented and meet their acceptance criteria
- [ ] Competitor search and addition via Google Places API works
- [ ] The full authentication flow (sign-up, email verification, sign-in, sign-out, password reset) works end-to-end
- [ ] Verification and password reset emails are actually delivered via Resend

### Environment

- [ ] Deployed to production; the target users can access the URL
- [ ] All features work as expected in the latest version of Chrome

### Demo

- [ ] The application can be demonstrated with seed data already loaded (own store ×1, competitors ×3, observations ×10+)

### Documentation

- [ ] The README documents how to run, deploy, and which environment variables are required
