# Connect your backend to Render.com (you already have PostgreSQL)

Steps to put your Node.js backend on Render and point it at **your existing Postgres**. No new database.

---

## 1. Push your code to Git

Make sure your project (including the **backend** folder) is in GitHub, GitLab, or Bitbucket.

---

## 2. Create the backend on Render

1. Go to [dashboard.render.com](https://dashboard.render.com) and log in.
2. Click **New +** → **Web Service**.
3. Connect your Git account and select the **repository** that contains this app.
4. Use these settings:

   | Field | Value |
   |-------|--------|
   | **Name** | `seedfit-api` (or any name) |
   | **Root Directory** | `backend` |
   | **Runtime** | Node |
   | **Build Command** | `npm install` |
   | **Start Command** | `npm start` |

5. Under **Environment**, click **Add Environment Variable** and add your **existing Postgres** details:

   | Key | Value (your real values) |
   |-----|---------------------------|
   | `DB_HOST` | Your Postgres host (e.g. `13.202.148.229` or your DB host) |
   | `DB_PORT` | `5432` |
   | `DB_NAME` | Your database name (e.g. `seedfit`) |
   | `DB_USER` | Your Postgres user |
   | `DB_PASSWORD` | Your Postgres password |

6. Click **Create Web Service**.

Render will build and deploy. When it shows **Live**, your backend URL is:

**`https://seedfit-api.onrender.com`** (or whatever name you chose).

---

## 3. Test

Open in a browser:

- **Health:** `https://YOUR-SERVICE-NAME.onrender.com/api/health`
- **Habit tracker:** `https://YOUR-SERVICE-NAME.onrender.com/api/v1/habits/tracker/test-user-123`

If you see JSON (e.g. `"status":"ok"`), the backend is connected to your Postgres.

---

## 4. Use in the app

In **`lib/services/habit_api_client.dart`** set:

```dart
const String kHabitApiBaseUrl = 'https://YOUR-SERVICE-NAME.onrender.com';
```

Replace `YOUR-SERVICE-NAME` with the name you gave in step 4 (e.g. `seedfit-api`).
