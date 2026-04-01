import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/routes_name.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  RxBool isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _tokenListenerAdded = false;

  //--------------------------------------------
  // REQUEST NOTIFICATION PERMISSION
  //--------------------------------------------
  Future<void> requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(alert: true,badge: true,sound: true);
  }

  //--------------------------------------------
  // SAVE USER TO FIRESTORE + FCM TOKEN
  //--------------------------------------------
  Future<void> saveUserToFirestore(User user) async {
    final docRef = _firestore.collection("users").doc(user.uid);
    final snapshot = await docRef.get();

    // Get FCM Token
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    await docRef.set({
      "uid": user.uid,
      "email": user.email,
      "fcmToken": fcmToken, // IMPORTANT (single token for Cloud Function)
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    /// Listen for token refresh only once
    if (!_tokenListenerAdded) {
      _tokenListenerAdded = true;

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await docRef.set({
          "fcmToken": newToken,
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    }
  }

  //--------------------------------------------
  // LOGIN FUNCTION
  //--------------------------------------------
  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email & Password required");
      return;
    }

    try {
      isLoading.value = true;

      await requestPermission();

      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      await saveUserToFirestore(userCredential.user!);

      Get.offAllNamed(RoutesName.chatListScreen);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Login Failed", e.message ?? e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  //--------------------------------------------
  // REGISTER FUNCTION
  //--------------------------------------------
  Future<void> register() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email & Password required");
      return;
    }

    try {
      isLoading.value = true;

      await requestPermission();

      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      await saveUserToFirestore(userCredential.user!);

      Get.offAllNamed(RoutesName.chatListScreen);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Register Failed", e.message ?? e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/routes_name.dart';

class LoginController extends GetxController {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  RxBool isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> login() async {

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Error", "Email & Password required");
      return;
    }

    try {

      isLoading.value = true;

      UserCredential credential =
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User user = credential.user!;

      await saveFcmToken(user.uid, user.email!);

      listenTokenRefresh(user.uid);

      Get.offAllNamed(RoutesName.chatListScreen);

    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveFcmToken(String uid, String email) async {

    String? token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await _firestore.collection("users").doc(uid).set({
      "uid": uid,
      "email": email,
      "fcmTokens": FieldValue.arrayUnion([token]),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void listenTokenRefresh(String uid) {

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _firestore.collection("users").doc(uid).set({
        "fcmTokens": FieldValue.arrayUnion([newToken]),
      }, SetOptions(merge: true));
    });
  }
}*/
