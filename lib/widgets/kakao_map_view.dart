// lib/widgets/kakao_map_view.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kakao_maps_flutter/kakao_maps_flutter.dart';
import '../models/bus_stop.dart';

class KakaoMapView extends StatefulWidget {
  const KakaoMapView({super.key});

  @override
  State<KakaoMapView> createState() => KakaoMapViewState();
}

class KakaoMapViewState extends State<KakaoMapView> {
  KakaoMapController? _controller;

  // 레이어/스타일/마커 ID
  static const _myLayerId = 'layer_my';
  static const _stopsLayerId = 'layer_stops';
  static const _meMarkerId = 'me_marker';
  static const _meStyleId = 'me_style_dot';
  static const _stopStyleId = 'stop_style_pin';

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

        // 스타일 등록 (없어도 동작하도록 try)
        await _ensureMyDotStyle();
        await _ensureStopStyle();

        setState(() => _mapReady = true);
      },
    );
  }

  // ─────────── 공개 API (부모가 GlobalKey로 호출) ───────────

  /// 현위치로 카메라 이동 + 파란 점 마커 표시. 성공 시 현재 좌표 반환.
  Future<LatLng?> goToMyLocation() async {
    if (_controller == null || !_mapReady || !_myLayerReady) return null;

    // 위치 권한/서비스 체크는 부모 쪽에서 처리해도 되지만,
    // 이 위젯은 지도만 담당하므로 단순히 플랫폼 좌표를 받는다고 가정.
    // 실제 앱에선 geolocator로 좌표를 받아서 이 메서드에 주입해도 OK.
    // 여기서는 카메라 중심을 "현재 위치"로 간주하는 헬퍼도 제공한다.
    // (원한다면 이 메서드를 LatLng 파라미터 받도록 바꿔 써도 됨)

    // 만약 부모가 좌표를 갖고 있다면 moveToAndMark(me) 를 쓰세요.

    // 카메라의 현재 중심 좌표를 받아오는 API가 없으니
    // geolocator 쪽에서 좌표를 넘겨받는 형태가 가장 깔끔합니다.
    // => 아래 헬퍼 사용 권장
    return null;
  }

  /// 외부에서 받은 좌표로 카메라 이동 + 파란 점 마커 표시
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

  /// 정류장 마커를 전체 갈아끼우기
  Future<void> setStops(List<Stop> stops) async {
    if (_controller == null || !_mapReady || !_stopsLayerReady) return;

    // 기존 정류장 마커 제거
    for (final markerId in _stopIdToMarkerId.values) {
      try {
        await _controller!.removeMarker(id: markerId, layerId: _stopsLayerId);
      } catch (_) {}
    }
    _stopIdToMarkerId.clear();

    // 새 정류장 마커 추가
    for (final s in stops) {
      final id = 'stop_${s.stopId}';
      await _controller!.addMarker(
        markerOption: MarkerOption(
          id: id,
          latLng: LatLng(latitude: s.lat, longitude: s.lng),
          styleId: _stopStyleReady ? _stopStyleId : null,
          text: s.name, // 필요 없으면 삭제
        ),
        layerId: _stopsLayerId,
      );
      _stopIdToMarkerId[s.stopId] = id;
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
  }

  LatLng? get lastMyLocation => _lastMe;

  // ─────────── 내부: 스타일 등록 ───────────

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
      // 에셋이 없어도 동작하도록 조용히 패스(기본 마커 사용)
      _meStyleReady = false;
    }
  }

  /// 정류장 핀 스타일 (에셋이 없으면 기본 마커 사용)
  Future<void> _ensureStopStyle() async {
    if (_stopStyleReady || _controller == null) return;
    try {
      // 에셋 준비가 아직 없다면 같은 파란점/또는 다른 핀을 두세요.
      // 없을 수 있으니 try-catch로 감싸고, 실패 시 기본 마커로 표시합니다.
      final bytes = await _loadResizedPngBytes('assets/images/stop_pin.png', 60);
      final styles = [
        MarkerStyle(
          styleId: _stopStyleId,
          perLevels: [MarkerPerLevelStyle.fromBytes(bytes: bytes)],
        ),
      ];
      await _controller!.registerMarkerStyles(styles: styles);
      _stopStyleReady = true;
    } catch (_) {
      _stopStyleReady = false;
    }
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
