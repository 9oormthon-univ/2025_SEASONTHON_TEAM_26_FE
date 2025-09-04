// lib/widgets/kakao_map_view.dart
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kakao_maps_flutter/kakao_maps_flutter.dart';
import '../models/bus_stop.dart'; // 파일명만 bus_stop.dart, 클래스는 Stop

typedef StopTapCallback = void Function(Stop stop);

class KakaoMapView extends StatefulWidget {
  const KakaoMapView({
    super.key,
    this.onStopMarkerTap,
  });

  /// 정류장 마커를 탭했을 때 부모로 올려줄 콜백
  final StopTapCallback? onStopMarkerTap;

  @override
  State<KakaoMapView> createState() => KakaoMapViewState();
}

class KakaoMapViewState extends State<KakaoMapView> {
  KakaoMapController? _controller;

  // 레이어 / 스타일 / 마커 ID
  static const _myLayerId = 'layer_my';
  static const _stopsLayerId = 'layer_stops';
  static const _meMarkerId = 'me_marker';
  static const _meStyleId = 'me_style_dot';

  // 정류장 크기별 스타일
  static const _stopStyleSmall = 'stop_style_60';
  static const _stopStyleLarge = 'stop_style_80';

  // 상태
  bool _mapReady = false;
  bool _myLayerReady = false;
  bool _stopsLayerReady = false;
  bool _meStyleReady = false;
  bool _stopStyleReady = false;

  // 내부 캐시
  LatLng? _lastMe;
  final Map<int, String> _stopIdToMarkerId = {}; // stopId -> markerId
  final Map<String, Stop> _markerIdToStop = {};  // markerId -> Stop
  String? _selectedMarkerId;

  // 구독
  StreamSubscription? _labelClickSub;

  @override
  void dispose() {
    _labelClickSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KakaoMap(
      initialPosition: const LatLng(latitude: 37.5665, longitude: 126.9780),
      initialLevel: 7,
      onMapCreated: (c) async {
        _controller = c;

        // 맵 엔진 준비 시간
        await Future.delayed(const Duration(milliseconds: 200));

        // 레이어 생성 (내 위치 / 정류장 분리)
        await _controller!.addMarkerLayer(layerId: _myLayerId);
        _myLayerReady = true;
        await _controller!.addMarkerLayer(layerId: _stopsLayerId);
        _stopsLayerReady = true;

        // 스타일 등록
        await _ensureMyDotStyle();   // 파란 점
        await _ensureStopStyle();    // 정류장 (60/80)

        // 마커(라벨) 탭 이벤트는 스트림으로 처리
        _labelClickSub = _controller!.onLabelClickedStream.listen((event) async {
          final markerId = event.labelId; // addMarker 때 준 id
          final stop = _markerIdToStop[markerId];
          if (stop == null) return;

          // 1) 이전 선택 복구 (60px)
          if (_selectedMarkerId != null && _selectedMarkerId != markerId) {
            final prevStop = _markerIdToStop[_selectedMarkerId!];
            if (prevStop != null) {
              await _replaceStopMarker(
                markerId: _selectedMarkerId!,
                stop: prevStop,
                styleId: _stopStyleReady ? _stopStyleSmall : null, // 60px
              );
            }
          }

          // 2) 새 선택 확대 (80px)
          await _replaceStopMarker(
            markerId: markerId,
            stop: stop,
            styleId: _stopStyleReady ? _stopStyleLarge : null, // 80px
          );

          _selectedMarkerId = markerId;

          // 3) 부모 콜백(하단 시트에 정보 표시)
          widget.onStopMarkerTap?.call(stop);
        });

        setState(() => _mapReady = true);
      },
    );
  }

  // ─────────── 공개 API (부모가 GlobalKey로 호출) ───────────

  /// 외부에서 받은 좌표로 카메라 이동 + 파란 점(내 위치) 마커 표시
  Future<void> moveToAndMark(LatLng me) async {
    if (_controller == null || !_mapReady || !_myLayerReady) return;

    await _controller!.moveCamera(
      cameraUpdate: CameraUpdate.fromLatLng(me),
      animation: const CameraAnimation(
        duration: 500,
        autoElevation: true,
        isConsecutive: false,
      ),
    );

    // 내 위치 마커 갱신
    try {
      await _controller!.removeMarker(id: _meMarkerId, layerId: _myLayerId);
    } catch (_) {}

    await _controller!.addMarker(
      markerOption: MarkerOption(
        id: _meMarkerId,
        latLng: me,
        styleId: _meStyleReady ? _meStyleId : null, // 스타일 없으면 기본 마커
      ),
      layerId: _myLayerId,
    );

    _lastMe = me;
  }

