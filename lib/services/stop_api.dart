import '../models/bus_stop.dart';

abstract class StopApi {
  /// 현재 위치 기준 가까운 정류장 목록 반환
  Future<List<Stop>> fetchNearbyStops({
    required double lat,
    required double lng,
    int radiusMeters = 1000,
    String? dow, // MON..SUN (백엔드가 요일 필터 지원 시)
    String? keyword, // 지역/정류장 검색어
  });
}
