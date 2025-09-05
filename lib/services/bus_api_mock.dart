import 'dart:math';
import '../models/bus.dart';
import '../models/bus_status.dart';
import '../models/bus_stop.dart';
import 'bus_api.dart';

class MockBusApi implements BusApi {
  final _rand = Random();

  // ───────── 지역/버스/정류장 목업 ─────────
  // 지역: 천안(1), 아산(2), 김포 마산동(3)
  final _regions = <int, Map<String, dynamic>>{
    1: {'name': '천안시', 'centerLat': 36.815, 'centerLng': 127.113},
    2: {'name': '아산시', 'centerLat': 36.792, 'centerLng': 127.004},
    3: {'name': '김포시 마산동', 'centerLat': 37.6210, 'centerLng': 126.8230}, // 📍김포 마산동 근처
  };

  // regionId -> buses
  final Map<int, List<Bus>> _buses = {};

  // courseId -> stops
  final Map<int, List<Stop>> _courseStops = {};

  // stopId -> regionId (빠른 조회용)
  final Map<int, int> _stopRegion = {};

  // stopId -> courses 포함 (역참조; 정류장에서 운행하는 버스 찾기)
  final Map<int, List<Bus>> _busesByStop = {};

  // 버스의 "현재 정류장" (목업: 실행 중 랜덤 갱신)
  final Map<int, int?> _busCurrentStopId = {};

  MockBusApi() {
    // 천안
    final bus101 = Bus(busId: 101, regionId: 1, courseId: 1001, name: '천안 순환 A', centerLat: 36.815, centerLng: 127.113);
    _buses[1] = [bus101];
    _courseStops[1001] = [
      Stop(stopId: 1, regionId: 1, name: '천안시청', lat: 36.8152, lng: 127.1127),
      Stop(stopId: 2, regionId: 1, name: '신부동 터미널', lat: 36.8190, lng: 127.1540),
      Stop(stopId: 3, regionId: 1, name: '천안역', lat: 36.8101, lng: 127.1467),
      Stop(stopId: 4, regionId: 1, name: '청수호수공원', lat: 36.7939, lng: 127.1227),
      Stop(stopId: 5, regionId: 1, name: '단국대병원', lat: 36.8403, lng: 127.1792),
    ];

    // 아산
    final bus201 = Bus(busId: 201, regionId: 2, courseId: 2001, name: '아산 순환 B', centerLat: 36.792, centerLng: 127.004);
    _buses[2] = [bus201];
    _courseStops[2001] = [
      Stop(stopId: 11, regionId: 2, name: '아산시청', lat: 36.7921, lng: 127.0043),
      Stop(stopId: 12, regionId: 2, name: '온양온천역', lat: 36.7808, lng: 127.0011),
      Stop(stopId: 13, regionId: 2, name: '탕정면사무소', lat: 36.8166, lng: 127.0592),
      Stop(stopId: 14, regionId: 2, name: '배방역', lat: 36.7772, lng: 127.0529),
      Stop(stopId: 15, regionId: 2, name: '둔포중심', lat: 36.8735, lng: 127.0610),
    ];

    // ✅ 김포 마산동(요청 2번)
    final bus301 = Bus(busId: 301, regionId: 3, courseId: 3001, name: '김포 꿈마중 월요일 코스', centerLat: 37.640, centerLng: 126.636);
    _buses[3] = [bus301];
    _courseStops[3001] = [
      Stop(stopId: 31, regionId: 3, name: '구래역', lat: 37.6453, lng: 126.6286),
      Stop(stopId: 32, regionId: 3, name: '모아엘가아파트', lat: 37.6379, lng: 126.6307),
      Stop(stopId: 33, regionId: 3, name: '은여울초등학교', lat: 37.6382, lng: 126.6406),
      Stop(stopId: 34, regionId: 3, name: '마산역', lat: 37.6408, lng: 126.6443),
      Stop(stopId: 35, regionId: 3, name: '한강신도시 마산동 주민센터', lat: 37.6436, lng: 126.6411),
    ];

    // 역참조/지역 맵 구성 + 정류장별 버스 매핑
    for (final entry in _courseStops.entries) {
      final courseId = entry.key;
      final stops = entry.value;
      final bus = _buses.values.expand((e) => e).firstWhere((b) => b.courseId == courseId);
      for (final s in stops) {
        _stopRegion[s.stopId] = s.regionId;
        _busesByStop.putIfAbsent(s.stopId, () => []).add(bus);
      }
    }

    // 버스 현재 위치(정류장) 랜덤 초기화
    _busCurrentStopId[101] = 2;
    _busCurrentStopId[201] = 14;
    _busCurrentStopId[301] = 34;
  }

