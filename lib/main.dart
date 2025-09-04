import 'package:flutter/material.dart';
import 'package:kakao_maps_flutter/kakao_maps_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/bus_status_screen.dart';
import 'screens/bus_application_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 카카오 네이티브 앱 키로 SDK 초기화 (Kakao Developers 콘솔에서 발급)
  await KakaoMapsFlutter.init('7388c32d83d1c4266b0af485cefbacca');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '꿈마중 버스',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      initialRoute: '/bus-status',
      routes: {
        // '/login': (context) => const LoginScreen(),
        // '/signup': (context) => const SignupScreen(),
        '/bus-status': (context) => const BusStatusScreen(),
        // '/bus-application': (context) => const BusApplicationScreen(),
      },
    );
  }
}
