class Region {
  final String regionId;
  final String name;
  final RegionCenter center;

  Region({
    required this.regionId,
    required this.name,
    required this.center,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      regionId: json['regionId'],
      name: json['name'],
      center: RegionCenter.fromJson(json['center']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regionId': regionId,
      'name': name,
      'center': center.toJson(),
    };
  }
}

class RegionCenter {
  final double lat;
  final double lng;

  RegionCenter({
    required this.lat,
    required this.lng,
  });

  // Getter for latitude (alias for lat)
  double get latitude => lat;
  
  // Getter for longitude (alias for lng)
  double get longitude => lng;

  factory RegionCenter.fromJson(Map<String, dynamic> json) {
    return RegionCenter(
      lat: json['lat'].toDouble(),
      lng: json['lng'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}

class RegionSearchResponse {
  final List<Region> items;

  RegionSearchResponse({
    required this.items,
  });

  factory RegionSearchResponse.fromJson(Map<String, dynamic> json) {
    return RegionSearchResponse(
      items: (json['items'] as List)
          .map((item) => Region.fromJson(item))
          .toList(),
    );
  }
}
