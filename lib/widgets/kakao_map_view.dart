// lib/widgets/kakao_map_view.dart
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;


import 'package:flutter/material.dart';
import 'package:kakao_maps_flutter/kakao_maps_flutter.dart' as kmap;

import '../models/bus_stop.dart';

typedef StopTapCallback = void Function(Stop stop);

class KakaoMapView extends StatefulWidget {
  const KakaoMapView({super.key, this.onStopMarkerTap});
  final StopTapCallback? onStopMarkerTap;

  @override
  State<KakaoMapView> createState() => KakaoMapViewState();
}

class KakaoMapViewState extends State<KakaoMapView> {
  kmap.KakaoMapController? _controller;

  // 레이어/스타일/ID
  static const _myLayerId = 'layer_my';
  static const _stopsLayerId = 'layer_stops';
  static const _routeLayerId = 'layer_route';

  static const _meMarkerId = 'me_marker';
  static const _meStyleId = 'me_style_dot';
  static const _stopStyleSmall = 'stop_style_60';
  static const _stopStyleLarge = 'stop_style_80';
  static const _routeDotStyleId = 'route_dot_style_8';

  bool _mapReady = false;
  bool _myLayerReady = false;
  bool _stopsLayerReady = false;
  bool _routeLayerReady = false;

  bool _meStyleReady = false;
  bool _stopStyleReady = false;
  bool _routeStyleReady = false;

  kmap.LatLng? _lastMe;

  final Map<int, String> _stopIdToMarkerId = {};
  final Map<String, Stop> _markerIdToStop = {};
  String? _selectedMarkerId;

  final List<String> _routeDotIds = [];

  StreamSubscription? _labelClickSub;

  @override
  void dispose() {
    _labelClickSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return kmap.KakaoMap(
      initialPosition:
          const kmap.LatLng(latitude: 37.5665, longitude: 126.9780),
      initialLevel: 7,
      onMapCreated: (c) async {
        _controller = c;
        // 살짝 대기 (엔진 초기화)
        await Future.delayed(const Duration(milliseconds: 200));

        // 레이어 준비
        await _controller!.addMarkerLayer(layerId: _myLayerId);
        _myLayerReady = true;
        await _controller!.addMarkerLayer(layerId: _stopsLayerId);
        _stopsLayerReady = true;
        await _controller!.addMarkerLayer(layerId: _routeLayerId);
        _routeLayerReady = true;

        // 스타일 준비
        await _ensureMyDotStyle();
        await _ensureStopStyle();
        await _ensureRouteDotStyle();

        // 마커 탭 이벤트 → 정류장 확대 선택 / 콜백
        _labelClickSub =
            _controller!.onLabelClickedStream.listen((event) async {
          final markerId = event.labelId;
          final stop = _markerIdToStop[markerId];
          if (stop == null) return;

          // 이전 선택 복구(작은 핀으로)
          if (_selectedMarkerId != null && _selectedMarkerId != markerId) {
            final prev = _markerIdToStop[_selectedMarkerId!];
            if (prev != null) {
              await _replaceStopMarker(
                markerId: _selectedMarkerId!,
                stop: prev,
                styleId: _stopStyleReady ? _stopStyleSmall : null,
              );
            }
          }
          // 새 선택 확대(큰 핀)
          await _replaceStopMarker(
            markerId: markerId,
            stop: stop,
            styleId: _stopStyleReady ? _stopStyleLarge : null,
          );
          _selectedMarkerId = markerId;

          widget.onStopMarkerTap?.call(stop);
        });

        setState(() => _mapReady = true);
      },
    );
  }

  // ───────────────── 내 위치 표시/카메라 ─────────────────

  Future<void> setMyLocation(kmap.LatLng me, {bool moveCamera = true}) async {
    if (_controller == null || !_mapReady || !_myLayerReady) return;

    if (moveCamera) {
      await _controller!.moveCamera(
        cameraUpdate: kmap.CameraUpdate.fromLatLng(me),
        animation: const kmap.CameraAnimation(
          duration: 500,
          autoElevation: true,
          isConsecutive: false,
        ),
      );
    }

    try {
      await _controller!.removeMarker(id: _meMarkerId, layerId: _myLayerId);
    } catch (_) {}

    await _controller!.addMarker(
      markerOption: kmap.MarkerOption(
        id: _meMarkerId,
        latLng: me,
        styleId: _meStyleReady ? _meStyleId : null,
      ),
      layerId: _myLayerId,
    );
    _lastMe = me;
  }

  Future<void> clearMyLocation() async {
    if (_controller == null || !_myLayerReady) return;
    try {
      await _controller!.removeMarker(id: _meMarkerId, layerId: _myLayerId);
    } catch (_) {}
    _lastMe = null;
  }

  Future<void> moveCameraTo(kmap.LatLng target) async {
    if (_controller == null || !_mapReady) return;
    await _controller!.moveCamera(
      cameraUpdate: kmap.CameraUpdate.fromLatLng(target),
      animation: const kmap.CameraAnimation(
        duration: 500,
        autoElevation: true,
        isConsecutive: false,
      ),
    );
  }

  // ───────────────── 정류장 마커 ─────────────────

  Future<void> setStops(List<Stop> stops) async {
    if (_controller == null || !_mapReady || !_stopsLayerReady) return;

    // 기존 정류장 마커 제거
    for (final id in _stopIdToMarkerId.values) {
      try {
        await _controller!.removeMarker(id: id, layerId: _stopsLayerId);
      } catch (_) {}
    }
    _stopIdToMarkerId.clear();
    _markerIdToStop.clear();
    _selectedMarkerId = null;

    for (final s in stops) {
      final id = 'stop_${s.stopId}';
      await _controller!.addMarker(
        markerOption: kmap.MarkerOption(
          id: id,
          latLng: kmap.LatLng(latitude: s.lat, longitude: s.lng),
          styleId: _stopStyleReady ? _stopStyleSmall : null,
          text: s.name,
        ),
        layerId: _stopsLayerId,
      );
      _stopIdToMarkerId[s.stopId] = id;
      _markerIdToStop[id] = s;
    }
  }

