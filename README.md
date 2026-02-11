# Seedfit Backend

Node.js API for **Seedfit app**: support tickets and habit tracker. Uses Express and PostgreSQL.

## Stack

- **Node.js** + **Express**
- **PostgreSQL** (your existing database)
- **dotenv** for config

## Setup

### 1. Install

```bash
cd backend
npm install
```

### 2. Environment

Create a `.env` file in the `backend` folder:

```env
PORT=3000
DB_HOST=your_postgres_host
DB_PORT=5432
DB_NAME=your_database_name
DB_USER=your_user
DB_PASSWORD=your_password
```

### 3. Database

Run the schema in your Postgres database (e.g. pgAdmin → Query Tool):

- Open `seedfit_postgres.sql` and execute it in your database.

### 4. Run

```bash
npm start
```

Server runs at `http://localhost:3000`. Check: [http://localhost:3000/api/health](http://localhost:3000/api/health)

## API

| Endpoint | Description |
|----------|-------------|
| `GET /api/health` | Health check |
| `POST /api/v1/support/tickets` | Create support ticket |
| `GET /api/v1/support/tickets` | List user tickets |
| `GET /api/v1/habits/tracker/:userId` | Get habit tracker data |
| `POST /api/v1/habits/daily-compliance` | Save daily habit compliance |

## Deploy on Render

See **[RENDER_DEPLOY.md](./RENDER_DEPLOY.md)** for steps. You only need to set `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` in Render environment (no new database).

## Local testing

See **[LOCALHOST_CONNECT_AND_TEST_API.md](./LOCALHOST_CONNECT_AND_TEST_API.md)** for local run and API examples.