  /// 정류장 마커를 전체 갈아끼우기 (기본 크기: 60px)
  Future<void> setStops(List<Stop> stops) async {
    if (_controller == null || !_mapReady || !_stopsLayerReady) return;

    // 기존 정류장 마커 제거
    for (final markerId in _stopIdToMarkerId.values) {
      try {
        await _controller!.removeMarker(id: markerId, layerId: _stopsLayerId);
      } catch (_) {}
    }
    _stopIdToMarkerId.clear();
    _markerIdToStop.clear();
    _selectedMarkerId = null;

    // 새 정류장 마커 추가
    for (final s in stops) {
      final id = 'stop_${s.stopId}';
      await _controller!.addMarker(
        markerOption: MarkerOption(
          id: id,
          latLng: LatLng(latitude: s.lat, longitude: s.lng),
          styleId: _stopStyleReady ? _stopStyleSmall : null, // 60px
          text: s.name, // 필요 없으면 제거
        ),
        layerId: _stopsLayerId,
      );
      _stopIdToMarkerId[s.stopId] = id;
      _markerIdToStop[id] = s;
    }
  }

  /// 모든 정류장 마커 제거
  Future<void> clearStops() async {
    if (_controller == null || !_mapReady || !_stopsLayerReady) return;
    for (final markerId in _stopIdToMarkerId.values) {
      try {
        await _controller!.removeMarker(id: markerId, layerId: _stopsLayerId);
      } catch (_) {}
    }
    _stopIdToMarkerId.clear();
    _markerIdToStop.clear();
    _selectedMarkerId = null;
  }

  LatLng? get lastMyLocation => _lastMe;

  // ─────────── 내부: 스타일 등록 / 헬퍼 ───────────

  /// 파란 점(내 위치) 스타일
  Future<void> _ensureMyDotStyle() async {
    if (_meStyleReady || _controller == null) return;
    try {
      final bytes = await _loadResizedPngBytes('assets/images/blue_dot.png', 24);
      final styles = [
        MarkerStyle(
          styleId: _meStyleId,
          perLevels: [MarkerPerLevelStyle.fromBytes(bytes: bytes)],
        ),
      ];
      await _controller!.registerMarkerStyles(styles: styles);
      _meStyleReady = true;
    } catch (_) {
      _meStyleReady = false; // 에셋이 없어도 기본 마커로 진행
    }
  }

  /// 정류장 핀 스타일(60 / 80)
  Future<void> _ensureStopStyle() async {
    if (_stopStyleReady || _controller == null) return;
    try {
      final bytes60 = await _loadResizedPngBytes('assets/images/stop_pin.png', 60);
      final bytes80 = await _loadResizedPngBytes('assets/images/stop_pin.png', 80);

      final styles = [
        MarkerStyle(
          styleId: _stopStyleSmall,
          perLevels: [MarkerPerLevelStyle.fromBytes(bytes: bytes60)],
        ),
        MarkerStyle(
          styleId: _stopStyleLarge,
          perLevels: [MarkerPerLevelStyle.fromBytes(bytes: bytes80)],
        ),
      ];
      await _controller!.registerMarkerStyles(styles: styles);
      _stopStyleReady = true;
    } catch (_) {
      _stopStyleReady = false; // 에셋 없으면 기본 마커로 표시
    }
  }

  // 동일 id 마커를 크기/스타일 변경할 때: remove → add
  Future<void> _replaceStopMarker({
    required String markerId,
    required Stop stop,
    required String? styleId,
  }) async {
    try {
      await _controller?.removeMarker(id: markerId, layerId: _stopsLayerId);
    } catch (_) {}
    await _controller?.addMarker(
      markerOption: MarkerOption(
        id: markerId,
        latLng: LatLng(latitude: stop.lat, longitude: stop.lng),
        styleId: styleId, // null이면 기본 마커
        text: stop.name,
      ),
      layerId: _stopsLayerId,
    );
  }

  // 에셋 PNG 리사이즈 → 바이트
  Future<Uint8List> _loadResizedPngBytes(String assetPath, int sizePx) async {
    final raw = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(
      raw.buffer.asUint8List(),
      targetWidth: sizePx,
      targetHeight: sizePx,
    );
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }
}
