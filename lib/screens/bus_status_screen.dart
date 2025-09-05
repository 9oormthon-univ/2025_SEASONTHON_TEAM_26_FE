import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_maps_flutter/kakao_maps_flutter.dart' as kmap;

import '../widgets/kakao_map_view.dart';
import '../models/bus_stop.dart'; // 파일명만 bus_stop.dart, 클래스명은 Stop 유지
import '../models/bus.dart';
import '../models/bus_status.dart';
import '../services/bus_api.dart';
import '../services/bus_api_mock.dart';

class BusStatusScreen extends StatefulWidget {
  const BusStatusScreen({super.key});

  @override
  State<BusStatusScreen> createState() => _BusStatusScreenState();
}

class _BusStatusScreenState extends State<BusStatusScreen> {
  final GlobalKey<KakaoMapViewState> _mapKey = GlobalKey<KakaoMapViewState>();
  final DraggableScrollableController _sheetCtrl = DraggableScrollableController();

  final BusApi _api = MockBusApi(); // TODO: 실제 API 구현체로 교체

  // 검색/선택 상태
  final TextEditingController _searchCtl = TextEditingController();
  List<Bus> _searchResults = [];
  Bus? _selectedBus;

  // 지도/시트 상태
  List<Stop> _routeStops = [];
  Stop? _selectedStop;

  // 표시 상태
  BusRunState? _busRunState;               // 버스 전체 상태
  BusStatusAtStop? _statusAtSelectedStop;  // 특정 정류장에서의 상태
  int? _busCurrentStopId;                  // 현재 버스가 있는 정류장

  // “검색 전” 기본 화면: 내 위치 근처 정류장 + 그 정류장을 지나는 버스들
  Stop? _nearestStop;
  List<Bus> _busesAtNearestStop = [];
  bool _nearestLoading = false;
  String? _nearestError;

  // 위치 스트림
  StreamSubscription<Position>? _posSub;
  bool _nearestBusy = false; // 중복 호출 방지
  int? _lastNearestStopId;   // 동일 정류장 중복 렌더 방지
  DateTime _lastNearestAt = DateTime.fromMillisecondsSinceEpoch(0); // 스로틀용

  bool get _autoNearestEnabled => _selectedBus == null;

