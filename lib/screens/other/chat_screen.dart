import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/services/notification_api_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverEmail;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  String get chatId {
    final currentUser = FirebaseAuth.instance.currentUser!.uid;
    List<String> ids = [currentUser, widget.receiverId];
    ids.sort();
    return ids.join("_");
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser!;
    final messageText = messageController.text.trim();

    /// message save
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .add({
      "message": messageText,
      "senderId": currentUser.uid,
      "senderEmail": currentUser.email ?? "",
      "receiverId": widget.receiverId,
      "receiverEmail": widget.receiverEmail,
      "timestamp": FieldValue.serverTimestamp(),
    });

    messageController.clear();

    /// chat list update (last message)
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatId)
        .set({
      "participants": [currentUser.uid, widget.receiverId],
      "lastMessage": messageText,
      "lastTime": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    messageController.clear();

    /// auto scroll
    Future.delayed(const Duration(milliseconds: 200), () {
      if (scrollController.hasClients) {
        scrollController.jumpTo(
          scrollController.position.maxScrollExtent,
        );
      }
    });

    /// push notification
    sendChatNotification(
      receiverId: widget.receiverId,
      senderId: currentUser.uid,
      senderEmail: currentUser.email ?? "",
      message: messageText,
    );
  }

  String formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "";
    DateTime dt = timestamp.toDate();
    return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        centerTitle: true,
      ),

      /// keyboard responsive
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: Column(
          children: [

            /// messages area
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chat_rooms')
                    .doc(chatId)
                    .collection('messages')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  var messages = snapshot.data!.docs;

                  if (messages.isEmpty) {
                    return const Center(
                      child: Text("Start Conversation"),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {

                      var msg = messages[index];
                      final data = msg.data() as Map<String, dynamic>;

                      bool isMe = data['senderId'] == currentUid;

                      final text =
                          data['message'] ??
                              data['text'] ??
                              data['messages'] ??
                              '';

                      Timestamp? time = data['timestamp'];

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth:
                            MediaQuery.of(context).size.width * 0.75,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.green.shade200
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                text,
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatTime(time),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            /// input area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black.withOpacity(.05),
                  )
                ],
              ),
              child: Row(
                children: [

                  /// textfield
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: "Type message...",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  /// send button
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.green,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: sendMessage,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}