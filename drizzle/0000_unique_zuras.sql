CREATE TYPE "public"."day_of_week" AS ENUM('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday');--> statement-breakpoint
CREATE TYPE "public"."time_band" AS ENUM('morning', 'lunch', 'cafe', 'dinner', 'late_night');--> statement-breakpoint
CREATE TYPE "public"."usage_scene" AS ENUM('casual_meal', 'business', 'date', 'family', 'friends_group', 'solo_work', 'celebration', 'late_night');--> statement-breakpoint
CREATE TYPE "public"."user_role" AS ENUM('admin', 'staff');--> statement-breakpoint
CREATE TYPE "public"."weather" AS ENUM('sunny', 'cloudy', 'rain', 'snow');--> statement-breakpoint
CREATE TABLE "observations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"restaurant_id" uuid NOT NULL,
	"observer_id" text NOT NULL,
	"observed_at" timestamp with time zone NOT NULL,
	"observation_duration_minutes" integer NOT NULL,
	"customer_count" integer NOT NULL,
	"gender_ratio_male" integer NOT NULL,
	"gender_ratio_female" integer NOT NULL,
	"age_under_20" integer DEFAULT 0 NOT NULL,
	"age_twenties" integer DEFAULT 0 NOT NULL,
	"age_thirties" integer DEFAULT 0 NOT NULL,
	"age_forties" integer DEFAULT 0 NOT NULL,
	"age_fifties" integer DEFAULT 0 NOT NULL,
	"age_sixties_plus" integer DEFAULT 0 NOT NULL,
	"observed_usage_scene" "usage_scene" NOT NULL,
	"weather" "weather" NOT NULL,
	"day_of_week" "day_of_week" NOT NULL,
	"time_band" time_band NOT NULL,
	"google_rating_snapshot" real,
	"google_review_count_snapshot" integer,
	"notes" text DEFAULT '' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "restaurants" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"is_own_store" boolean DEFAULT false NOT NULL,
	"name" varchar(255) NOT NULL,
	"address" text NOT NULL,
	"latitude" real NOT NULL,
	"longitude" real NOT NULL,
	"google_place_id" varchar(255),
	"google_rating" real,
	"google_review_count" integer,
	"google_price_level" integer,
	"google_business_hours" jsonb,
	"google_photo_urls" text[] DEFAULT '{}' NOT NULL,
	"google_phone_number" varchar(50),
	"google_website_url" text,
	"google_categories" text[] DEFAULT '{}' NOT NULL,
	"google_synced_at" timestamp with time zone,
	"average_price" real NOT NULL,
	"seat_count" integer DEFAULT 0 NOT NULL,
	"menu_count" integer DEFAULT 0 NOT NULL,
	"counter_seats" integer DEFAULT 0 NOT NULL,
	"table_seats" integer DEFAULT 0 NOT NULL,
	"sofa_seats" integer DEFAULT 0 NOT NULL,
	"patio_seats" integer DEFAULT 0 NOT NULL,
	"instagram_handle" varchar(100),
	"twitter_handle" varchar(100),
	"tiktok_handle" varchar(100),
	"notes" text DEFAULT '' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "restaurants_google_place_id_unique" UNIQUE("google_place_id")
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" text PRIMARY KEY NOT NULL,
	"email" text NOT NULL,
	"email_verified" boolean DEFAULT false NOT NULL,
	"name" text NOT NULL,
	"image" text,
	"role" "user_role" DEFAULT 'staff' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "users_email_unique" UNIQUE("email")
);
--> statement-breakpoint
ALTER TABLE "observations" ADD CONSTRAINT "observations_restaurant_id_restaurants_id_fk" FOREIGN KEY ("restaurant_id") REFERENCES "public"."restaurants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "observations" ADD CONSTRAINT "observations_observer_id_users_id_fk" FOREIGN KEY ("observer_id") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "observations_restaurant_id_observed_at_idx" ON "observations" USING btree ("restaurant_id","observed_at");--> statement-breakpoint
CREATE INDEX "observations_observed_at_idx" ON "observations" USING btree ("observed_at");--> statement-breakpoint
CREATE INDEX "restaurants_is_own_store_idx" ON "restaurants" USING btree ("is_own_store");