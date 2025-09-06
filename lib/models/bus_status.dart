enum BusRunState {
  inService,  // 이동중
  dwell,      // 정차중
  before,     // 운행전
  finished,   // 운행종료
}

class BusStatusAtStop {
  final int stopId;
  final BusRunState state;
  final Duration? etaToArrive;      // 도착까지 남은 시간
  final Duration? remainingDwell;   // 정차 남은 시간

  BusStatusAtStop({
    required this.stopId,
    required this.state,
    this.etaToArrive,
    this.remainingDwell,
  });
}
