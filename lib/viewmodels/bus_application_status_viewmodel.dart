import 'package:flutter/material.dart';
import '../models/region.dart';
import '../models/bus_application_summary.dart';
import 'bus_search_viewmodel.dart';
import 'base_viewmodel.dart';

class BusApplicationStatusViewModel extends BaseViewModel {
  // TextEditingController
  final TextEditingController searchController = TextEditingController();
  
  // 상태 변수들
  final List<String> _suggestions = [];
  BusApplicationSummary? _summary;
  List<Region> _searchResults = [];
  String? _regionId;
  String? _regionName;
  // Getters
  List<String> get suggestions => _suggestions;
  BusApplicationSummary? get summary => _summary;
  List<Region> get searchResults => _searchResults;
  String? get regionId => _regionId;
  String? get regionName => _regionName;

  // 초기화
  void initialize(String? regionName, {String? regionId}) {
    print('BusApplicationStatusViewModel 초기화: regionName=$regionName, regionId=$regionId'); // 디버깅용 로그
    _regionName = regionName;
    _regionId = regionId;
    
    if (regionName != null) {
      searchController.text = regionName;
    }
    loadBusApplicationSummary(regionId: regionId);
  }

  // 목업 신청 현황 데이터 (static으로 변경해서 다른 ViewModel에서도 접근 가능)
  static Map<String, BusApplicationSummary> _mockSummaries = {
    'RGN_001': BusApplicationSummary(
      regionId: 'RGN_001',
      regionName: '서울특별시',
      appliedCount: 35,
      capacity: 50,
      remaining: 15,
      fillRatePercent: 70.0,
    ),
    'RGN_001_001': BusApplicationSummary(
      regionId: 'RGN_001_001',
      regionName: '강남구',
      appliedCount: 42,
      capacity: 50,
      remaining: 8,
      fillRatePercent: 84.0,
    ),
    'RGN_001_002': BusApplicationSummary(
      regionId: 'RGN_001_002',
      regionName: '강서구',
      appliedCount: 28,
      capacity: 50,
      remaining: 22,
      fillRatePercent: 56.0,
    ),
    'RGN_001_003': BusApplicationSummary(
      regionId: 'RGN_001_003',
      regionName: '강북구',
      appliedCount: 15,
      capacity: 50,
      remaining: 35,
      fillRatePercent: 30.0,
    ),
    'RGN_001_004': BusApplicationSummary(
      regionId: 'RGN_001_004',
      regionName: '강동구',
      appliedCount: 38,
      capacity: 50,
      remaining: 12,
      fillRatePercent: 76.0,
    ),
    'RGN_001_005': BusApplicationSummary(
      regionId: 'RGN_001_005',
      regionName: '송파구',
      appliedCount: 45,
      capacity: 50,
      remaining: 5,
      fillRatePercent: 90.0,
    ),
    'RGN_001_006': BusApplicationSummary(
      regionId: 'RGN_001_006',
      regionName: '서초구',
      appliedCount: 33,
      capacity: 50,
      remaining: 17,
      fillRatePercent: 66.0,
    ),
    'RGN_002': BusApplicationSummary(
      regionId: 'RGN_002',
      regionName: '경기도',
      appliedCount: 22,
      capacity: 50,
      remaining: 28,
      fillRatePercent: 44.0,
    ),
    'RGN_002_001': BusApplicationSummary(
      regionId: 'RGN_002_001',
      regionName: '수원시',
      appliedCount: 40,
      capacity: 50,
      remaining: 10,
      fillRatePercent: 80.0,
    ),
    'RGN_002_002': BusApplicationSummary(
      regionId: 'RGN_002_002',
      regionName: '성남시',
      appliedCount: 18,
      capacity: 50,
      remaining: 32,
      fillRatePercent: 36.0,
    ),
    'RGN_002_003': BusApplicationSummary(
      regionId: 'RGN_002_003',
      regionName: '의정부시',
      appliedCount: 25,
      capacity: 50,
      remaining: 25,
      fillRatePercent: 50.0,
    ),
    'RGN_002_004': BusApplicationSummary(
      regionId: 'RGN_002_004',
      regionName: '안양시',
      appliedCount: 31,
      capacity: 50,
      remaining: 19,
      fillRatePercent: 62.0,
    ),
    'RGN_002_005': BusApplicationSummary(
      regionId: 'RGN_002_005',
      regionName: '부천시',
      appliedCount: 12,
      capacity: 50,
      remaining: 38,
      fillRatePercent: 24.0,
    ),
    'RGN_003': BusApplicationSummary(
      regionId: 'RGN_003',
      regionName: '인천광역시',
      appliedCount: 19,
      capacity: 50,
      remaining: 31,
      fillRatePercent: 38.0,
    ),
    'RGN_003_001': BusApplicationSummary(
      regionId: 'RGN_003_001',
      regionName: '연수구',
      appliedCount: 36,
      capacity: 50,
      remaining: 14,
      fillRatePercent: 72.0,
    ),
    'RGN_003_002': BusApplicationSummary(
      regionId: 'RGN_003_002',
      regionName: '남동구',
      appliedCount: 27,
      capacity: 50,
      remaining: 23,
      fillRatePercent: 54.0,
    ),
    'RGN_003_003': BusApplicationSummary(
      regionId: 'RGN_003_003',
      regionName: '부평구',
      appliedCount: 21,
      capacity: 50,
      remaining: 29,
      fillRatePercent: 42.0,
    ),
    'RGN_004': BusApplicationSummary(
      regionId: 'RGN_004',
      regionName: '강원특별자치도',
      appliedCount: 8,
      capacity: 50,
      remaining: 42,
      fillRatePercent: 16.0,
    ),
    'RGN_004_001': BusApplicationSummary(
      regionId: 'RGN_004_001',
      regionName: '춘천시',
      appliedCount: 29,
      capacity: 50,
      remaining: 21,
      fillRatePercent: 58.0,
    ),
    'RGN_004_002': BusApplicationSummary(
      regionId: 'RGN_004_002',
      regionName: '원주시',
      appliedCount: 16,
      capacity: 50,
      remaining: 34,
      fillRatePercent: 32.0,
    ),
    'RGN_004_003': BusApplicationSummary(
      regionId: 'RGN_004_003',
      regionName: '강릉시',
      appliedCount: 23,
      capacity: 50,
      remaining: 27,
      fillRatePercent: 46.0,
    ),
    'RGN_005': BusApplicationSummary(
      regionId: 'RGN_005',
      regionName: '부산광역시',
      appliedCount: 14,
      capacity: 50,
      remaining: 36,
      fillRatePercent: 28.0,
    ),
    'RGN_005_001': BusApplicationSummary(
      regionId: 'RGN_005_001',
      regionName: '해운대구',
      appliedCount: 37,
      capacity: 50,
      remaining: 13,
      fillRatePercent: 74.0,
    ),
    'RGN_005_002': BusApplicationSummary(
      regionId: 'RGN_005_002',
      regionName: '사하구',
      appliedCount: 20,
      capacity: 50,
      remaining: 30,
      fillRatePercent: 40.0,
    ),
    'RGN_005_003': BusApplicationSummary(
      regionId: 'RGN_005_003',
      regionName: '금정구',
      appliedCount: 26,
      capacity: 50,
      remaining: 24,
      fillRatePercent: 52.0,
    ),
  };

