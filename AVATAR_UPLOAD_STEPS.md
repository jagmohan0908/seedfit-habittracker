## Seedfit – Avatar Upload (Pre‑signed S3 URL) – Step by Step

This file shows **exact steps** you must do to test and use the new avatar upload flow.

Backend base URL (Render):

- `https://seedfit-habittracker.onrender.com`

S3 bucket:

- `eternity-apps` in region `ap-south-1`

---

## 1. Test backend flow in Postman (RECOMMENDED)

Do these 4 requests in order, using the same `user_id` each time (example: `"test-user-123"`).

### 1.1 Get pre‑signed S3 upload URL

- **Method**: `POST`
- **URL**: `https://seedfit-habittracker.onrender.com/api/v1/users/profile/avatar-upload-url`
- **Headers**:
  - `Content-Type: application/json`
- **Body → raw → JSON**:

```json
{
  "user_id": "test-user-123",
  "avatar_mime_type": "image/jpeg"
}
```

#### Expected response

- `success: true`
- `upload_url`: long signed S3 URL (for PUT)
- `file_url`: clean S3 URL (public URL of the image)

Copy:

- `upload_url` → use in step 1.2  
- `file_url` → use in step 1.3

---

### 1.2 Upload image directly to S3 using upload_url

In Postman:

- **Method**: `PUT`
- **URL**: paste the `upload_url` from step 1.1 (exactly as returned).
- **Headers**:
  - `Content-Type: image/jpeg`
- **Body**:
  - Select **binary**
  - Choose a real image file (e.g. `avatar.jpg`).

Send the request.

- If status is **200** or **201**, upload to S3 is successful.
- In AWS console → S3 → bucket `eternity-apps` → folder `user-profiles/`, you should see:
  - `user-profiles/test-user-123.jpg`

---

### 1.3 Notify backend to save avatar_url in Postgres

Now tell the backend which S3 URL belongs to this user.

- **Method**: `PUT`
- **URL**: `https://seedfit-habittracker.onrender.com/api/v1/users/profile`
- **Headers**:
  - `Content-Type: application/json`
- **Body → raw → JSON**:

```json
{
  "user_id": "test-user-123",
  "avatar_url": "PASTE_file_url_FROM_STEP_1_1",
  "name": "Test User",
  "email": "test@example.com",
  "phone": "+911234567890"
}
```

Replace `"PASTE_file_url_FROM_STEP_1_1"` with the **exact** `file_url` from step 1.1.

#### Expected response

```json
{
  "success": true,
  "message": "Profile updated",
  "avatar_url": "https://eternity-apps.s3.ap-south-1.amazonaws.com/user-profiles/test-user-123.jpg"
}
```

This means:

- Postgres table `user_profiles` now has `avatar_url` set to the S3 URL.

---

### 1.4 Confirm profile data is correct

- **Method**: `GET`
- **URL**: `https://seedfit-habittracker.onrender.com/api/v1/users/profile/test-user-123`

#### Expected response

```json
{
  "success": true,
  "data": {
    "user_id": "test-user-123",
    "name": "Test User",
    "email": "test@example.com",
    "phone": "+911234567890",
    "avatar_url": "https://eternity-apps.s3.ap-south-1.amazonaws.com/user-profiles/test-user-123.jpg",
    "created_at": "...",
    "updated_at": "..."
  }
}
```

If this works, the **backend + S3 + Postgres flow is 100% correct**.

---

## 2. How Flutter app uses this (high level)

You **do not** need to remember all code. Just understand the flow:

1. Flutter calls:

   - `POST /api/v1/users/profile/avatar-upload-url`
   - Uses `user.id` from the logged‑in user and passes `avatar_mime_type`.

2. Flutter receives:

   - `upload_url` (for PUT)
   - `file_url` (public S3 URL)

3. Flutter uploads the selected image:

   - **PUT upload_url** with raw image bytes (`Content-Type: image/jpeg`).

4. After PUT is success, Flutter calls:

   - `PUT /api/v1/users/profile` with:
     - `user_id`
     - `avatar_url = file_url` from step 2
     - plus name / email / phone

5. Backend saves `avatar_url` into Postgres.

6. Later, app calls:

   - `GET /api/v1/users/profile/:userId`
   - Uses the returned `avatar_url` to display the image.

---

## 3. Quick troubleshooting

- If **step 1.1** fails:
  - Check AWS env vars on Render: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `S3_BUCKET_NAME`.

- If **step 1.2** fails:
  - Make sure:
    - you use **PUT** (not POST),
    - `Content-Type` matches the mime type,
    - bucket CORS allows `PUT` from your client.

- If **step 1.3** or **1.4** fails:
  - Check Postgres connection (`/api/health`),
  - Re‑check DB env vars on Render (`DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`).

