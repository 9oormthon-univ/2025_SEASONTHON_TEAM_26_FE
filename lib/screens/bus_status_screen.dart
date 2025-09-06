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

// ✅ 통합 앱바 색/텍스트 스타일
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BusStatusScreen extends StatefulWidget {
  const BusStatusScreen({super.key});

  @override
  State<BusStatusScreen> createState() => _BusStatusScreenState();
}

class _BusStatusScreenState extends State<BusStatusScreen> {
  final GlobalKey<KakaoMapViewState> _mapKey = GlobalKey<KakaoMapViewState>();
  final DraggableScrollableController _sheetCtrl = DraggableScrollableController();

  // 시트 크기 한계값(DraggableScrollableSheet와 동일하게 유지)
  static const double _minSheet = 0.12;
  static const double _maxSheet = 0.60;

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

  // ───────── 통합 앱바 ─────────
  Widget _buildIntegratedAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.appBarBackground, // Ivory-300 배경
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryDisabled, // Primary/Orange-200
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        children: [
          // Dream Drivers 로고
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft, // 왼쪽 정렬
              child: Image.asset(
                'assets/images/dreamdrivers_orange.png',
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 네비게이션 탭
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                // 버스 현황 탭 (현재 화면)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/bus-status');
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface, // Neutral/Ivory-300
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary, width: 1),
                      ),
                      child: Center(
                        child: Text('버스 현황', style: AppTextStyles.navigatorTabInactive),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 버스 신청 탭
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/bus-search');
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary, // Primary/Orange-500
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(child: Text('버스 신청', style: AppTextStyles.navigatorTab)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ─────────────────────────────

  // ───────── 헤더 드래그 → 시트 높이 제어 로직 ─────────
  void _onHeaderDragUpdate(DragUpdateDetails d) {
    final screenH = MediaQuery.of(context).size.height;
    if (screenH <= 0) return;
    final dy = d.delta.dy; // 위로 드래그 시 음수
    final next = (_sheetCtrl.size - dy / screenH).clamp(_minSheet, _maxSheet);
    _sheetCtrl.jumpTo(next);
  }

  void _onHeaderDragEnd(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond.dy; // 위로 빠르게 드래그: 음수
    double target = _sheetCtrl.size;
    if (v.abs() > 600) {
      target = (v < 0) ? (_sheetCtrl.size + 0.18) : (_sheetCtrl.size - 0.18);
    }
    target = target.clamp(_minSheet, _maxSheet);
    if ((target - _sheetCtrl.size).abs() > 0.02) {
      _sheetCtrl.animateTo(
        target,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
      );
    }
  }
  // ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final hasBus = _selectedBus != null;
    final showingStopStatus = _selectedStop != null && _statusAtSelectedStop != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildIntegratedAppBar(context), // 상단 고정
            Expanded(
              child: Stack(
                children: [
                  // ① 지도
                  Positioned.fill(
                    child: KakaoMapView(
                      key: _mapKey,
                      onStopMarkerTap: (stop) async {
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
                    minChildSize: _minSheet,
                    maxChildSize: _maxSheet,
                    builder: (context, controller) {
                      if (!hasBus) {
                        return _NearestStopSheet(
                          controller: controller,
                          loading: _nearestLoading,
                          error: _nearestError,
                          stop: _nearestStop,
                          buses: _busesAtNearestStop,
                          onTapBus: _onSelectBusFromNearest,
                          onHeaderDragUpdate: _onHeaderDragUpdate,
                          onHeaderDragEnd: _onHeaderDragEnd,
                        );
                      }

                      if (hasBus && !showingStopStatus) {
                        return _BusOverviewSheet(
                          controller: controller,
                          selectedBus: _selectedBus!,
                          runState: _busRunState,
                          routeStops: _routeStops,
                          currentStopId: _busCurrentStopId,
                          onTapStop: _onTapStopFromList,
                          onHeaderDragUpdate: _onHeaderDragUpdate,
                          onHeaderDragEnd: _onHeaderDragEnd,
                        );
                      }

                      return _BusAtStopSheet(
                        controller: controller,
                        selectedStop: _selectedStop!,
                        statusAtStop: _statusAtSelectedStop!,
                        routeStops: _routeStops,
                        currentStopId: _busCurrentStopId,
                        onTapStop: _onTapStopFromList,
                        onHeaderDragUpdate: _onHeaderDragUpdate,
                        onHeaderDragEnd: _onHeaderDragEnd,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '내 위치로 이동',
        onPressed: _goToMyLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  // ───────── 위치 스트림: 가까운 정류장 자동 갱신 ─────────
  void _startNearestWatcher() async {
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
      if (!_autoNearestEnabled) return;
      if (_nearestBusy) return;

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

        if (!_autoNearestEnabled) return;

        if (near == null) {
          if (_nearestStop != null) {
            setState(() {
              _nearestStop = null;
              _busesAtNearestStop = [];
              _nearestError = '주변 800m 이내 정류장이 없어요.';
            });
          }
          await _mapKey.currentState?.setMyLocation(
            kmap.LatLng(latitude: pos.latitude, longitude: pos.longitude),
            moveCamera: false,
          );
          return;
        }

        if (_lastNearestStopId == near.stopId) {
          await _mapKey.currentState?.setMyLocation(
            kmap.LatLng(latitude: pos.latitude, longitude: pos.longitude),
            moveCamera: false,
          );
          return;
        }
        _lastNearestStopId = near.stopId;

        await _mapKey.currentState?.setMyLocation(
          kmap.LatLng(latitude: pos.latitude, longitude: pos.longitude),
          moveCamera: false,
        );

        await _mapKey.currentState?.setStops([near]);

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
    _stopNearestWatcher();
    await _mapKey.currentState?.clearMyLocation();

    setState(() {
      _selectedBus = bus;
      _selectedStop = null;
      _statusAtSelectedStop = null;
      _busCurrentStopId = null;
      _searchResults = [];
    });

    await _mapKey.currentState?.moveCameraTo(
      kmap.LatLng(latitude: bus.centerLat, longitude: bus.centerLng),
    );

    final stops = await _api.fetchRouteStops(bus.courseId);
    await _mapKey.currentState?.setStops(stops);
    final runState = await _api.fetchBusRunState(bus.busId);
    final curStopId = await _api.fetchBusCurrentStopId(bus.busId);

    setState(() {
      _routeStops = stops;
      _busRunState = runState;
      _busCurrentStopId = curStopId;
    });

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
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
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

      await _mapKey.currentState?.setStops([near]);

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

  // ───────── “내 위치로 이동” FAB ─────────
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
  const _SearchBar({
    required this.controller,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 검색 입력 필드
        Expanded(
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(20),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '지역을 검색하세요',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryLight),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: Colors.white,
                // 모든 상태 동일한 테두리
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.primaryDisabled, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.primaryDisabled, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.primaryDisabled, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.primaryDisabled, width: 1.5),
                ),
              ),
              onSubmitted: onSubmitted,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // 요일 선택 버튼 (UI만)
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_drop_down, color: Colors.white),
              SizedBox(width: 4),
              Text('요일', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
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
            leading: const Icon(Icons.directions_bus_filled, color: AppColors.primary),
            title: Text(b.name),
            subtitle: Text('courseId: ${b.courseId}'),
            onTap: () => onSelectBus(b),
          );
        },
      ),
    );
  }
}

// 공통: 헤더 드래그 영역 Wrapper
class _HeaderDraggable extends StatelessWidget {
  const _HeaderDraggable({
    required this.child,
    required this.onUpdate,
    required this.onEnd,
  });

  final Widget child;
  final GestureDragUpdateCallback onUpdate;
  final GestureDragEndCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: onUpdate,
      onVerticalDragEnd: onEnd,
      child: child,
    );
  }
}

// 공통: 시트 상단 헤더(그립+데코+타이틀+구분선)
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 44, height: 5,
          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(height: 22),
        Image.asset('assets/images/groom.png', height: 16, fit: BoxFit.contain),
        const SizedBox(height: 35),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 18),
        Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: AppColors.primaryDisabled),
        const SizedBox(height: 12),
      ],
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
    required this.onHeaderDragUpdate,
    required this.onHeaderDragEnd,
  });

  final ScrollController controller;
  final bool loading;
  final String? error;
  final Stop? stop;
  final List<Bus> buses;
  final ValueChanged<Bus> onTapBus;

  final GestureDragUpdateCallback onHeaderDragUpdate;
  final GestureDragEndCallback onHeaderDragEnd;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          _HeaderDraggable(
            onUpdate: onHeaderDragUpdate,
            onEnd: onHeaderDragEnd,
            child: Column(
              children: [
                const _SheetHeader(title: '가장 가까운 정류장'),
                if (loading)
                  const LinearProgressIndicator(
                    backgroundColor: AppColors.surfaceVariant,
                    color: AppColors.primaryLight,
                  ),
                if (error != null) const SizedBox(height: 8),
                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                if (!loading && error == null && stop != null) ...[
                  ListTile(
                    leading: const Icon(Icons.place, color: AppColors.primary),
                    title: Text(stop!.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('(${stop!.lat.toStringAsFixed(5)}, ${stop!.lng.toStringAsFixed(5)})'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('이 정류장을 지나는 버스', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),

          if (!loading && error == null && stop != null) ...[
            if (buses.isEmpty)
              const Text('해당 정류장을 운행하는 버스가 없습니다.', style: TextStyle(color: Colors.black54)),
            ...buses.map(
              (b) => Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.primaryDisabled),
                ),
                child: ListTile(
                  leading: const Icon(Icons.directions_bus_filled, color: AppColors.primary),
                  title: Text(b.name),
                  subtitle: Text('courseId: ${b.courseId}'),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
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
    required this.onHeaderDragUpdate,
    required this.onHeaderDragEnd,
  });

  final ScrollController controller;
  final Bus selectedBus;
  final BusRunState? runState;
  final List<Stop> routeStops;
  final int? currentStopId;
  final ValueChanged<Stop> onTapStop;

  final GestureDragUpdateCallback onHeaderDragUpdate;
  final GestureDragEndCallback onHeaderDragEnd;

  String _stateToKo(BusRunState s) {
    switch (s) {
      case BusRunState.inService: return '이동중';
      case BusRunState.dwell:     return '정차중';
      case BusRunState.before:    return '운행 전';
      case BusRunState.finished:  return '운행 종료';
    }
  }

  // 정류장별 시간 범위(데이터 없으면 플레이스홀더)
  String _timeRangeOrDash(Stop s) {
    try {
      final dyn = s as dynamic;
      final start = dyn.startTime as String?;
      final end = dyn.endTime as String?;
      if (start != null && end != null && start.isNotEmpty && end.isNotEmpty) {
        return '$start ~ $end';
      }
    } catch (_) {}
    return '— — : — —  ~  — — : — —';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Column(
        children: [
          _HeaderDraggable(
            onUpdate: onHeaderDragUpdate,
            onEnd: onHeaderDragEnd,
            child: Column(
              children: [
                _SheetHeader(title: selectedBus.name),
                const SizedBox(height: 12),
                //칩 라벨
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Pill('상태'),
                        Pill('현재 위치'),
                        Pill('도착 시간'),
                        Pill('잔여 시간'),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // 칩 값(모델에 값 없으면 “–” 처리)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: CellText('—')),
                      Expanded(child: CellText('—')),
                      Expanded(child: CellText('— — : — —')),
                      Expanded(child: CellText('—')),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 구분선
                Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: AppColors.primaryDisabled),

                // // 상태 칩(우측)
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                //   child: Row(
                //     children: [
                //       const Spacer(),
                //       if (runState != null)
                //         Chip(
                //           label: Text(_stateToKo(runState!)),
                //           backgroundColor: AppColors.primary.withOpacity(0.1),
                //           labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                //           visualDensity: VisualDensity.compact,
                //         ),
                //     ],
                //   ),
                // ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('노선 정류장', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),

          // 리스트 (배경에 녹이고 구분선으로만 나눔)
          Expanded(
            child: ListView.separated(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              itemCount: routeStops.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.primaryDisabled),
              itemBuilder: (context, i) {
                final s = routeStops[i];
                final isCurrent = currentStopId == s.stopId;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isCurrent ? Icons.directions_bus : Icons.radio_button_unchecked,
                    color: isCurrent ? AppColors.primary : Colors.black54,
                  ),
                  title: Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(_timeRangeOrDash(s), style: const TextStyle(fontSize: 12, color: Colors.black54)),
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
    required this.onHeaderDragUpdate,
    required this.onHeaderDragEnd,
  });

  final ScrollController controller;
  final Stop selectedStop;
  final BusStatusAtStop statusAtStop;
  final List<Stop> routeStops;
  final int? currentStopId;
  final ValueChanged<Stop> onTapStop;

  final GestureDragUpdateCallback onHeaderDragUpdate;
  final GestureDragEndCallback onHeaderDragEnd;

  String _stateToKo(BusRunState s) {
    switch (s) {
      case BusRunState.inService: return '이동중';
      case BusRunState.dwell:     return '정차중';
      case BusRunState.before:    return '운행 전';
      case BusRunState.finished:  return '운행 종료';
    }
  }

  // 남은 시간 mm표현 (예: 1시간 30분)
  String _fmtDuration(Duration? d) {
    if (d == null) return '–';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}분';
    if (m == 0) return '${h}시간';
    return '${h}시간 ${m}분';
  }

  // “13분 후” 같은 표기
  String _fmtEta(Duration? d) {
    if (d == null) return '–';
    final m = d.inMinutes;
    if (m <= 0) return '곧 도착';
    return '${m}분 후';
  }

  @override
  Widget build(BuildContext context) {
    final regionText = (() {
      try {
        final v = (selectedStop as dynamic).region ?? (selectedStop as dynamic).regionName;
        if (v is String && v.isNotEmpty) return v;
      } catch (_) {}
      return '–';
    })();

    return Material(
      elevation: 12,
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Column(
        children: [
          _HeaderDraggable(
            onUpdate: onHeaderDragUpdate,
            onEnd: onHeaderDragEnd,
            child: Center(
              child: Column(
                children: [
                  _SheetHeader(title: selectedStop.name), // 정류장명
                  const SizedBox(height: 12),

                  // 칩 라벨 4개 (지역/운행 요일/도착 시간/정차 시간)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Pill('지역'),
                        Pill('운행 요일'),
                        Pill('도착 시간'),
                        Pill('정차 시간'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 값 4개
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        const CellText('–')..toString(), // 지역명은 아래로 교체
                        // ↑ Analyzer 경고 회피용. 하지만 바로 아래서 교체한다.
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 리스트 (아래 영역만 스크롤)
          Expanded(
            child: Container(
              color: AppColors.appBarBackground,
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: routeStops.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.primaryDisabled),
                itemBuilder: (context, i) {
                  final s = routeStops[i];
                  final isCurrent = currentStopId == s.stopId;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isCurrent ? Icons.directions_bus : Icons.radio_button_unchecked,
                      color: isCurrent ? AppColors.primary : Colors.black54,
                    ),
                    title: Text(s.name),
                    onTap: () => onTapStop(s),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 라벨 칩
class Pill extends StatelessWidget {
  const Pill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}

// 값 셀(Expanded 균등분배)
class CellText extends StatelessWidget {
  const CellText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text(
          '', // 사용 시 텍스트 주입 필요
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
