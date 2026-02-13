# Seedfit – Queries to View Data in the Database

Use these SQL queries in **pgAdmin**, **psql**, or any PostgreSQL client connected to your Seedfit database.

---

## 1. User profiles

```sql
-- All user profiles
SELECT * FROM user_profiles ORDER BY updated_at DESC;

-- Count of users
SELECT COUNT(*) AS total_users FROM user_profiles;

-- Users with avatar set
SELECT user_id, name, email, avatar_url, updated_at
FROM user_profiles
WHERE avatar_url IS NOT NULL AND avatar_url != '';
```

---

## 2. User habits

**How does data get into `user_habits`?**  
The app syncs habits to the backend via **POST /api/v1/habits/sync** when habits are created or updated (e.g. default habits on first load, or prescription-based habits when the user opens Daily Checklist or Progress). After sync, `GET /api/v1/habits/tracker/:userId` returns these habits. If the table is still empty, no sync has run yet (e.g. user hasn’t opened the habit tracker) or you can insert test rows manually (see below).

```sql
-- All habits (per user)
SELECT * FROM user_habits ORDER BY user_id, display_order;

-- Habits for a specific user (replace 'USER_ID' with real user_id)
SELECT * FROM user_habits WHERE user_id = 'USER_ID' ORDER BY display_order;

-- Count habits per user
SELECT user_id, COUNT(*) AS habit_count
FROM user_habits
GROUP BY user_id;
```

### Insert test data into `user_habits`

Use a `user_id` that exists in `user_profiles` (e.g. from the first query in section 1). Replace `'YOUR_USER_ID'` with the real value (e.g. `test-user-123` or your Shopify customer gid).

```sql
-- Example: two habits for one user (replace YOUR_USER_ID)
INSERT INTO user_habits (user_id, habit_id, name, description, usage_frequency, gender, display_order, created_at, updated_at)
VALUES
  ('YOUR_USER_ID', 'habit-1', 'Ovita Tablets', 'Use as directed', 'twice_daily', 'both', 0, now(), now()),
  ('YOUR_USER_ID', 'habit-2', 'Vitamin D', 'One per day', 'once_daily', 'both', 1, now(), now())
ON CONFLICT (user_id, habit_id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  usage_frequency = EXCLUDED.usage_frequency,
  updated_at = now();
```

Then run `SELECT * FROM user_habits ORDER BY user_id, display_order;` again to see the rows.

---

## 3. Habit trackers (streaks)

```sql
-- All tracker summaries
SELECT * FROM habit_trackers ORDER BY updated_at DESC;

-- Users with active streaks
SELECT user_id, current_streak, longest_streak, last_compliance_on, streak_start_on
FROM habit_trackers
WHERE current_streak > 0
ORDER BY current_streak DESC;
```

---

## 4. Daily compliance

```sql
-- Recent daily compliance (last 30 days)
SELECT id, user_id, habit_id, day, morning_done, evening_done, compliance_score, last_updated
FROM habit_daily_compliance
WHERE day >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY day DESC, user_id, habit_id;

-- Compliance for a specific user (replace 'USER_ID')
SELECT * FROM habit_daily_compliance
WHERE user_id = 'USER_ID'
ORDER BY day DESC
LIMIT 50;

-- Days with full compliance (morning + evening) per user
SELECT user_id, day, COUNT(*) AS habits_fully_done
FROM habit_daily_compliance
WHERE morning_done = TRUE AND evening_done = TRUE
GROUP BY user_id, day
ORDER BY day DESC;
```

---

## 5. Habit rewards

```sql
-- All rewards
SELECT * FROM habit_rewards ORDER BY earned_at DESC;

-- Unused rewards
SELECT * FROM habit_rewards WHERE is_used = FALSE AND (expires_at IS NULL OR expires_at > now());

-- Rewards for a specific user (replace 'USER_ID')
SELECT * FROM habit_rewards WHERE user_id = 'USER_ID' ORDER BY earned_at DESC;
```

---

## 6. Quick overview (counts)

```sql
SELECT
  (SELECT COUNT(*) FROM user_profiles)     AS users,
  (SELECT COUNT(*) FROM user_habits)        AS habits,
  (SELECT COUNT(*) FROM habit_trackers)     AS trackers,
  (SELECT COUNT(*) FROM habit_daily_compliance) AS compliance_rows,
  (SELECT COUNT(*) FROM habit_rewards)      AS rewards;
```

---

## 7. Join examples

```sql
-- User profiles with their streak info
SELECT p.user_id, p.name, p.email, t.current_streak, t.longest_streak, t.last_compliance_on
FROM user_profiles p
LEFT JOIN habit_trackers t ON p.user_id = t.user_id
ORDER BY t.current_streak DESC NULLS LAST;

-- User habits with latest compliance for today
SELECT h.user_id, h.habit_id, h.name, c.day, c.morning_done, c.evening_done
FROM user_habits h
LEFT JOIN habit_daily_compliance c ON h.user_id = c.user_id AND h.habit_id = c.habit_id AND c.day = CURRENT_DATE
ORDER BY h.user_id, h.display_order;
```

---

**Tip:** Replace `'USER_ID'` with a real `user_id` from `user_profiles` (e.g. WooCommerce/Flutter user id) when testing for one user.