  // 버스 신청 현황 데이터 로드 (목업 데이터 사용)
  Future<void> loadBusApplicationSummary({String? regionId}) async {
    print('loadBusApplicationSummary 호출: regionId=$regionId');
    print('🔍 버스 신청 현황 로드 시작: regionId=$regionId');
    setLoading(true);
    clearError();

    // 목업 데이터에서 로드
    await Future.delayed(Duration(milliseconds: 300)); // 로딩 시뮬레이션
    
    final summary = _mockSummaries[regionId ?? 'RGN_001'];
    if (summary != null) {
      print('🔍 목업 데이터 로드: ${summary.regionName}, ${summary.appliedCount}/${summary.capacity}');
      _summary = summary;
    } else {
      // 기본값 설정
      _summary = BusApplicationSummary(
        regionId: regionId ?? 'RGN_001',
        regionName: _regionName ?? '서울특별시',
        appliedCount: 30,
        capacity: 50,
        remaining: 20,
        fillRatePercent: 60.0,
      );
    }
    
    notifyListeners();
    setLoading(false);
  }

  // BusSearchViewModel의 지역 데이터를 공통으로 사용
  static List<Region> get _mockRegions => BusSearchViewModel.getMockRegions();

  // 지역 검색 (목업 데이터 사용)
  Future<void> searchRegions(String keyword) async {
    if (keyword.trim().isEmpty) {
      _searchResults.clear();
      notifyListeners();
      return;
    }

    // 목업 데이터에서 검색
    List<Region> filteredRegions = [];
    
    for (var region in _mockRegions) {
      // 최상위 지역 검색
      if (region.name.toLowerCase().contains(keyword.toLowerCase())) {
        filteredRegions.add(region);
      }
      
      // 하위 지역 검색
      if (region.children != null) {
        for (var child in region.children!) {
          if (child.name.toLowerCase().contains(keyword.toLowerCase())) {
            filteredRegions.add(child);
          }
        }
      }
    }
    
    _searchResults = filteredRegions;
    notifyListeners();
  }

  // 지역 선택
  void selectRegion(BuildContext context, Region region) {
    // 현재 화면에서 지역 정보 업데이트
    _regionId = region.regionId;
    _regionName = region.name;
    
    // 검색 필드에 선택된 지역명 설정
    searchController.text = region.name;
    
    // 새로운 지역의 데이터 로드
    loadBusApplicationSummary(regionId: region.regionId);
    
    notifyListeners();
  }

  // 버스 신청 화면으로 이동
  void navigateToApplication(BuildContext context, {
    required String regionId,
    required String regionName,
  }) {
    Navigator.pushNamed(
      context,
      '/bus-application',
      arguments: {
        'regionId': regionId,
        'regionName': regionName,
      },
    );
  }

  // 검색어 설정
  void setSearchText(String text) {
    searchController.text = text;
    notifyListeners();
  }

  // 검색 결과 초기화
  void clearSearchResults() {
    _searchResults.clear();
    notifyListeners();
  }

  // 신청 후 데이터 업데이트 (다른 ViewModel에서 호출)
  static void updateApplicationCount(String regionId) {
    final summary = _mockSummaries[regionId];
    if (summary != null && summary.appliedCount < summary.capacity) {
      final newAppliedCount = summary.appliedCount + 1;
      final newRemainingCount = summary.capacity - newAppliedCount;
      final newApplicationRate = (newAppliedCount / summary.capacity) * 100;
      
      _mockSummaries[regionId] = BusApplicationSummary(
        regionId: summary.regionId,
        regionName: summary.regionName,
        appliedCount: newAppliedCount,
        capacity: summary.capacity,
        remaining: newRemainingCount,
        fillRatePercent: newApplicationRate,
      );
      
      print('📊 신청 현황 업데이트: ${summary.regionName} - ${newAppliedCount}/${summary.capacity} (${newApplicationRate.toStringAsFixed(1)}%)');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
