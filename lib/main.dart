import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/bus_application/bus_search_screen.dart';
import 'screens/bus_application/bus_application_status_screen.dart';
import 'screens/bus_application/bus_application_screen.dart';
import 'theme/app_themes.dart';
// import 'screens/bus_status_screen.dart';

void main() {
  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: 'Y028c043da80499d5f5a4091190738ab0',
  );
  
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
      themeMode: ThemeMode.light, // 라이트 테마를 기본으로 사용
      home: LoginScreen(), // 로그인 화면을 홈으로 설정
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
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
        //'/bus-status': (context) => BusStatusScreen(),
      },
    );
  }
}


