-- Seedfit backend - PostgreSQL tables
-- Run this in your Postgres database (e.g. pgAdmin). Use one database for all tables.

-- User profile (name, email, phone, avatar)
CREATE TABLE IF NOT EXISTS user_profiles (
  user_id     TEXT PRIMARY KEY,
  name        TEXT,
  email       TEXT,
  phone       TEXT,
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Habits per user
CREATE TABLE IF NOT EXISTS user_habits (
  user_id          TEXT        NOT NULL,
  habit_id         TEXT        NOT NULL,
  name             TEXT        NOT NULL,
  description      TEXT,
  usage_frequency  TEXT        NOT NULL,
  gender           TEXT        NOT NULL DEFAULT 'both',
  display_order    INT         NOT NULL DEFAULT 0,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, habit_id)
);

-- Tracker summary per user (streaks)
CREATE TABLE IF NOT EXISTS habit_trackers (
  user_id            TEXT        PRIMARY KEY,
  current_streak     INT         NOT NULL DEFAULT 0,
  longest_streak     INT         NOT NULL DEFAULT 0,
  last_compliance_on DATE,
  streak_start_on    DATE,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Daily compliance per habit
CREATE TABLE IF NOT EXISTS habit_daily_compliance (
  id               BIGSERIAL   PRIMARY KEY,
  user_id          TEXT        NOT NULL,
  habit_id         TEXT        NOT NULL,
  day              DATE        NOT NULL,
  morning_done     BOOLEAN     NOT NULL DEFAULT FALSE,
  evening_done     BOOLEAN     NOT NULL DEFAULT FALSE,
  use1_done        BOOLEAN     NOT NULL DEFAULT FALSE,
  use2_done        BOOLEAN     NOT NULL DEFAULT FALSE,
  notes            JSONB       NOT NULL DEFAULT '{}'::jsonb,
  compliance_score NUMERIC(5,2) NOT NULL DEFAULT 0.0,
  last_updated     TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, habit_id, day)
);

-- Rewards (e.g. streak coupons)
CREATE TABLE IF NOT EXISTS habit_rewards (
  id               BIGSERIAL   PRIMARY KEY,
  user_id          TEXT        NOT NULL,
  streak_days       INT         NOT NULL,
  coupon_code      TEXT        NOT NULL,
  discount_percent NUMERIC(5,2) NOT NULL,
  earned_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at       TIMESTAMPTZ,
  is_used          BOOLEAN     NOT NULL DEFAULT FALSE,
  used_at          TIMESTAMPTZ,
  order_id         TEXT,
  FOREIGN KEY (user_id) REFERENCES habit_trackers(user_id) ON DELETE CASCADE
);
