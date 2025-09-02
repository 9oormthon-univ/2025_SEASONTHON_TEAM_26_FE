// lib/widgets/kakao_map_view.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kakao_maps_flutter/kakao_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class KakaoMapView extends StatefulWidget {
  const KakaoMapView({super.key});

  @override
  State<KakaoMapView> createState() => KakaoMapViewState();
}

class KakaoMapViewState extends State<KakaoMapView> {
  KakaoMapController? _controller;

  // IDs
  static const _meMarkerId = 'me_marker';
  static const _meStyleId = 'me_style_dot';
  static const _myLayerId = 'my_marker_layer';

  bool _mapReady = false;
  bool _styleRegistered = false;
  bool _layerReady = false;

  @override
  Widget build(BuildContext context) {
    return KakaoMap(
      initialPosition: const LatLng(latitude: 37.5665, longitude: 126.9780),
      initialLevel: 7,
      onMapCreated: (c) async {
        _controller = c;
        await Future.delayed(const Duration(milliseconds: 200));

        // 1) 나만의 마커 레이어 생성 (LabelManager 경로 확실히 준비)
        await _controller!.addMarkerLayer(layerId: _myLayerId);
        _layerReady = true;

        // 2) 파란 점 스타일 등록
        await _ensureBlueDotStyleRegistered();

        if (mounted) setState(() => _mapReady = true);
      },
    );
  }

  /// 부모에서 호출할 공개 메서드: 현위치로 카메라 이동 + 파란 점 마커 표시
  Future<void> goToMyLocation() async {
    if (_controller == null || !_mapReady || !_layerReady) return;
    if (!_styleRegistered) {
      await _ensureBlueDotStyleRegistered();
    }

    // 권한/서비스 체크
    final ok = await _ensureLocationPermission();
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치 권한을 허용해주세요.')),
      );
      return;
    }

    // 현재 좌표
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    final me = LatLng(latitude: pos.latitude, longitude: pos.longitude);

    // 카메라 이동
    await _controller!.moveCamera(
      cameraUpdate: CameraUpdate.fromLatLng(me),
      animation: const CameraAnimation(
        duration: 500,
        autoElevation: true,
        isConsecutive: false,
      ),
    );

    // 기존 마커 제거 후 새로 추가 (내 레이어에)
    try {
      await _controller!.removeMarker(id: _meMarkerId, layerId: _myLayerId);
    } catch (_) {}

    await _controller!.addMarker(
      markerOption: MarkerOption(
        id: _meMarkerId,
        latLng: me,
        styleId: _meStyleId, // 파란 점
      ),
      layerId: _myLayerId,
    );
  }

  // ───────────────── helpers ─────────────────

  Future<void> _ensureBlueDotStyleRegistered() async {
    if (_styleRegistered || _controller == null) return;

    // 에셋 PNG를 24px로 리사이즈
    final Uint8List bytes24 =
        await _loadResizedPngBytes('assets/images/blue_dot.png', 24);

    final styles = [
      MarkerStyle(
        styleId: _meStyleId,
        perLevels: [
          // 생성자엔 width/height 없음 — 리사이즈된 bytes를 직접 넣는다
          MarkerPerLevelStyle.fromBytes(bytes: bytes24),
        ],
      ),
    ];

    await _controller!.registerMarkerStyles(styles: styles);
    _styleRegistered = true;
  }

  Future<Uint8List> _loadResizedPngBytes(
      String assetPath, int targetSizePx) async {
    final raw = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(
      raw.buffer.asUint8List(),
      targetWidth: targetSizePx,
      targetHeight: targetSizePx,
    );
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }
}
