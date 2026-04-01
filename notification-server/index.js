require("dotenv").config();
const express = require("express");
const cors = require("cors");
const admin = require("firebase-admin");

const app = express();
app.use(cors());
app.use(express.json());

// Initialize Firebase Admin (no Blaze - we only use Firestore read + FCM send)
let initialized = false;
if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
  try {
    const cred = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
    admin.initializeApp({ credential: admin.credential.cert(cred) });
    initialized = true;
  } catch (e) {
    console.error("Invalid FIREBASE_SERVICE_ACCOUNT_JSON:", e.message);
  }
} else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  admin.initializeApp();
  initialized = true;
}

if (!initialized) {
  console.error(
    "Set FIREBASE_SERVICE_ACCOUNT_JSON or GOOGLE_APPLICATION_CREDENTIALS"
  );
  process.exit(1);
}

const db = admin.firestore();
const messaging = admin.messaging();

// POST /send-notification
// Body: { receiverId, senderId, senderEmail, message }
app.post("/send-notification", async (req, res) => {
  try {
    const { receiverId, senderId, senderEmail, message } = req.body || {};
    if (!receiverId || !senderId) {
      return res.status(400).json({
        ok: false,
        error: "receiverId and senderId required",
      });
    }

    const userDoc = await db.collection("users").doc(receiverId).get();
    if (!userDoc.exists) {
      return res.status(404).json({ ok: false, error: "Receiver not found" });
    }

    const fcmToken = userDoc.data().fcmToken;
    if (!fcmToken) {
      return res.status(404).json({
        ok: false,
        error: "Receiver has no FCM token",
      });
    }

    const payload = {
      notification: { title: "New Message", body: message || "" },
      data: {
        receiverId: String(senderId),
        receiverEmail: String(senderEmail || ""),
      },
      token: fcmToken,
    };

    await messaging.send(payload);
    console.log("Notification sent to", receiverId);
    return res.json({ ok: true });
  } catch (err) {
    console.error("Send notification error:", err);
    return res
      .status(500)
      .json({ ok: false, error: err.message || "Failed to send" });
  }
});

app.get("/", (req, res) => res.json({ service: "we-chat-notification", status: "ok" }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log("Notification server on port", PORT));