  // ────────── 인터페이스 구현 ──────────
  @override
  Future<Stop?> fetchNearestStop({
    required double lat,
    required double lng,
    int maxDistanceMeters = 800,
  }) async {
    await Future.delayed(const Duration(milliseconds: 160));
    Stop? best;
    double bestD = 1e9;
    for (final list in _courseStops.values) {
      for (final s in list) {
        final d = _haversine(lat, lng, s.lat, s.lng);
        if (d < bestD) {
          bestD = d;
          best = s;
        }
      }
    }
    return bestD <= maxDistanceMeters ? best : null;
  }

  @override
  Future<List<Bus>> fetchBusesByStop(int stopId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return List<Bus>.from(_busesByStop[stopId] ?? const []);
  }

  @override
  Future<List<Bus>> searchBusesByRegion(String keyword) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final key = keyword.trim();
    if (key.isEmpty) return [];
    final matchedRegionIds = _regions.entries
        .where((e) => e.value['name'].toString().contains(key))
        .map((e) => e.key)
        .toList();
    final out = <Bus>[];
    for (final id in matchedRegionIds) {
      out.addAll(_buses[id] ?? const []);
    }
    return out;
  }

  @override
  Future<List<Stop>> fetchRouteStops(int courseId) async {
    await Future.delayed(const Duration(milliseconds: 180));
    return _courseStops[courseId] ?? [];
  }

  @override
  Future<BusRunState> fetchBusRunState(int busId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    // 간단 랜덤
    final r = _rand.nextInt(4);
    return [BusRunState.inService, BusRunState.dwell, BusRunState.before, BusRunState.finished][r];
  }

  @override
  Future<int?> fetchBusCurrentStopId(int busId) async {
    await Future.delayed(const Duration(milliseconds: 80));
    // 가끔 움직이게 랜덤 이동
    if (_rand.nextBool()) {
      final bus = _buses.values.expand((e) => e).firstWhere((b) => b.busId == busId);
      final stops = _courseStops[bus.courseId]!;
      final cur = _busCurrentStopId[busId];
      final idx = cur == null ? 0 : (stops.indexWhere((s) => s.stopId == cur) + 1) % stops.length;
      _busCurrentStopId[busId] = stops[idx].stopId;
    }
    return _busCurrentStopId[busId];
  }

  @override
  Future<BusStatusAtStop> fetchBusStatusAtStop({
    required int busId,
    required int stopId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 160));
    // 현재 정류장과 비교해 간단히 상태 생성
    final cur = await fetchBusCurrentStopId(busId);
    if (cur == stopId) {
      return BusStatusAtStop(stopId: stopId, state: BusRunState.dwell, remainingDwell: const Duration(minutes: 4));
    }
    // 완전 임의 로직 (목업)
    final r = _rand.nextInt(3);
    if (r == 0) {
      return BusStatusAtStop(stopId: stopId, state: BusRunState.inService, etaToArrive: const Duration(minutes: 6));
    } else if (r == 1) {
      return BusStatusAtStop(stopId: stopId, state: BusRunState.before);
    } else {
      return BusStatusAtStop(stopId: stopId, state: BusRunState.finished);
    }
  }

  // ────────── util: 거리(m) ──────────
  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double d) => d * pi / 180.0;
}
