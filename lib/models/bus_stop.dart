class Stop {
  final int stopId;
  final int regionId;
  final String name;
  final double lat;
  final double lng;

  Stop({
    required this.stopId,
    required this.regionId,
    required this.name,
    required this.lat,
    required this.lng,
  });

  factory Stop.fromJson(Map<String, dynamic> j) => Stop(
        stopId: j['stopId'],
        regionId: j['regionId'],
        name: j['stop_name'] ?? j['name'],
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'stopId': stopId,
        'regionId': regionId,
        'stop_name': name,
        'lat': lat,
        'lng': lng,
      };
}
