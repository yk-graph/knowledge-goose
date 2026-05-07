# データモデル

> Available in: [English](../data-model.md) | 日本語

## 設計方針

- **2 層構造**: `restaurants`(店舗マスタ、変動が遅い情報) + `observations`(時系列の観察レコード)
- **Google 由来 / 手入力をフィールド名で明示**: `google_*` プレフィックスが付いている field はすべて Google Places API から自動取得する想定
- **観察時点の Google データはスナップショット保存**: 後から「あの時のレビュー数」を追えるように、`observations` 側にも一部の Google データを保存する
- **想定売上は計算フィールド**(DB には保存しない): `restaurants.average_price * observations.customer_count` を表示時に計算
- **通貨は CAD**: バンクーバーのカフェ向けのため
- **nullable は `null` を採用**: SQL の NULL とのマッピング、JSON シリアライズの整合性、entity の型設計として `null` が主流のため
- **`is_own_store` フラグで自店と競合を区別**: 1 テーブルで両方を扱い、クエリを統一

---

## restaurants テーブル(店舗マスタ)

```typescript
interface Restaurant {
  id: string // UUID
  is_own_store: boolean // true は 1 件のみ(app レベルで制約)

  // 基本情報
  name: string
  address: string
  latitude: number
  longitude: number
  google_place_id: string | null // null なら API 連携なし

  // Google Places API から自動取得
  google_rating: number | null // 0.0 - 5.0
  google_review_count: number | null
  google_price_level: 0 | 1 | 2 | 3 | 4 | null // FREE - VERY_EXPENSIVE
  google_business_hours: BusinessHours | null
  google_photo_urls: string[]
  google_phone_number: string | null
  google_website_url: string | null
  google_categories: string[] // ['Cafe', 'Restaurant', ...]
  google_synced_at: string | null // ISO datetime

  // 手入力(売上計算と詳細比較に必要)
  average_price: number // CAD、必須
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
  monday: TimeRange[] | null // null = 定休日
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

## observations テーブル(時系列の観察レコード)

```typescript
interface Observation {
  id: string
  restaurant_id: string // FK -> Restaurant.id

  // 観察メタ情報
  observed_at: string // ISO datetime
  observation_duration_minutes: number
  observer_id: string // FK -> User.id(認証導入後の追加分)

  // 集客(時系列グラフの主データ)
  customer_count: number

  // 客層(主観)
  gender_ratio_male: number // 0-100 (%)
  gender_ratio_female: number // 0-100 (%)
  age_distribution: AgeDistribution

  // この時の利用シーン(主観、1 つ選択)
  observed_usage_scene: UsageScene

  // 環境(集客との相関を見るため)
  weather: Weather
  day_of_week: DayOfWeek // observed_at から派生(冗長保存、集計効率のため)
  time_band: TimeBand // observed_at から派生

  // Google データのスナップショット
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

## Enum 定義

```typescript
type UsageScene =
  | 'casual_meal' // 普段使い
  | 'business' // 商談・会議
  | 'date' // デート
  | 'family' // ファミリー
  | 'friends_group' // 友人グループ
  | 'solo_work' // 一人作業・カフェ利用
  | 'celebration' // 記念日・祝い事
  | 'late_night' // 深夜利用

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
  | 'late_night' // 22:00-
```

---

## 派生値(DB に持たない、表示時に計算)

| 値 | 計算式 |
| --- | --- |
| `estimated_revenue` | `restaurant.average_price * observation.customer_count` |
| `day_of_week` | `observed_at` から派生(冗長保存しているのは集計クエリの効率化のため) |
| `time_band` | `observed_at` から派生(同上) |

---

## バリデーション制約

- `is_own_store = true` の row は **1 件のみ**(app レベルで担保)
- `gender_ratio_male + gender_ratio_female = 100`(MVP では 2 値のみ。non-binary 等は後日検討)
- `age_distribution` の各値の合計 = 100
- `google_place_id` は null でなければ unique
- `customer_count >= 0`
- `observation_duration_minutes > 0`
- `seat_composition` の各値 >= 0
- `seat_count >= sum(seat_composition の各値)`(全席数 ≥ 内訳の合計)

### 認可制約

- **`admin` ロールのユーザーが少なくとも 1 名必要**(app レベルで保証)
- **観察記録の編集権限**: `admin` は全レコード、`staff` は `observer_id = 自分の user.id` のレコードのみ
- **マスタの編集権限**: `admin` のみ

---

## index 推奨

- `restaurants(is_own_store)` ── 自店検索が頻繁
- `restaurants(google_place_id)` ── Google データ更新時の lookup
- `observations(restaurant_id, observed_at DESC)` ── 店舗ごとの時系列取得
- `observations(observed_at)` ── 全店舗横断の時系列分析

---

## なぜ Google データのスナップショットを観察レコードに保存するのか

`observations` 側に `google_rating_snapshot` / `google_review_count_snapshot` を持つ理由:

- Google レビュー数や評価は **時間とともに変化する**
- 観察時点での Google 評価値を記録しておくことで、「Google 評価が上がった時期に客数も増えたか」のような **時系列相関分析** ができる
- マスタ側の `google_rating` / `google_review_count` は「最新値」であり、過去値は保持しない

これは意図的な denormalization。

---

## なぜ通貨を CAD で固定するのか

- 対象店舗(自店)が **バンクーバーのカフェ** に固定されているため
- 多通貨対応は scope 外。将来必要になれば `Restaurant` に `currency_code` field を追加する形で拡張可能

---

## User テーブル(認証・認可)

```typescript
interface User {
  id: string // UUID
  email: string // unique
  display_name: string
  google_account_id: string | null // Google OAuth subject ID(Google 連携時のみ)
  role: UserRole
  created_at: string
  updated_at: string
}

type UserRole = 'admin' | 'staff'
```

- `admin` ロール付与は実装者が DB を直接 SQL で更新する。MVP ではロール変更 UI を持たない
- 新規登録は全員自動的に `staff` ロール
