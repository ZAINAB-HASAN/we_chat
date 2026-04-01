# We Chat – Notification Server (no Blaze)

This small Node.js server sends FCM push notifications when someone sends a chat message. You can host it for **free** on Render, Railway, or similar — **no Firebase Blaze plan** needed.

## What it does

- Your Flutter app calls `POST /send-notification` with `receiverId`, `senderId`, `senderEmail`, `message`.
- The server reads the receiver’s `fcmToken` from Firestore and sends the FCM message.
- The recipient gets a notification; tapping it opens the chat with the sender.

## 1. Get a Firebase service account key

1. Open [Firebase Console](https://console.firebase.google.com) → your project → **Project settings** (gear) → **Service accounts**.
2. Click **Generate new private key**.
3. Save the JSON file. You’ll use its contents as an environment variable (see below).

## 2. Run locally

```bash
cd notification-server
npm install
```

**Option A – env file (local)**  
Create a `.env` file (do not commit it):

```env
# Paste the entire contents of the service account JSON (single line or multi-line)
FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account","project_id":"we-chat-c9b6d",...}
```

Then load it (e.g. with `dotenv`). Or run with the variable set:

**Option B – JSON file (local)**  
Save the key as `serviceAccountKey.json` in `notification-server/` and run:

```bash
# Windows PowerShell
$env:GOOGLE_APPLICATION_CREDENTIALS=".\serviceAccountKey.json"
node index.js
```

```bash
# Linux / Mac
export GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json
node index.js
```

Server runs at `http://localhost:3000`.

## 3. Deploy for free (e.g. Render)

1. Push this repo to GitHub (ensure `notification-server/` is included).
2. Go to [Render](https://render.com) → **New** → **Web Service**.
3. Connect the repo, set:
   - **Root Directory**: `notification-server`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
4. In **Environment**:
   - Add `FIREBASE_SERVICE_ACCOUNT_JSON` and paste the **entire** contents of your service account JSON (one line is fine).
5. Deploy. Note the URL (e.g. `https://we-chat-notification.onrender.com`).

## 4. Point the Flutter app to your server

In `lib/data/services/notification_api_service.dart`, set:

```dart
const String kNotificationServerBaseUrl = 'https://your-app.onrender.com';
```

Use your real Render (or other) URL, with no trailing slash.

## Summary

| Item              | Where |
|-------------------|--------|
| Server code       | `notification-server/` |
| Flutter base URL  | `lib/data/services/notification_api_service.dart` → `kNotificationServerBaseUrl` |
| Service account   | Firebase Console → Project settings → Service accounts → Generate key |

No Firebase Blaze plan is required; only the free Spark plan + this hosted server.
