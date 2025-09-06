class BusApplicationSummary {
  final String regionId;
  final String regionName;
  final int capacity;
  final int appliedCount;
  final int remaining;
  final double fillRatePercent;

  BusApplicationSummary({
    required this.regionId,
    required this.regionName,
    required this.capacity,
    required this.appliedCount,
    required this.remaining,
    required this.fillRatePercent,
  });

  // Getter for totalApplications (alias for appliedCount)
  int get totalApplications => appliedCount;
  
  // Getter for approvedApplications (mock data - 실제로는 API에서 받아와야 함)
  int get approvedApplications => (appliedCount * 0.8).round();
  
  // Getter for pendingApplications (mock data - 실제로는 API에서 받아와야 함)
  int get pendingApplications => (appliedCount * 0.15).round();
  
  // Getter for rejectedApplications (mock data - 실제로는 API에서 받아와야 함)
  int get rejectedApplications => (appliedCount * 0.05).round();

  factory BusApplicationSummary.fromJson(Map<String, dynamic> json) {
    return BusApplicationSummary(
      regionId: json['regionId'],
      regionName: json['region_name'],
      capacity: json['capacity'],
      appliedCount: json['appliedCount'],
      remaining: json['remaining'],
      fillRatePercent: json['fillRatePercent'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regionId': regionId,
      'region_name': regionName,
      'capacity': capacity,
      'appliedCount': appliedCount,
      'remaining': remaining,
      'fillRatePercent': fillRatePercent,
    };
  }
}
