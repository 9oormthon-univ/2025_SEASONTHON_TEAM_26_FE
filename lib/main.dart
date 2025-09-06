import 'package:flutter/material.dart';
// import 'package:kakao_maps_flutter/kakao_maps_flutter.dart'; // Kakao Map SDK - 에뮬레이터 호환성 문제로 주석 처리
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';  // Kakao Login etc.

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/bus_status_screen.dart';

import 'screens/bus_application/bus_search_screen.dart';
import 'screens/bus_application/bus_application_status_screen.dart';
import 'screens/bus_application/bus_application_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kakao SDK 초기화 (네이티브 앱 키)
  KakaoSdk.init(
    nativeAppKey: '028c043da80499d5f5a4091190738ab0',
  );

  // Kakao Map SDK 초기화 (네이티브 앱 키) - 에뮬레이터 호환성 문제로 주석 처리
  // await KakaoMapsFlutter.init('7388c32d83d1c4266b0af485cefbacca');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '꿈마중 버스',
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
