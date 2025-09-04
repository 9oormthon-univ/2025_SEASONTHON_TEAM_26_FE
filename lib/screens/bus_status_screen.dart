// lib/screens/bus_status_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_maps_flutter/kakao_maps_flutter.dart' as kmap;
import '../widgets/kakao_map_view.dart';
import '../models/bus_stop.dart'; // 파일명만 bus_stop.dart, 클래스는 Stop

class BusStatusScreen extends StatefulWidget {
  const BusStatusScreen({super.key});

  @override
  State<BusStatusScreen> createState() => _BusStatusScreenState();
}

class _BusStatusScreenState extends State<BusStatusScreen> {
  final GlobalKey<KakaoMapViewState> _mapKey = GlobalKey<KakaoMapViewState>();
  final DraggableScrollableController _sheetCtrl = DraggableScrollableController();

  List<Stop> _stops = [];
  Stop? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('버스 현황'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNearBy, // 현위치 + 주변 정류장(목업) 불러오기
            tooltip: '주변 정류장 불러오기',
          ),
        ],
      ),
      body: Stack(
        children: [
          // ① 지도 (정류장 마커 탭 콜백 연결)
          Positioned.fill(
            child: KakaoMapView(
              key: _mapKey,
              onStopMarkerTap: (stop) async {
                setState(() => _selected = stop);
                // 마커 탭 시 시트를 살짝 올려서 정보가 보이게
                try {
                  await _sheetCtrl.animateTo(
                    0.30, duration: const Duration(milliseconds: 250), curve: Curves.easeOut,
                  );
                } catch (_) {}
              },
            ),
          ),

          // ② 상단 검색/필터 바 (예시)
          Positioned(
            top: 12, left: 12, right: 12,
            child: _TopSearchBar(onSubmitted: (q) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('검색어: $q')),
              );
            }),
          ),

          // ③ 하단 드래그 시트
          DraggableScrollableSheet(
            controller: _sheetCtrl,
            initialChildSize: 0.22,
            minChildSize: 0.10,
            maxChildSize: 0.45,
            builder: (context, controller) {
              return _BottomSheetContent(
                controller: controller,
                selected: _selected,
                stops: _stops,
                onTapStop: (s) async {
                  setState(() => _selected = s);
                  await _mapKey.currentState?.moveToAndMark(
                    kmap.LatLng(latitude: s.lat, longitude: s.lng),
                  );
                  try {
                    await _sheetCtrl.animateTo(
                      0.30, duration: const Duration(milliseconds: 250), curve: Curves.easeOut,
                    );
                  } catch (_) {}
                },
              );
            },
          ),
        ],
      ),

      // ④ 현위치 버튼
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _refreshNearBy,
        icon: const Icon(Icons.my_location),
        label: const Text('현위치'),
      ),
    );
  }

  /// 현위치로 이동 + 주변 정류장 불러오기 + 지도 마커 갱신
  Future<void> _refreshNearBy() async {
    // 권한/서비스 체크
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    // 현재 좌표
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    final me = kmap.LatLng(latitude: pos.latitude, longitude: pos.longitude);

    // 지도 이동 + 내 위치 마커
    await _mapKey.currentState?.moveToAndMark(me);

    // 서버에서 가까운 정류장 조회 (지금은 목)
    final stops = await _fetchNearbyStops(pos.latitude, pos.longitude);

    // 지도에 정류장 마커 반영
    await _mapKey.currentState?.setStops(stops);

    // 시트 데이터/선택 업데이트
    setState(() {
      _stops = stops;
      _selected = stops.isNotEmpty ? stops.first : null;
    });

    // 시트를 살짝 올려서 리스트가 보이게
    try {
      await _sheetCtrl.animateTo(
        0.22, duration: const Duration(milliseconds: 200), curve: Curves.easeOut,
      );
    } catch (_) {}
  }

  /// TODO: 나중에 Spring API 연결 (HttpStopApi 등으로 교체)
  Future<List<Stop>> _fetchNearbyStops(double lat, double lng) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      Stop(stopId: 1, regionId: 1, name: '시청역 사거리', lat: lat + 0.0010,  lng: lng + 0.0010),
      Stop(stopId: 2, regionId: 1, name: '덕수궁 앞',     lat: lat - 0.0012, lng: lng + 0.0006),
      Stop(stopId: 3, regionId: 1, name: '청계광장',     lat: lat + 0.0005, lng: lng - 0.0015),
    ];
  }
}

// ───────────── UI 조각들 ─────────────

class _TopSearchBar extends StatelessWidget {
  const _TopSearchBar({required this.onSubmitted});
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: '지역을 검색하세요',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: const Icon(Icons.calendar_today), // 요일 필터 자리
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  const _BottomSheetContent({
    required this.controller,
    required this.selected,
    required this.stops,
    required this.onTapStop,
  });

  final ScrollController controller;
  final Stop? selected;
  final List<Stop> stops;
  final ValueChanged<Stop> onTapStop;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      color: Theme.of(context).cardColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.black26, borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (selected != null) ...[
            Text(selected!.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _kv('지역', '천안'),             // TODO: 백엔드 연동 시 region name
            _kv('운행 요일', '월'),          // TODO
            _kv('도착 시간', '13:00'),       // TODO
            _kv('정차 시간', '1시간 30분'),    // TODO
            const SizedBox(height: 12),
          ],
          const Divider(),
          const SizedBox(height: 8),
          const Text('주변 정류장', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          for (final s in stops)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(s.name),
              subtitle: Text('(${s.lat.toStringAsFixed(5)}, ${s.lng.toStringAsFixed(5)})'),
              onTap: () => onTapStop(s),
            ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        SizedBox(width: 80, child: Text(k, style: const TextStyle(color: Colors.black54))),
        Expanded(child: Text(v, textAlign: TextAlign.right)),
      ],
    ),
  );
}
