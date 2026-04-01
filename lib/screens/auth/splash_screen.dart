import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_chat/core/routes/routes_name.dart';
import 'package:we_chat/screens/widgets/ui_helper.dart';

import '../../data/services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (FirebaseAuth.instance.currentUser != null) {
        final pending = NotificationService.pendingNotificationData;
        if (pending != null) {
          final receiverId = pending['receiverId']?.toString().trim();
          final receiverEmail = pending['receiverEmail']?.toString().trim() ?? '';
          NotificationService.pendingNotificationData = null;
          if (receiverId != null && receiverId.isNotEmpty) {
            Get.offAllNamed(
              RoutesName.chatScreen,
              arguments: {
                'receiverId': receiverId,
                'receiverEmail': receiverEmail,
              },
            );
            return;
          }
        }
        Get.offAllNamed(RoutesName.chatListScreen);
      } else {
        Get.offAllNamed(RoutesName.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Flexible(
              flex: 3,
              child: UiHelper.CustomImage(imgUrl: 'wechat.png'),
            ),

            Spacer(),

            //Spacer(),
            UiHelper.CustomText(
              context: context,
              text: 'Made in India 🇮🇳',
              fontSize: 20,
              fontFamily: "bold",
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
      /*floatingActionButton: UiHelper. CustomButton(
        context: context,
        btnName: 'Start Messaging',
        callback: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,*/
    );
  }
}
