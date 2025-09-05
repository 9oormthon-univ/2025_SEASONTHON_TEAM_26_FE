// lib/widgets/bus_bottom_sheets.dart
import 'package:flutter/material.dart';
import '../models/bus.dart';
import '../models/bus_status.dart';
import '../models/bus_stop.dart';

/// 공용: 상태 → 한글
String _stateToKo(BusRunState s) {
  switch (s) {
    case BusRunState.inService: return '이동중';
    case BusRunState.dwell:     return '정차중';
    case BusRunState.before:    return '운행 전';
    case BusRunState.finished:  return '운행 종료';
  }
}

/// 공용: 상단 그랩바
Widget _grabber() => Center(
  child: Container(
    width: 36, height: 4,
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(2),
    ),
  ),
);

/// 공용: SliverPersistentHeader 델리게이트
class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.child,
  });

  @override
  final double minExtent;
  @override
  final double maxExtent;

  final Widget child;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Theme.of(context).cardColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.minExtent != minExtent ||
           oldDelegate.maxExtent != maxExtent ||
           oldDelegate.child != child;
  }
}

/// 가까운 정류장 시트 (헤더 드래그 가능 + 리스트 스크롤)
class NearestStopSheet extends StatelessWidget {
  const NearestStopSheet({
    super.key,
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
      clipBehavior: Clip.antiAlias,
      child: CustomScrollView(
        controller: controller, // ← 헤더에서도 드래그 인식
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedHeaderDelegate(
              minExtent: 110, maxExtent: 110,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  _grabber(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: const [
                        Icon(Icons.place),
                        SizedBox(width: 8),
                        Expanded(child: Text('가까운 정류장', style: TextStyle(fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 본문
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (loading) const LinearProgressIndicator(),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(error!, style: const TextStyle(color: Colors.red)),
                    ),
                  if (!loading && error == null && stop != null) ...[
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.place),
                      title: Text(stop!.name),
                      subtitle: Text('(${stop!.lat.toStringAsFixed(5)}, ${stop!.lng.toStringAsFixed(5)})'),
                    ),
                    const SizedBox(height: 10),
                    const Text('이 정류장을 지나는 버스', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    if (buses.isEmpty)
                      const Text('해당 정류장을 운행하는 버스가 없습니다.', style: TextStyle(color: Colors.black54)),
                  ],
                ],
              ),
            ),
          ),

          // 버스 리스트 (표준 SliverList)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final b = buses[i];
                return Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, i == buses.length - 1 ? 0 : 8),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.directions_bus_filled),
                      title: Text(b.name),
                      subtitle: Text('courseId: ${b.courseId}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => onTapBus(b),
                    ),
                  ),
                );
              },
              childCount: buses.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

/// 버스 개요 시트 (버스 상태 헤더 고정 + 리스트 스크롤)
class BusOverviewSheet extends StatelessWidget {
  const BusOverviewSheet({
    super.key,
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

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      color: Theme.of(context).cardColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: CustomScrollView(
        controller: controller, // ← 헤더에서도 드래그 인식
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedHeaderDelegate(
              minExtent: 116, maxExtent: 116,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  _grabber(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_bus_filled),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedBus.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (runState != null) Chip(label: Text(_stateToKo(runState!))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),

          // 섹션 타이틀
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('노선 정류장', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),

          // 정류장 리스트
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final s = routeStops[i];
                final isCurrent = currentStopId == s.stopId;
                return ListTile(
                  leading: Icon(isCurrent ? Icons.directions_bus : Icons.radio_button_unchecked),
                  title: Text(s.name),
                  subtitle: Text('(${s.lat.toStringAsFixed(5)}, ${s.lng.toStringAsFixed(5)})'),
                  onTap: () => onTapStop(s), // 부모가 시트 올림
                );
              },
              childCount: routeStops.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

/// 정류장 상태 시트 (정류장 헤더 고정 + 리스트 스크롤)
class BusAtStopSheet extends StatelessWidget {
  const BusAtStopSheet({
    super.key,
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

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      color: Theme.of(context).cardColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: CustomScrollView(
        controller: controller, // ← 헤더에서도 드래그 인식
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedHeaderDelegate(
              minExtent: 140, maxExtent: 140,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  _grabber(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.place),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedStop.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
                ],
              ),
            ),
          ),

          // 섹션 타이틀
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('노선 정류장', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),

          // 정류장 리스트
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final s = routeStops[i];
                final isCurrent = currentStopId == s.stopId;
                return ListTile(
                  leading: Icon(isCurrent ? Icons.directions_bus : Icons.radio_button_unchecked),
                  title: Text(s.name),
                  onTap: () => onTapStop(s), // 부모가 시트 올림
                );
              },
              childCount: routeStops.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
