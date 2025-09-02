// lib/screens/bus_status_screen.dart
import 'package:flutter/material.dart';
import '../widgets/kakao_map_view.dart';

class BusStatusScreen extends StatefulWidget {
  const BusStatusScreen({super.key});

  @override
  State<BusStatusScreen> createState() => _BusStatusScreenState();
}

class _BusStatusScreenState extends State<BusStatusScreen> {
  final GlobalKey<KakaoMapViewState> _mapKey = GlobalKey<KakaoMapViewState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('버스 현황')),
      body: Stack(
        children: [
          // ① 지도
          Positioned.fill(
            child: KakaoMapView(key: _mapKey),
          ),

          // ② 상단 정보 패널(예시)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _TopInfoCard(),
          ),

          // ③ 하단 시트/패널(예시)
          Positioned(
            left: 0,
            right: 0,
            bottom: 90,
            child: _BottomStatusBar(),
          ),
        ],
      ),

      // ④ 현위치 버튼(부모에서 제어)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mapKey.currentState?.goToMyLocation(),
        icon: const Icon(Icons.my_location),
        label: const Text('현위치'),
      ),
    );
  }
}

// ───────────────── 샘플 UI 위젯들 ─────────────────

class _TopInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: const [
            Icon(Icons.directions_bus_filled),
            SizedBox(width: 8),
            Text('가장 가까운 정류장: 샘플 정류장'),
          ],
        ),
      ),
    );
  }
}

class _BottomStatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: const [
            Icon(Icons.schedule),
            SizedBox(width: 8),
            Expanded(child: Text('다음 버스: 08:10 / 08:40 / 09:10')),
          ],
        ),
      ),
    );
  }
}
