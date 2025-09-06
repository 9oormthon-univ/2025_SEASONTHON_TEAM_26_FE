class Region {
  final String regionId;
  final String name;
  final List<Region>? children;

  Region({
    required this.regionId,
    required this.name,
    this.children,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      regionId: json['regionId'],
      name: json['name'],
      children: json['children'] != null
          ? (json['children'] as List)
              .map((child) => Region.fromJson(child))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regionId': regionId,
      'name': name,
      if (children != null)
        'children': children!.map((child) => child.toJson()).toList(),
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
  final List<Region> regions;
  final List<Region> items; // 호환성을 위한 getter

  RegionSearchResponse({
    required this.regions,
  }) : items = regions;

  factory RegionSearchResponse.fromJson(Map<String, dynamic> json) {
    final regionsList = (json['regions'] as List)
        .map((item) => Region.fromJson(item))
        .toList();
    return RegionSearchResponse(regions: regionsList);
  }
}
