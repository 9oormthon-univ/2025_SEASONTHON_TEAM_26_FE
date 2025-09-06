import 'dart:async';
import 'package:flutter/material.dart';
import '../models/region.dart';
import 'base_viewmodel.dart';

class BusSearchViewModel extends BaseViewModel {
  // TextEditingController
  final TextEditingController searchController = TextEditingController();
  
  // 상태 변수들
  List<String> _suggestions = []; // 기본 정적 리스트
  List<Region> _searchResults = [];
  bool _hasSearched = false;
  String? _selectedRegionName;
  Region? _selectedRegion;
  
  // 스로틀링 관련 변수들
  Timer? _searchTimer;
  static const Duration _searchDelay = Duration(milliseconds: 500); // 500ms 지연

  // Getters
  List<String> get suggestions => _suggestions;
  List<Region> get searchResults => _searchResults;
  bool get hasSearched => _hasSearched;
  String? get selectedRegionName => _selectedRegionName;
  Region? get selectedRegion => _selectedRegion;

  // 스로틀링된 지역 검색 (텍스트 변경 시 자동 호출)
  void searchRegionsWithThrottle(String keyword) {
    // 이전 타이머 취소
    _searchTimer?.cancel();
    
    // 빈 문자열이면 검색 결과 초기화
    if (keyword.trim().isEmpty) {
      clearSearchResults();
      return;
    }
    
    // 500ms 후에 검색 실행
    _searchTimer = Timer(_searchDelay, () {
      searchRegions(keyword);
    });
  }

  // 목업 지역 데이터 (공통으로 사용)
  static final List<Region> _mockRegions = [
    Region(regionId: 'RGN_001', name: '서울특별시', children: [
      Region(regionId: 'RGN_001_001', name: '강남구'),
      Region(regionId: 'RGN_001_002', name: '강서구'),
      Region(regionId: 'RGN_001_003', name: '강북구'),
      Region(regionId: 'RGN_001_004', name: '강동구'),
      Region(regionId: 'RGN_001_005', name: '송파구'),
      Region(regionId: 'RGN_001_006', name: '서초구'),
    ]),
    Region(regionId: 'RGN_002', name: '경기도', children: [
      Region(regionId: 'RGN_002_001', name: '수원시'),
      Region(regionId: 'RGN_002_002', name: '성남시'),
      Region(regionId: 'RGN_002_003', name: '의정부시'),
      Region(regionId: 'RGN_002_004', name: '안양시'),
      Region(regionId: 'RGN_002_005', name: '부천시'),
    ]),
    Region(regionId: 'RGN_003', name: '인천광역시', children: [
      Region(regionId: 'RGN_003_001', name: '연수구'),
      Region(regionId: 'RGN_003_002', name: '남동구'),
      Region(regionId: 'RGN_003_003', name: '부평구'),
    ]),
    Region(regionId: 'RGN_004', name: '강원특별자치도', children: [
      Region(regionId: 'RGN_004_001', name: '춘천시'),
      Region(regionId: 'RGN_004_002', name: '원주시'),
      Region(regionId: 'RGN_004_003', name: '강릉시'),
    ]),
    Region(regionId: 'RGN_005', name: '부산광역시', children: [
      Region(regionId: 'RGN_005_001', name: '해운대구'),
      Region(regionId: 'RGN_005_002', name: '사하구'),
      Region(regionId: 'RGN_005_003', name: '금정구'),
    ]),
  ];

  // 다른 ViewModel에서 지역 데이터에 접근할 수 있도록 하는 getter
  static List<Region> getMockRegions() => _mockRegions;

  // 지역 검색 (목업 데이터 사용)
  Future<void> searchRegions(String keyword) async {
    if (keyword.trim().isEmpty) {
      setError('검색어를 입력해주세요.');
      return;
    }

    print('🔍 지역 검색 시작: $keyword');
    setLoading(true);
    clearError();

    // 목업 데이터에서 검색
    await Future.delayed(Duration(milliseconds: 300)); // 로딩 시뮬레이션
    
    List<Region> filteredRegions = [];
    List<String> allRegionNames = [];
    
    for (var region in _mockRegions) {
      // 최상위 지역 검색
      if (region.name.toLowerCase().contains(keyword.toLowerCase())) {
        filteredRegions.add(region);
      }
      allRegionNames.add(region.name);
      
      // 하위 지역 검색
      if (region.children != null) {
        for (var child in region.children!) {
          if (child.name.toLowerCase().contains(keyword.toLowerCase())) {
            filteredRegions.add(child);
          }
          allRegionNames.add(child.name);
        }
      }
    }
    
    print('🔍 검색 응답 받음: ${filteredRegions.length}개 결과');
    
    _searchResults = filteredRegions;
    _hasSearched = true;
    _selectedRegionName = keyword.trim();
    
    // 입력한 키워드가 포함된 지역명만 필터링하고 최대 5개로 제한
    final filteredSuggestions = allRegionNames
        .where((name) => name.toLowerCase().contains(keyword.toLowerCase()))
        .take(5)
        .toList();
    
    _suggestions = filteredSuggestions;
    print('🔍 전체 지역 수: ${allRegionNames.length}개');
    print('🔍 필터링된 suggestions: ${_suggestions.length}개 항목 - $_suggestions');
    
    // 검색 결과가 있으면 첫 번째 결과를 선택된 지역으로 설정
    if (filteredRegions.isNotEmpty) {
      _selectedRegion = filteredRegions.first;
      print('🔍 검색 성공: ${_selectedRegion?.name}');
      print('🔍 선택된 지역 ID: ${_selectedRegion?.regionId}');
    } else {
      print('🔍 검색 결과 없음');
      _selectedRegion = null;
    }
    
    notifyListeners();
    setLoading(false);
  }

  // 지역 선택
  void selectRegion(BuildContext context, Region region) {
    Navigator.pushNamed(
      context, 
      '/bus-application-status',
      arguments: {
        'regionId': region.regionId,
        'regionName': region.name,
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
    _hasSearched = false;
    _selectedRegionName = null;
    _selectedRegion = null;
    _suggestions = []; // 빈 리스트로 초기화
    notifyListeners();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
