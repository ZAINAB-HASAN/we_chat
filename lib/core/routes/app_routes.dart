import 'package:get/get.dart';
import 'package:we_chat/core/routes/routes_name.dart';
import 'package:we_chat/screens/auth/login_screen.dart';
import 'package:we_chat/screens/auth/splash_screen.dart';
import 'package:we_chat/screens/other/chat_list_screen.dart';
import 'package:we_chat/screens/other/chat_screen.dart';
import 'package:we_chat/screens/other/home_screen.dart';

class AppRoutes {
  static List<GetPage<dynamic>> appRoutes() => [
    GetPage(name: RoutesName.splash, page: () => SplashScreen()),
    GetPage(name: RoutesName.login, page: () => LoginScreen()),
    GetPage(name: RoutesName.home, page: () => HomeScreen()),
    GetPage(
      name: RoutesName.chatScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return ChatScreen(
          receiverId: args?['receiverId'] ?? '',
          receiverEmail: args?['receiverEmail'] ?? '',
        );
      },
    ),
    GetPage(name: RoutesName.chatListScreen, page: () => ChatListScreen()),
  ];
}
