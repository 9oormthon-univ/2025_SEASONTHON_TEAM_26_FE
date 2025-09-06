import 'package:flutter/material.dart';
import '../models/region.dart';
import '../models/bus_application_summary.dart';
import '../services/api_service.dart';
import '../screens/bus_application/regions.dart';
import 'base_viewmodel.dart';

class BusApplicationStatusViewModel extends BaseViewModel {
  // TextEditingController
  final TextEditingController searchController = TextEditingController();
  
  // 상태 변수들
  final List<String> _suggestions = Regions.list;
  BusApplicationSummary? _summary;
  List<Region> _searchResults = [];
  String? _regionId;
  String? _regionName;
  Map<String, double>? _center;

  // Getters
  List<String> get suggestions => _suggestions;
  BusApplicationSummary? get summary => _summary;
  List<Region> get searchResults => _searchResults;
  String? get regionId => _regionId;
  String? get regionName => _regionName;
  Map<String, double>? get center => _center;

  // 초기화
  void initialize(String? regionName, {String? regionId, Map<String, double>? center}) {
    print('BusApplicationStatusViewModel 초기화: regionName=$regionName, regionId=$regionId'); // 디버깅용 로그
    _regionName = regionName;
    _regionId = regionId;
    _center = center;
    
    if (regionName != null) {
      searchController.text = regionName;
    }
    loadBusApplicationSummary(regionId: regionId);
  }

  // 버스 신청 현황 데이터 로드
  Future<void> loadBusApplicationSummary({String? regionId}) async {
    print('loadBusApplicationSummary 호출: regionId=$regionId'); // 디버깅용 로그
    setLoading(true);
    clearError();

    try {
      final response = await ApiService.getBusApplicationSummary(
        regionId: regionId ?? '1', // 기본값은 서울
      );
      print('API 응답 받음: ${response.regionName}, ${response.appliedCount}/${response.capacity}'); // 디버깅용 로그
      _summary = response;
      notifyListeners();
    } catch (e) {
      setError('데이터를 불러오는 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  // 지역 검색
  Future<void> searchRegions(String keyword) async {
    if (keyword.trim().isEmpty) {
      _searchResults.clear();
      notifyListeners();
      return;
    }

    try {
      final response = await ApiService.searchRegions(
        keyword: keyword.trim(),
        limit: 10,
      );
      
      _searchResults = response.items;
      notifyListeners();
    } catch (e) {
      setError('검색 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 지역 선택
  void selectRegion(BuildContext context, Region region) {
    // 현재 화면에서 지역 정보 업데이트
    _regionId = region.regionId;
    _regionName = region.name;
    _center = region.center != null ? {
      'latitude': region.center!.latitude,
      'longitude': region.center!.longitude,
    } : null;
    
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
    required Map<String, double> center,
  }) {
    Navigator.pushNamed(
      context,
      '/bus-application',
      arguments: {
        'regionId': regionId,
        'regionName': regionName,
        'center': center,
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
