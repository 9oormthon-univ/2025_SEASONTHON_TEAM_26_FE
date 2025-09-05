import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kakao_maps_flutter/kakao_maps_flutter.dart';
import '../models/bus_stop.dart';

typedef StopTapCallback = void Function(Stop stop);

class KakaoMapView extends StatefulWidget {
  const KakaoMapView({super.key, this.onStopMarkerTap});
  final StopTapCallback? onStopMarkerTap;

  @override
  State<KakaoMapView> createState() => KakaoMapViewState();
}

class KakaoMapViewState extends State<KakaoMapView> {
  KakaoMapController? _controller;

  static const _myLayerId = 'layer_my';
  static const _stopsLayerId = 'layer_stops';
  static const _meMarkerId = 'me_marker';
  static const _meStyleId = 'me_style_dot';
  static const _stopStyleSmall = 'stop_style_60';
  static const _stopStyleLarge = 'stop_style_80';

  bool _mapReady = false;
  bool _myLayerReady = false;
  bool _stopsLayerReady = false;
  bool _meStyleReady = false;
  bool _stopStyleReady = false;

  LatLng? _lastMe;
  final Map<int, String> _stopIdToMarkerId = {};
  final Map<String, Stop> _markerIdToStop = {};
  String? _selectedMarkerId;

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
        await Future.delayed(const Duration(milliseconds: 200));

        await _controller!.addMarkerLayer(layerId: _myLayerId);
        _myLayerReady = true;
        await _controller!.addMarkerLayer(layerId: _stopsLayerId);
        _stopsLayerReady = true;

        await _ensureMyDotStyle();
        await _ensureStopStyle();

        _labelClickSub = _controller!.onLabelClickedStream.listen((event) async {
          final markerId = event.labelId;
          final stop = _markerIdToStop[markerId];
          if (stop == null) return;

          // 이전 선택 복구
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
          // 새 선택 확대
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

  // ─── 내 위치 점/카메라 제어 ───
  Future<void> setMyLocation(LatLng me, {bool moveCamera = true}) async {
    if (_controller == null || !_mapReady || !_myLayerReady) return;
    if (moveCamera) {
      await _controller!.moveCamera(
        cameraUpdate: CameraUpdate.fromLatLng(me),
        animation: const CameraAnimation(duration: 500, autoElevation: true, isConsecutive: false),
      );
    }
    try {
      await _controller!.removeMarker(id: _meMarkerId, layerId: _myLayerId);
    } catch (_) {}
    await _controller!.addMarker(
      markerOption: MarkerOption(
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

  Future<void> moveCameraTo(LatLng target) async {
    if (_controller == null || !_mapReady) return;
    await _controller!.moveCamera(
      cameraUpdate: CameraUpdate.fromLatLng(target),
      animation: const CameraAnimation(duration: 500, autoElevation: true, isConsecutive: false),
    );
  }

  // ─── 정류장 ───
  Future<void> setStops(List<Stop> stops) async {
    if (_controller == null || !_mapReady || !_stopsLayerReady) return;
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
        markerOption: MarkerOption(
          id: id,
          latLng: LatLng(latitude: s.lat, longitude: s.lng),
          styleId: _stopStyleReady ? _stopStyleSmall : null,
          text: s.name,
        ),
        layerId: _stopsLayerId,
      );
      _stopIdToMarkerId[s.stopId] = id;
      _markerIdToStop[id] = s;
    }
  }

  // ─── 스타일 등록/헬퍼 ───
  Future<void> _ensureMyDotStyle() async {
    if (_meStyleReady || _controller == null) return;
    try {
      final bytes = await _loadResizedPngBytes('assets/images/blue_dot.png', 24);
      final styles = [MarkerStyle(styleId: _meStyleId, perLevels: [MarkerPerLevelStyle.fromBytes(bytes: bytes)])];
      await _controller!.registerMarkerStyles(styles: styles);
      _meStyleReady = true;
    } catch (_) {}
  }

  Future<void> _ensureStopStyle() async {
    if (_stopStyleReady || _controller == null) return;
    try {
      final bytes60 = await _loadResizedPngBytes('assets/images/stop_pin.png', 60);
      final bytes80 = await _loadResizedPngBytes('assets/images/stop_pin.png', 80);
      final styles = [
        MarkerStyle(styleId: _stopStyleSmall, perLevels: [MarkerPerLevelStyle.fromBytes(bytes: bytes60)]),
        MarkerStyle(styleId: _stopStyleLarge, perLevels: [MarkerPerLevelStyle.fromBytes(bytes: bytes80)]),
      ];
      await _controller!.registerMarkerStyles(styles: styles);
      _stopStyleReady = true;
    } catch (_) {}
  }

  Future<void> _replaceStopMarker({required String markerId, required Stop stop, required String? styleId}) async {
    try {
      await _controller?.removeMarker(id: markerId, layerId: _stopsLayerId);
    } catch (_) {}
    await _controller?.addMarker(
      markerOption: MarkerOption(id: markerId, latLng: LatLng(latitude: stop.lat, longitude: stop.lng), styleId: styleId, text: stop.name),
      layerId: _stopsLayerId,
    );
  }

  Future<Uint8List> _loadResizedPngBytes(String path, int size) async {
    final raw = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(raw.buffer.asUint8List(), targetWidth: size, targetHeight: size);
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }
}
