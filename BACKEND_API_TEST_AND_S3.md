# Seedfit Backend – API & S3 Testing Guide

Base URLs:

- **Local**: `http://localhost:3000`
- **Render (production)**: `https://seedfit-habittracker.onrender.com`

In Postman, replace `{{BASE_URL}}` with one of the above.

---

## 1. Health Check

### Request

- **Method**: `GET`
- **URL**: `https://seedfit-habittracker.onrender.com/api/health`

### Example Success Response (200)

```json
{
  "status": "ok",
  "message": "Support Ticket API is running",
  "timestamp": "2026-02-11T10:00:00.000Z"
}
```

If this works, the server is UP and connected.

---

## 2. User Profile – Get Profile

Returns profile info including `avatar_url` (S3 URL) if saved.

### Request

- **Method**: `GET`
- **URL**: `{{BASE_URL}}/api/v1/users/profile/{{USER_ID}}`

Example:

```text
https://seedfit-habittracker.onrender.com/api/v1/users/profile/12345
```

### Example Success Response

```json
{
  "success": true,
  "data": {
    "user_id": "12345",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+911234567890",
    "avatar_url": "https://your-bucket.s3.ap-south-1.amazonaws.com/user-profiles/12345.jpg",
    "created_at": "2026-02-01T10:00:00.000Z",
    "updated_at": "2026-02-11T09:30:00.000Z"
  }
}
```

If profile does not exist yet:

```json
{
  "success": true,
  "data": null
}
```

---

## 3. User Profile – Update Profile + Upload Avatar (S3)

We now use a **pre-signed S3 URL** flow:

1. **Client → Backend**: ask for pre-signed upload URL.  
2. **Backend → S3**: generate pre-signed URL for `PUT` upload.  
3. **Client → S3**: upload the image file directly to S3 via that URL.  
4. **Client → Backend**: notify backend with the final S3 file URL.  
5. **Backend → Postgres**: save `avatar_url` in `user_profiles.avatar_url`.

### 3.1 Get pre-signed S3 URL (direct upload from app)

- **Method**: `POST`
- **URL**: `{{BASE_URL}}/api/v1/users/profile/avatar-upload-url`
- **Headers**: `Content-Type: application/json`
- **Body → raw → JSON**:

```json
{
  "user_id": "12345",
  "avatar_mime_type": "image/jpeg"
}
```

> `avatar_mime_type` can be `image/jpeg` or `image/png`. Default is `image/jpeg` if omitted.

### Example Success Response (get upload URL)

```json
{
  "success": true,
  "upload_url": "https://your-bucket.s3.ap-south-1.amazonaws.com/user-profiles/12345.jpg?...AWS_SIGNATURE...",
  "file_url": "https://your-bucket.s3.ap-south-1.amazonaws.com/user-profiles/12345.jpg",
  "key": "user-profiles/12345.jpg",
  "expires_in": 900,
  "message": "Use upload_url to PUT the image file directly to S3, then call PUT /api/v1/users/profile with avatar_url=file_url"
}
```

### 3.2 Client uploads image directly to S3

- The client (Flutter app) performs:
  - **Method**: `PUT`
  - **URL**: `upload_url` from previous response
  - **Headers**: `Content-Type: image/jpeg` (or matching mime type)
  - **Body**: **raw binary** image file

If this `PUT` succeeds (status `200`), the image is now stored at `file_url`.

### 3.3 Notify backend and save `avatar_url` in Postgres

Now call the existing profile endpoint, but pass the **final S3 URL** instead of base64:

- **Method**: `PUT`
- **URL**: `{{BASE_URL}}/api/v1/users/profile`
- **Headers**: `Content-Type: application/json`
- **Body → raw → JSON**:

```json
{
  "user_id": "12345",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+911234567890",
  "avatar_url": "https://your-bucket.s3.ap-south-1.amazonaws.com/user-profiles/12345.jpg"
}
```

### Example Success Response (save URL)

```json
{
  "success": true,
  "message": "Profile updated",
  "avatar_url": "https://your-bucket.s3.ap-south-1.amazonaws.com/user-profiles/12345.jpg"
}
```

> Note: The old flow using `avatar_base64` still works, but the **recommended production flow** is this pre-signed URL approach where the client uploads the file directly to S3.

### How to confirm image really uploaded to S3

1. **Check S3 bucket directly**
   - Go to AWS S3 console → your bucket (`S3_BUCKET_NAME`).
   - Open the folder `user-profiles/`.
   - You should see an object like:  
     `user-profiles/12345.jpg` or `user-profiles/12345.png`.
2. **Check backend logs (console)**
   - On local, see your terminal where `npm start` is running.
   - On Render, open the **Logs** tab for your service.
   - On **success** you should see:

     ```text
     ✅ S3 avatar upload success for user_id=12345, key=user-profiles/12345.jpg
     🔗 Avatar URL: https://your-bucket.s3.ap-south-1.amazonaws.com/user-profiles/12345.jpg
     ```

   - On **error** you will see:

     ```text
     ❌ S3 avatar upload failed for user_id=12345: <error details>
     ```

   - If S3 is not configured (missing `S3_BUCKET_NAME`), you will see:

     ```text
     S3 not configured (S3_BUCKET_NAME); skipping upload
     ```

