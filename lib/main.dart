import 'package:flutter/material.dart';
import 'package:kakao_maps_flutter/kakao_maps_flutter.dart'; // Kakao Map SDK
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';  // Kakao Login etc.

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/bus_status_screen.dart';

import 'screens/bus_application/bus_search_screen.dart';
import 'screens/bus_application/bus_application_status_screen.dart';
import 'screens/bus_application/bus_application_screen.dart';

import 'theme/app_themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kakao Map SDK 초기화 (네이티브 앱 키)
  await KakaoMapsFlutter.init('7388c32d83d1c4266b0af485cefbacca');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '꿈마중 버스',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.light, // 라이트 테마 기본
      initialRoute: '/login',     // develop 브랜치 정책 유지
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),

        // 버스 신청/조회 플로우 (develop)
        '/bus-search': (context) => BusSearchScreen(),
        '/bus-application-status': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BusApplicationStatusScreen(
            regionId: args?['regionId'],
            regionName: args?['regionName'],
            center: args?['center'],
          );
        },
        '/bus-application': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return BusApplicationScreen(
            regionId: args?['regionId'] ?? '',
            regionName: args?['regionName'] ?? '',
            center: args?['center'] ?? {'latitude': 0.0, 'longitude': 0.0},
          );
        },

        // 버스 현황 지도 (feature/bus-status)
        '/bus-status': (context) => const BusStatusScreen(),
      },
    );
  }
}
