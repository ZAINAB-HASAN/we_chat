import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() => Column(
          children: [
            /// EMAIL
            TextField(
              controller: controller.emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 15),

            /// PASSWORD
            TextField(
              controller: controller.passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),

            const SizedBox(height: 25),

            /// LOGIN
            ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.login,
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Login"),
            ),

            const SizedBox(height: 10),

            /// REGISTER
            ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.register,
              child: const Text("Register"),
            ),
          ],
        )),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../core/routes/routes_name.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passController = TextEditingController();

  bool isLoading = false;

  //--------------------------------------------
  // REQUEST NOTIFICATION PERMISSION
  //--------------------------------------------
  Future<void> requestPermission() async {
    await FirebaseMessaging.instance.requestPermission();
  }

  //--------------------------------------------
  // SAVE USER TO FIRESTORE + FCM TOKEN
  //--------------------------------------------
  Future<void> saveUserToFirestore(User user) async {

    final docRef =
    FirebaseFirestore.instance.collection("users").doc(user.uid);

    final snapshot = await docRef.get();

    /// Get FCM Token
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (!snapshot.exists) {

      await docRef.set({
        "uid": user.uid,
        "email": user.email,
        "fcmToken": fcmToken,
        "createdAt": FieldValue.serverTimestamp(),
      });

    } else {

      await docRef.update({
        "fcmToken": fcmToken,
      });
    }

    /// TOKEN AUTO REFRESH
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      docRef.update({
        "fcmToken": newToken,
      });
    });
  }

  //--------------------------------------------
  // LOGIN FUNCTION
  //--------------------------------------------
  Future<void> login(String email, String password) async {

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter email & password")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      await requestPermission();

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await saveUserToFirestore(userCredential.user!);

      Get.offAllNamed(RoutesName.chatListScreen);

    } on FirebaseAuthException catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login Error")),
      );

    } finally {
      setState(() => isLoading = false);
    }
  }

  //--------------------------------------------
  // REGISTER FUNCTION
  //--------------------------------------------
  Future<void> register(String email, String password) async {

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter email & password")),
      );
      return;
    }

    try {

      setState(() => isLoading = true);

      await requestPermission();

      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await saveUserToFirestore(userCredential.user!);

      Get.offAllNamed(RoutesName.chatListScreen);

    } on FirebaseAuthException catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Register Error")),
      );

    } finally {
      setState(() => isLoading = false);
    }
  }

  //--------------------------------------------
  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  //--------------------------------------------
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// EMAIL
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 15),

            /// PASSWORD
            TextField(
              controller: passController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),

            const SizedBox(height: 25),

            /// LOGIN
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                login(
                  emailController.text.trim(),
                  passController.text.trim(),
                );
              },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Login"),
            ),

            const SizedBox(height: 10),

            /// REGISTER
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                register(
                  emailController.text.trim(),
                  passController.text.trim(),
                );
              },
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
*/