  @override
  void initState() {
    super.initState();
    _loadNearestStopAndBuses(); // 최초 1회
    _startNearestWatcher();     // 이후 위치 변할 때마다 자동 갱신
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    _posSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasBus = _selectedBus != null;
    final showingStopStatus = _selectedStop != null && _statusAtSelectedStop != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('버스 현황'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToMyLocation,
            tooltip: '내 위치로 이동',
          ),
        ],
      ),
      body: Stack(
        children: [
          // ① 지도
          Positioned.fill(
            child: KakaoMapView(
              key: _mapKey,
              onStopMarkerTap: (stop) async {
                // 버스 선택 전에는 마커 탭 → 전환하지 않음 (근접 모드 유지)
                if (_selectedBus == null) return;

                setState(() {
                  _selectedStop = stop;
                  _statusAtSelectedStop = null;
                });

                final st = await _api.fetchBusStatusAtStop(
                  busId: _selectedBus!.busId,
                  stopId: stop.stopId,
                );
                setState(() => _statusAtSelectedStop = st);

                // 시트 올리기
                try {
                  await _sheetCtrl.animateTo(
                    0.32,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                } catch (_) {}
              },
            ),
          ),

          // ② 상단: 지역 검색 + 결과 드롭다운 카드
          Positioned(
            top: 12, left: 12, right: 12,
            child: Column(
              children: [
                _SearchBar(
                  controller: _searchCtl,
                  onSubmitted: _onSearchRegion,
                ),
                if (_searchResults.isNotEmpty)
                  _SearchResultCard(
                    buses: _searchResults,
                    onSelectBus: _onSelectBusFromList,
                  ),
              ],
            ),
          ),

          // ③ 하단 드래그 시트
          DraggableScrollableSheet(
            controller: _sheetCtrl,
            initialChildSize: 0.20,
            minChildSize: 0.12,
            maxChildSize: 0.60,
            builder: (context, controller) {
              // (A) 검색 전: 가까운 정류장 요약 + 그 정류장을 지나는 버스 목록
              if (!hasBus) {
                return _NearestStopSheet(
                  controller: controller,
                  loading: _nearestLoading,
                  error: _nearestError,
                  stop: _nearestStop,
                  buses: _busesAtNearestStop,
                  onTapBus: _onSelectBusFromNearest,
                );
              }

              // (B) 버스 전체 상태 (정류장 미선택)
              if (hasBus && !showingStopStatus) {
                return _BusOverviewSheet(
                  controller: controller,
                  selectedBus: _selectedBus!,
                  runState: _busRunState,
                  routeStops: _routeStops,
                  currentStopId: _busCurrentStopId,
                  onTapStop: _onTapStopFromList,
                );
              }

              // (C) 특정 정류장에서의 버스 상태 (정류장 고정 + 아래 리스트만 스크롤)
              return _BusAtStopSheet(
                controller: controller,
                selectedStop: _selectedStop!,
                statusAtStop: _statusAtSelectedStop!,
                routeStops: _routeStops,
                currentStopId: _busCurrentStopId,
                onTapStop: _onTapStopFromList,
              );
            },
          ),
        ],
      ),
    );
  }

  // ───────── 위치 스트림: 가까운 정류장 자동 갱신 ─────────
  void _startNearestWatcher() async {
    // 권한/서비스 확인
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return;
    }

    _posSub?.cancel();
    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25, // 25m 이상 이동 시 이벤트
      ),
    ).listen((pos) async {
      if (!_autoNearestEnabled) return; // 버스 탐색 중이면 자동 갱신 OFF
      if (_nearestBusy) return;

      // 과도 호출 방지: 0.8초 스로틀
      final now = DateTime.now();
      if (now.difference(_lastNearestAt).inMilliseconds < 800) return;
      _lastNearestAt = now;

      _nearestBusy = true;
      try {
        final near = await _api.fetchNearestStop(
          lat: pos.latitude,
          lng: pos.longitude,
          maxDistanceMeters: 800,
        );

        if (!_autoNearestEnabled) return; // 중간에 상태 바뀌면 무시

        if (near == null) {
          if (_nearestStop != null) {
            setState(() {
              _nearestStop = null;
              _busesAtNearestStop = [];
              _nearestError = '주변 800m 이내 정류장이 없어요.';
            });
          }
          // 내 위치 파란점은 업데이트만 (카메라는 따라가지 않음)
          await _mapKey.currentState?.setMyLocation(
            kmap.LatLng(latitude: pos.latitude, longitude: pos.longitude),
            moveCamera: false,
          );
          return;
        }

        // 같은 정류장이면 UI 갱신 생략(깜빡임 방지) + 내 위치 dot만 최신화
        if (_lastNearestStopId == near.stopId) {
          await _mapKey.currentState?.setMyLocation(
            kmap.LatLng(latitude: pos.latitude, longitude: pos.longitude),
            moveCamera: false,
          );
          return;
        }
        _lastNearestStopId = near.stopId;

        // 내 위치 dot 갱신 (카메라는 그대로)
        await _mapKey.currentState?.setMyLocation(
          kmap.LatLng(latitude: pos.latitude, longitude: pos.longitude),
          moveCamera: false,
        );

        // 지도엔 근접 정류장 하나만 표시
        await _mapKey.currentState?.setStops([near]);

        // 그 정류장을 지나는 버스
        final buses = await _api.fetchBusesByStop(near.stopId);

        if (!_autoNearestEnabled) return;
        setState(() {
          _nearestStop = near;
          _busesAtNearestStop = buses;
          _nearestError = null;
        });
      } finally {
        _nearestBusy = false;
      }
    });
  }

  void _stopNearestWatcher() {
    _posSub?.cancel();
    _posSub = null;
  }

  // ───────── 검색/선택 액션 ─────────
  Future<void> _onSearchRegion(String keyword) async {
    if (keyword.trim().isEmpty) return;
    final results = await _api.searchBusesByRegion(keyword);
    setState(() => _searchResults = results);
  }

  Future<void> _onSelectBusFromList(Bus bus) async {
    // 버스 보기 시작 → 자동 근접 정류장 갱신 일시정지 + 파란 점 제거
    _stopNearestWatcher();
    await _mapKey.currentState?.clearMyLocation();

    setState(() {
      _selectedBus = bus;
      _selectedStop = null;
      _statusAtSelectedStop = null;
      _busCurrentStopId = null;
      _searchResults = [];
    });

    // 지역 중심으로 카메라 이동 (파란 점 X)
    await _mapKey.currentState?.moveCameraTo(
      kmap.LatLng(latitude: bus.centerLat, longitude: bus.centerLng),
    );

    // 노선/상태 조회
    final stops = await _api.fetchRouteStops(bus.courseId);
    await _mapKey.currentState?.setStops(stops);
    final runState = await _api.fetchBusRunState(bus.busId);
    final curStopId = await _api.fetchBusCurrentStopId(bus.busId);

    setState(() {
      _routeStops = stops;
      _busRunState = runState;
      _busCurrentStopId = curStopId;
    });

    // 시트를 살짝 올림
    try {
      await _sheetCtrl.animateTo(
        0.22,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } catch (_) {}
  }

  Future<void> _onSelectBusFromNearest(Bus bus) => _onSelectBusFromList(bus);

  Future<void> _onTapStopFromList(Stop s) async {
    if (_selectedBus == null) return;

    setState(() {
      _selectedStop = s;
      _statusAtSelectedStop = null;
    });

    // 파란 점은 유지하지 않음, 카메라만 이동
    await _mapKey.currentState?.moveCameraTo(
      kmap.LatLng(latitude: s.lat, longitude: s.lng),
    );

    final st = await _api.fetchBusStatusAtStop(
      busId: _selectedBus!.busId,
      stopId: s.stopId,
    );
    final curId = await _api.fetchBusCurrentStopId(_selectedBus!.busId);

    setState(() {
      _statusAtSelectedStop = st;
      _busCurrentStopId = curId;
    });

    try {
      await _sheetCtrl.animateTo(
        0.32,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } catch (_) {}
  }

  // ───────── 내 위치 / 가까운 정류장(초기 1회) ─────────
  Future<void> _loadNearestStopAndBuses() async {
    setState(() {
      _nearestLoading = true;
      _nearestError = null;
      _nearestStop = null;
      _busesAtNearestStop = [];
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _nearestLoading = false;
          _nearestError = '위치 서비스가 꺼져 있어요.';
        });
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _nearestLoading = false;
          _nearestError = '위치 권한이 필요해요.';
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      final near = await _api.fetchNearestStop(
        lat: pos.latitude,
        lng: pos.longitude,
        maxDistanceMeters: 800,
      );

      // 내 위치 파란점 표시(초기엔 카메라도 이동)
      await _mapKey.currentState?.setMyLocation(
        kmap.LatLng(latitude: pos.latitude, longitude: pos.longitude),
        moveCamera: true,
      );

      if (near == null) {
        setState(() {
          _nearestLoading = false;
          _nearestError = '주변 800m 이내 정류장이 없어요.';
          _nearestStop = null;
          _busesAtNearestStop = [];
        });
        return;
      }

      // 지도엔 근접 정류장 하나만 표시
      await _mapKey.currentState?.setStops([near]);

      // 그 정류장을 지나는 버스들
      final buses = await _api.fetchBusesByStop(near.stopId);

      setState(() {
        _nearestLoading = false;
        _nearestError = null;
        _nearestStop = near;
        _busesAtNearestStop = buses;
        _lastNearestStopId = near.stopId;
      });
    } catch (e) {
      setState(() {
        _nearestLoading = false;
        _nearestError = '가까운 정류장 계산 실패: $e';
      });
    }
  }

  // ───────── “내 위치로 이동” 버튼 ─────────
  Future<void> _goToMyLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return;
    }
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    await _mapKey.currentState?.setMyLocation(
      kmap.LatLng(latitude: pos.latitude, longitude: pos.longitude),
      moveCamera: true,
    );
  }
}

