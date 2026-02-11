# Start server on localhost & connect / test API

This guide covers: starting the backend on your machine and checking that the API (health + habits) works.

---

## 1. Prerequisites

- **Node.js** installed (e.g. from [nodejs.org](https://nodejs.org)).
- **PostgreSQL** running (local or remote).
- **Database**: one database where you ran `seedfit_postgres.sql` (e.g. `seedfit`).
- **Dependencies** installed in the backend folder:
  ```bash
  cd backend
  npm install
  ```

---

## 2. Configure database (.env)

In the **backend** folder, create a file named **`.env`** (no extension).

### For local PostgreSQL

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=seedfit
DB_USER=postgres
DB_PASSWORD=your_postgres_password
PORT=3000
```

- Replace `your_postgres_password` with your Postgres user password.
- Replace `DB_NAME` with the database where you ran `seedfit_postgres.sql` (e.g. `seedfit`).
- Replace `DB_USER` with your Postgres username (often `postgres` on Windows).

### For remote PostgreSQL

Use your actual host, user, and password:

```env
DB_HOST=13.202.148.229
DB_PORT=5432
DB_NAME=seedfit
DB_USER=dba
DB_PASSWORD=your_password
PORT=3000
```

- **Important:** Use the **same** database where you created the Seedfit tables (`user_profiles`, `user_habits`, `habit_daily_compliance`, etc.), not a different DB name.

Save the file. Do **not** commit `.env` to git (it should be in `.gitignore`).

---

## 3. Start the server on localhost

In a terminal, from the **backend** folder:

```bash
cd backend
npm start
```

Or directly:

```bash
node server.js
```

You should see something like:

```
✅ Database connected successfully
🚀 Server running on: http://localhost:3000
💚 Health check: http://localhost:3000/api/health
```

- If you see **Database connection error**, fix `.env` (host, port, database name, user, password) and try again.
- Server runs on **http://localhost:3000** by default (or the `PORT` in `.env`).

Keep this terminal open while you test the API.

---

## 4. Connect and check the API

### 4.1 Health check (no DB needed for response)

**Browser:** open  
**http://localhost:3000/api/health**

**Expected:** JSON like:

```json
{
  "status": "ok",
  "message": "Support Ticket API is running",
  "timestamp": "2025-02-10T..."
}
```

**curl:**

```bash
curl http://localhost:3000/api/health
```

If this works, the server is running and you can reach it.

---

### 4.2 Habits – get tracker (GET)

Returns tracker, habits, daily compliance, and rewards for a user.  
Tables `habit_trackers`, `user_habits`, `habit_daily_compliance`, `habit_rewards` must exist in the DB you set in `.env`.

**URL:**  
`GET http://localhost:3000/api/v1/habits/tracker/USER_ID`

Replace `USER_ID` with any string (e.g. a test user id).

**Browser:**  
http://localhost:3000/api/v1/habits/tracker/test-user-123

**curl:**

```bash
curl http://localhost:3000/api/v1/habits/tracker/test-user-123
```

**Expected (empty user):**  
`200` and JSON like:

```json
{
  "success": true,
  "data": {
    "tracker": null,
    "habits": [],
    "dailyCompliance": {},
    "rewards": []
  }
}
```

If you get **500** or “relation does not exist”, the app is not connected to the database where you ran `seedfit_postgres.sql`. Fix `DB_NAME` (and connection) in `.env` and restart the server.

---

### 4.3 Habits – save daily compliance (POST)

Saves or updates one habit’s compliance for a day.  
Requires `user_habits` and `habit_daily_compliance` in the same DB.

**URL:**  
`POST http://localhost:3000/api/v1/habits/daily-compliance`

**Headers:**  
`Content-Type: application/json`

**Body (example):**

```json
{
  "user_id": "test-user-123",
  "habit_id": "ovalee-tablets",
  "date": "2025-02-10",
  "usage_frequency": "twice_daily",
  "morning_done": true,
  "evening_done": false,
  "use1_done": true,
  "use2_done": false,
  "notes": {}
}
```

**curl:**

```bash
curl -X POST http://localhost:3000/api/v1/habits/daily-compliance ^
  -H "Content-Type: application/json" ^
  -d "{\"user_id\":\"test-user-123\",\"habit_id\":\"ovalee-tablets\",\"date\":\"2025-02-10\",\"usage_frequency\":\"twice_daily\",\"morning_done\":true,\"evening_done\":false}"
```

On **PowerShell** (one line):

```powershell
curl.exe -X POST http://localhost:3000/api/v1/habits/daily-compliance -H "Content-Type: application/json" -d "{\"user_id\":\"test-user-123\",\"habit_id\":\"ovalee-tablets\",\"date\":\"2025-02-10\",\"usage_frequency\":\"twice_daily\",\"morning_done\":true,\"evening_done\":false}"
```

**Expected:**  
`200` and JSON like:

```json
{
  "success": true,
  "data": {
    "compliance": { ... }
  }
}
```

**Note:** If `user_habits` has a foreign key from `habit_daily_compliance`, you must have a row in `user_habits` for that `user_id` and `habit_id` first (e.g. insert via SQL or another API). Otherwise the POST may fail with a foreign key error.

---

### 4.4 Support tickets (optional)

- Create ticket:  
  `POST http://localhost:3000/api/v1/support/tickets`  
  (Body: `user_id`, `user_name`, `user_email`, `user_phone`, `subject`, `description`, etc.)
- List tickets:  
  `GET http://localhost:3000/api/v1/support/tickets?user_id=USER_ID`

These use the **same** server and `.env`; support ticket tables must exist in the same DB if you use them.

---

## 5. Quick checklist

| Step | Action |
|------|--------|
| 1 | Create `.env` in `backend` with `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `PORT` |
| 2 | Run `npm install` in `backend` |
| 3 | Run `npm start` in `backend` |
| 4 | Open http://localhost:3000/api/health → expect `"status":"ok"` |
| 5 | Open http://localhost:3000/api/v1/habits/tracker/test-user-123 → expect `200` and `data` with `tracker`, `habits`, `dailyCompliance`, `rewards` |
| 6 | (Optional) POST to `/api/v1/habits/daily-compliance` with a valid `user_id` / `habit_id` that exist in `user_habits` |

---

## 6. Flutter app – base URL for habit tracker

The habit tracker in the app loads and saves data via the same backend. For **local testing**:

- **Android emulator:** in `lib/services/habit_api_client.dart`, change the constant:
  ```dart
  const String kHabitApiBaseUrl = 'http://10.0.2.2:3000';
  ```
- **Physical device (same Wi‑Fi):** use your PC’s LAN IP, e.g. `http://192.168.1.5:3000`.

For **production**, leave it as:
```dart
const String kHabitApiBaseUrl = 'https://api-siya.butest.tech';
```

The app uses Hive for instant load and syncs with the backend in the background; when the user marks a habit done, data is sent to Postgres via `POST /api/v1/habits/daily-compliance`.
