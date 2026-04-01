const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendChatNotification = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {

    const messageData = snapshot.data();
    const chatId = context.params.chatId;

    const senderId = messageData.senderId;
    const receiverId = messageData.receiverId;
    const text = messageData.text;

    if (!receiverId) return null;

    const userDoc = await admin.firestore()
      .collection("users")
      .doc(receiverId)
      .get();

    if (!userDoc.exists) return null;

    const token = userDoc.data().fcmToken;
    if (!token) return null;

    const payload = {
      notification: {
        title: "New Message",
        body: text,
      },
      data: {
        chatId: chatId,
        receiverId: receiverId,
        senderId: senderId,
      },
      android: {
        priority: "high",
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    };

    return admin.messaging().sendToDevice(token, payload);
  });