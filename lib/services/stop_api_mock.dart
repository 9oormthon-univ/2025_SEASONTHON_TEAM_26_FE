import 'dart:math';
import '../models/bus_stop.dart';
import 'stop_api.dart';

class MockStopApi implements StopApi {
  final _rand = Random();
  @override
  Future<List<Stop>> fetchNearbyStops({
    required double lat,
    required double lng,
    int radiusMeters = 1000,
    String? dow,
    String? keyword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // 중심 주변에 6개 정도 가짜 정류장 생성
    return List.generate(6, (i) {
      final dx = (_rand.nextDouble() - 0.5) * 0.01; // ~1km
      final dy = (_rand.nextDouble() - 0.5) * 0.01;
      return Stop(
        stopId: 1000 + i,
        regionId: 1,
        name: keyword?.isNotEmpty == true ? '$keyword 정류장 #$i' : '샘플정류장 #$i',
        lat: lat + dx,
        lng: lng + dy,
      );
    });
  }
}