  // ───────────────── 노선 점선(의사-폴리라인) ─────────────────

  /// 정류장들 사이를 **작은 점 마커**로 이어서 점선을 그린다.
  /// (SDK에 폴리라인 API가 없어서 차선책)
  Future<void> drawRouteDots(List<Stop> stops,
      {int dotsPerSegment = 12}) async {
    if (_controller == null ||
        !_mapReady ||
        !_routeLayerReady ||
        !_routeStyleReady) return;

    // 이전 점선 제거
    await clearRouteDots();

    if (stops.length < 2) return;

    int seq = 0;
    for (int i = 0; i < stops.length - 1; i++) {
      final a = stops[i];
      final b = stops[i + 1];

      final aPos = kmap.LatLng(latitude: a.lat, longitude: a.lng);
      final bPos = kmap.LatLng(latitude: b.lat, longitude: b.lng);

      // a-b 구간을 선형보간으로 n개의 점 생성(양 끝 정류장과 겹치지 않게 1..n-1)
      for (int k = 1; k < dotsPerSegment; k++) {
        final t = k / dotsPerSegment;
        final lat = aPos.latitude + (bPos.latitude - aPos.latitude) * t;
        final lng = aPos.longitude + (bPos.longitude - aPos.longitude) * t;

        final id = 'route_dot_${i}_${k}_${seq++}'; // ← 변수 경계 명확화
        await _controller!.addMarker(
          markerOption: kmap.MarkerOption(
            id: id,
            latLng: kmap.LatLng(latitude: lat, longitude: lng),
            styleId: _routeDotStyleId,
          ),
          layerId: _routeLayerId,
        );
        _routeDotIds.add(id);
      }
    }
  }

  Future<void> clearRouteDots() async {
    if (_controller == null || !_routeLayerReady) return;
    for (final id in _routeDotIds) {
      try {
        await _controller!.removeMarker(id: id, layerId: _routeLayerId);
      } catch (_) {}
    }
    _routeDotIds.clear();
  }

  // ───────────────── 스타일 등록/헬퍼 ─────────────────

  Future<void> _ensureMyDotStyle() async {
    if (_meStyleReady || _controller == null) return;
    try {
      final bytes = await _makeCirclePngBytes(24, const Color(0xFF2E7DFF));
      final styles = [
        kmap.MarkerStyle(
          styleId: _meStyleId,
          perLevels: [kmap.MarkerPerLevelStyle.fromBytes(bytes: bytes)],
        )
      ];
      await _controller!.registerMarkerStyles(styles: styles);
      _meStyleReady = true;
    } catch (_) {}
  }

  Future<void> _ensureStopStyle() async {
  if (_stopStyleReady || _controller == null) return;
  try {
    // 에셋 이미지를 60px/80px로 리사이즈
    final bytes60 = await _loadResizedPngBytes('assets/images/stop_pin.png', 60);
    final bytes80 = await _loadResizedPngBytes('assets/images/stop_pin.png', 80);

    final styles = [
      kmap.MarkerStyle(
        styleId: _stopStyleSmall,
        perLevels: [kmap.MarkerPerLevelStyle.fromBytes(bytes: bytes60)],
      ),
      kmap.MarkerStyle(
        styleId: _stopStyleLarge,
        perLevels: [kmap.MarkerPerLevelStyle.fromBytes(bytes: bytes80)],
      ),
    ];
    await _controller!.registerMarkerStyles(styles: styles);
    _stopStyleReady = true;
  } catch (_) {}
}


  Future<void> _ensureRouteDotStyle() async {
    if (_routeStyleReady || _controller == null) return;
    try {
      // 작고 선명한 주황색 점(테마에 맞춤)
      final bytes = await _makeCirclePngBytes(8, const Color(0xFFFF7A00));
      final styles = [
        kmap.MarkerStyle(
          styleId: _routeDotStyleId,
          perLevels: [kmap.MarkerPerLevelStyle.fromBytes(bytes: bytes)],
        )
      ];
      await _controller!.registerMarkerStyles(styles: styles);
      _routeStyleReady = true;
    } catch (_) {}
  }

  Future<void> _replaceStopMarker({
    required String markerId,
    required Stop stop,
    required String? styleId,
  }) async {
    try {
      await _controller?.removeMarker(id: markerId, layerId: _stopsLayerId);
    } catch (_) {}
    await _controller?.addMarker(
      markerOption: kmap.MarkerOption(
        id: markerId,
        latLng: kmap.LatLng(latitude: stop.lat, longitude: stop.lng),
        styleId: styleId,
        text: stop.name,
      ),
      layerId: _stopsLayerId,
    );
  }

  /// 단색 원형 PNG 만들기 (폴리라인 대용 점/내 위치 점 용)
  Future<Uint8List> _makeCirclePngBytes(int size, Color color) async {
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    final paint = Paint()..color = color;

    final center = Offset(size / 2, size / 2);
    final radius = size / 2;

    canvas.drawCircle(center, radius, paint);
    final img =
        await rec.endRecording().toImage(size, size);
    final data =
        await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<Uint8List> _loadResizedPngBytes(String assetPath, int size) async {
  final raw = await rootBundle.load(assetPath);
  final codec = await ui.instantiateImageCodec(
    raw.buffer.asUint8List(),
    targetWidth: size,
    targetHeight: size,
  );
  final frame = await codec.getNextFrame();
  final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}
}