// ───────────── 아래: 시트 UI 위젯들 ─────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onSubmitted});
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: '지역을 입력하세요 (예: 천안, 아산, 김포)',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.buses, required this.onSelectBus});
  final List<Bus> buses;
  final ValueChanged<Bus> onSelectBus;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: buses.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final b = buses[i];
          return ListTile(
            leading: const Icon(Icons.directions_bus_filled),
            title: Text(b.name),
            subtitle: Text('courseId: ${b.courseId}'),
            onTap: () => onSelectBus(b),
          );
        },
      ),
    );
  }
}

class _NearestStopSheet extends StatelessWidget {
  const _NearestStopSheet({
    required this.controller,
    required this.loading,
    required this.error,
    required this.stop,
    required this.buses,
    required this.onTapBus,
  });

  final ScrollController controller;
  final bool loading;
  final String? error;
  final Stop? stop;
  final List<Bus> buses;
  final ValueChanged<Bus> onTapBus;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      color: Theme.of(context).cardColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const Text('가까운 정류장', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          if (loading) const LinearProgressIndicator(),
          if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
          if (!loading && error == null && stop != null) ...[
            ListTile(
              leading: const Icon(Icons.place),
              title: Text(stop!.name),
              subtitle: Text('(${stop!.lat.toStringAsFixed(5)}, ${stop!.lng.toStringAsFixed(5)})'),
            ),
            const SizedBox(height: 8),
            const Text('이 정류장을 지나는 버스', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (buses.isEmpty)
              const Text('해당 정류장을 운행하는 버스가 없습니다.', style: TextStyle(color: Colors.black54)),
            ...buses.map(
              (b) => Card(
                child: ListTile(
                  leading: const Icon(Icons.directions_bus_filled),
                  title: Text(b.name),
                  subtitle: Text('courseId: ${b.courseId}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onTapBus(b),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BusOverviewSheet extends StatelessWidget {
  const _BusOverviewSheet({
    required this.controller,
    required this.selectedBus,
    required this.runState,
    required this.routeStops,
    required this.currentStopId,
    required this.onTapStop,
  });

  final ScrollController controller;
  final Bus selectedBus;
  final BusRunState? runState;
  final List<Stop> routeStops;
  final int? currentStopId;
  final ValueChanged<Stop> onTapStop;

  String _stateToKo(BusRunState s) {
    switch (s) {
      case BusRunState.inService: return '이동중';
      case BusRunState.dwell:     return '정차중';
      case BusRunState.before:    return '운행 전';
      case BusRunState.finished:  return '운행 종료';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      color: Theme.of(context).cardColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.directions_bus_filled),
                const SizedBox(width: 8),
                Expanded(child: Text(selectedBus.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                if (runState != null) Chip(label: Text(_stateToKo(runState!))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Align(alignment: Alignment.centerLeft, child: Text('노선 정류장', style: TextStyle(fontWeight: FontWeight.w600))),
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              itemCount: routeStops.length,
              itemBuilder: (context, i) {
                final s = routeStops[i];
                final isCurrent = currentStopId == s.stopId;
                return ListTile(
                  leading: Icon(isCurrent ? Icons.directions_bus : Icons.radio_button_unchecked),
                  title: Text(s.name),
                  subtitle: Text('(${s.lat.toStringAsFixed(5)}, ${s.lng.toStringAsFixed(5)})'),
                  onTap: () => onTapStop(s),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BusAtStopSheet extends StatelessWidget {
  const _BusAtStopSheet({
    required this.controller,
    required this.selectedStop,
    required this.statusAtStop,
    required this.routeStops,
    required this.currentStopId,
    required this.onTapStop,
  });

  final ScrollController controller;
  final Stop selectedStop;
  final BusStatusAtStop statusAtStop;
  final List<Stop> routeStops;
  final int? currentStopId;
  final ValueChanged<Stop> onTapStop;

  String _stateToKo(BusRunState s) {
    switch (s) {
      case BusRunState.inService: return '이동중';
      case BusRunState.dwell:     return '정차중';
      case BusRunState.before:    return '운행 전';
      case BusRunState.finished:  return '운행 종료';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      color: Theme.of(context).cardColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),

          // 헤더: 선택 정류장 정보 (고정)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.place),
                const SizedBox(width: 8),
                Expanded(child: Text(selectedStop.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                Chip(label: Text(_stateToKo(statusAtStop.state))),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (statusAtStop.etaToArrive != null)
                  Expanded(child: _kv('도착 예정', '${statusAtStop.etaToArrive!.inMinutes}분 후')),
                if (statusAtStop.remainingDwell != null)
                  Expanded(child: _kv('정차 잔여', '${statusAtStop.remainingDwell!.inMinutes}분')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),

          // 리스트만 스크롤
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Align(alignment: Alignment.centerLeft, child: Text('노선 정류장', style: TextStyle(fontWeight: FontWeight.w600))),
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              itemCount: routeStops.length,
              itemBuilder: (context, i) {
                final s = routeStops[i];
                final isCurrent = currentStopId == s.stopId;
                return ListTile(
                  leading: Icon(isCurrent ? Icons.directions_bus : Icons.radio_button_unchecked),
                  title: Text(s.name),
                  onTap: () => onTapStop(s),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Row(
        children: [
          SizedBox(width: 80, child: Text(k, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(v, textAlign: TextAlign.right)),
        ],
      );
}
