class Bus {
  final int busId;
  final int regionId;
  final int courseId;
  final String name;      // 표시용 이름 (스키마엔 없지만 프론트 표시용으로 보강)
  final double centerLat; // 지역 중심 좌표 (Regions.center_lat)
  final double centerLng; // 지역 중심 좌표 (Regions.center_lng)

  Bus({
    required this.busId,
    required this.regionId,
    required this.courseId,
    required this.name,
    required this.centerLat,
    required this.centerLng,
  });

  factory Bus.fromJson(Map<String, dynamic> j) => Bus(
        busId: j['busId'],
        regionId: j['regionId'],
        courseId: j['courseId'],
        name: j['name'] ?? '버스 #${j['busId']}',
        centerLat: (j['centerLat'] as num).toDouble(),
        centerLng: (j['centerLng'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'busId': busId,
        'regionId': regionId,
        'courseId': courseId,
        'name': name,
        'centerLat': centerLat,
        'centerLng': centerLng,
      };
}
