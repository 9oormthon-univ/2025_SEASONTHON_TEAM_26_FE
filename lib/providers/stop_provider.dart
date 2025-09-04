import 'package:flutter/foundation.dart';
import '../models/bus_stop.dart';
import '../services/stop_api.dart';

class StopProvider extends ChangeNotifier {
  final StopApi api;
  StopProvider(this.api);

  List<Stop> _stops = [];
  Stop? _selected;
  bool _loading = false;

  List<Stop> get stops => _stops;
  Stop? get selected => _selected;
  bool get loading => _loading;

  Future<void> loadNearby({
    required double lat,
    required double lng,
    int radiusMeters = 1000,
    String? dow,
    String? keyword,
  }) async {
    _loading = true; notifyListeners();
    try {
      _stops = await api.fetchNearbyStops(
        lat: lat, lng: lng, radiusMeters: radiusMeters, dow: dow, keyword: keyword,
      );
    } finally {
      _loading = false; notifyListeners();
    }
  }

  void selectStop(Stop? s) {
    _selected = s;
    notifyListeners();
  }

  void clear() {
    _stops = [];
    _selected = null;
    notifyListeners();
  }
}
