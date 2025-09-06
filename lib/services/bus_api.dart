import '../models/bus.dart';
import '../models/bus_status.dart';
import '../models/bus_stop.dart'; // 파일명 bus_stop.dart, 클래스는 Stop

abstract class BusApi {
  /// 0) 내 위치 기준 가까운 정류장
  Future<Stop?> fetchNearestStop({
    required double lat,
    required double lng,
    int maxDistanceMeters = 800, // 이 거리 이내 없으면 null
  });

  /// 0-1) 정류장에서 운행하는 버스 목록
  Future<List<Bus>> fetchBusesByStop(int stopId);

  /// 1) 지역 키워드로 버스 목록 검색
  Future<List<Bus>> searchBusesByRegion(String keyword);

  /// 2) 버스 선택 시 노선의 모든 정류장
  Future<List<Stop>> fetchRouteStops(int courseId);

  /// 2-1) 버스 전체 운행 상태 (이동중/정차중/운행전/운행종료)
  Future<BusRunState> fetchBusRunState(int busId);

  /// 2-2) 버스의 현재 위치(정류장 id 기준; 없으면 null)
  Future<int?> fetchBusCurrentStopId(int busId);

  /// 3) 특정 정류장에서의 버스 상태(ETA/정차 잔여 등)
  Future<BusStatusAtStop> fetchBusStatusAtStop({
    required int busId,
    required int stopId,
  });
}