3. **Open the URL in browser**
   - From the response `avatar_url`, open in browser.
   - If bucket policy is correct (public read or CloudFront), you should see the image.

---

## 4. Habit Tracker – Get Tracker

### Request

- **Method**: `GET`
- **URL**: `{{BASE_URL}}/api/v1/habits/tracker/{{USER_ID}}`

Example:

```text
https://seedfit-habittracker.onrender.com/api/v1/habits/tracker/12345
```

### Example Response

```json
{
  "success": true,
  "data": {
    "tracker": {
      "user_id": "12345",
      "current_streak": 7,
      "longest_streak": 14,
      "last_compliance_on": "2026-02-10",
      "streak_start_on": "2026-02-04"
    },
    "habits": [
      {
        "habit_id": "psoria_oil",
        "name": "Psoria Oil",
        "description": "Oil for Scalp and Full Body Psoriasis",
        "usage_frequency": "twice_daily",
        "gender": "both",
        "display_order": 1
      }
    ],
    "dailyCompliance": {
      "2026-02-10": {
        "date": "2026-02-10",
        "completedHabits": {
          "psoria_oil": true
        },
        "completedHabitTimes": {
          "psoria_oil_morning": true,
          "psoria_oil_evening": true
        },
        "notes": {},
        "complianceScore": 100,
        "lastUpdated": "2026-02-10T18:00:00.000Z"
      }
    },
    "rewards": []
  }
}
```

---

## 5. Habit Tracker – Save Daily Compliance

### Request

- **Method**: `POST`
- **URL**: `{{BASE_URL}}/api/v1/habits/daily-compliance`
- **Headers**: `Content-Type: application/json`
- **Body → raw → JSON**:

```json
{
  "user_id": "12345",
  "habit_id": "psoria_oil",
  "date": "2026-02-10",
  "usage_frequency": "twice_daily",
  "morning_done": true,
  "evening_done": true,
  "use1_done": false,
  "use2_done": false,
  "notes": {
    "comment": "Skin felt better"
  }
}
```

### Example Response

```json
{
  "success": true,
  "message": "Daily compliance saved",
  "data": {
    "user_id": "12345",
    "habit_id": "psoria_oil",
    "day": "2026-02-10",
    "morning_done": true,
    "evening_done": true,
    "use1_done": false,
    "use2_done": false,
    "notes": {
      "comment": "Skin felt better"
    },
    "compliance_score": 100
  }
}
```

---

## 6. Support Ticket – Create Ticket

### Request

- **Method**: `POST`
- **URL**: `{{BASE_URL}}/api/v1/support/tickets`
- **Headers**: `Content-Type: application/json`
- **Body → raw → JSON**:

```json
{
  "user_id": "12345",
  "user_name": "John Doe",
  "user_email": "john@example.com",
  "user_phone": "+911234567890",
  "subject": "Issue with habit tracker",
  "description": "My streak is not updating correctly.",
  "category": "habit_tracker",
  "priority": "medium"
}
```

### Example Response

```json
{
  "success": true,
  "data": {
    "ticket_number": "TKT-2026-000123",
    "user_id": "12345",
    "user_name": "John Doe",
    "user_email": "john@example.com",
    "user_phone": "+911234567890",
    "subject": "Issue with habit tracker",
    "description": "My streak is not updating correctly.",
    "status": "open",
    "priority": "medium",
    "category": "habit_tracker",
    "created_at": "2026-02-11T09:00:00.000Z"
  }
}
```

---

## 7. Support Ticket – List Tickets for User

### Request

- **Method**: `GET`
- **URL**: `{{BASE_URL}}/api/v1/support/tickets?user_id={{USER_ID}}`

Example:

```text
https://seedfit-habittracker.onrender.com/api/v1/support/tickets?user_id=12345
```

### Example Response

```json
{
  "success": true,
  "data": [
    {
      "ticket_number": "TKT-2026-000123",
      "user_id": "12345",
      "subject": "Issue with habit tracker",
      "status": "open",
      "priority": "medium",
      "created_at": "2026-02-11T09:00:00.000Z"
    }
  ]
}
```

---

## 8. Quick checklist

- [x] `GET /api/health` returns `status: "ok"`.
- [x] `PUT /api/v1/users/profile` with `avatar_base64`:
  - [x] Response includes `avatar_url` (S3 URL).
  - [x] S3 bucket shows object under `user-profiles/`.
  - [x] Logs show `✅ S3 avatar upload success ...`.
- [x] `GET /api/v1/habits/tracker/:userId` returns habit data (or empty if none).
- [x] `POST /api/v1/habits/daily-compliance` returns `success: true`.
- [x] `POST /api/v1/support/tickets` creates ticket.
- [x] `GET /api/v1/support/tickets?user_id=...` lists tickets.

