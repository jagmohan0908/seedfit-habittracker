# Support Ticket API - Node.js Backend

RESTful API for customer support ticket management system built with Node.js, Express, and PostgreSQL.

## Features

- ✅ Create support tickets
- ✅ View user tickets
- ✅ Real-time messaging
- ✅ Agent replies
- ✅ Ticket status management
- ✅ Priority management
- ✅ Ticket assignment
- ✅ Message read status

## Tech Stack

- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** PostgreSQL
- **Environment:** dotenv

## Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

Create `.env` file:

```env
PORT=3000
DB_HOST=13.202.148.229
DB_PORT=5432
DB_NAME=support_tickets
DB_USER=dba
DB_PASSWORD=your_password
NODE_ENV=development
```

### 3. Start Server

**Development:**
```bash
npm start
```

**Production (with PM2):**
```bash
pm2 start server.js --name "support-ticket-api"
```

## API Endpoints

### Health Check
- `GET /api/health` - Server health check

### Tickets
- `POST /api/v1/support/tickets` - Create ticket
- `GET /api/v1/support/tickets` - Get user tickets
- `GET /api/v1/support/tickets/:id` - Get ticket details
- `PATCH /api/v1/support/tickets/:id` - Update ticket (status, priority, assignment)

### Messages
- `POST /api/v1/support/tickets/:id/messages` - Send message
- `GET /api/v1/support/tickets/:id/messages` - Get messages
- `POST /api/v1/support/tickets/:id/messages/read` - Mark as read

## Documentation

- [Postman Testing Guide](./POSTMAN_TESTING_GUIDE.md)
- [Agent Workflow Guide](./AGENT_WORKFLOW_GUIDE.md)
- [Deployment Guide](./DEPLOYMENT_GUIDE.md)

## Database Setup

Run the SQL script to create tables:

```bash
psql -h your_host -U your_user -d your_database -f database_setup.sql
```

Or use pgAdmin to execute `database_setup.sql`

## Security

- ✅ User authentication required for all endpoints
- ✅ User can only see their own tickets
- ✅ Input validation
- ✅ SQL injection protection (parameterized queries)

## License

MIT

