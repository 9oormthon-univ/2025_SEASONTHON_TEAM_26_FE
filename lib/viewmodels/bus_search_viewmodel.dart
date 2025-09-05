import 'package:flutter/material.dart';
import '../models/region.dart';
import '../services/api_service.dart';
import '../screens/bus_application/regions.dart';
import 'base_viewmodel.dart';

class BusSearchViewModel extends BaseViewModel {
  // TextEditingController
  final TextEditingController searchController = TextEditingController();
  
  // 상태 변수들
  final List<String> _suggestions = Regions.list;
  List<Region> _searchResults = [];
  bool _hasSearched = false;
  String? _selectedRegionName;
  Region? _selectedRegion;

  // Getters
  List<String> get suggestions => _suggestions;
  List<Region> get searchResults => _searchResults;
  bool get hasSearched => _hasSearched;
  String? get selectedRegionName => _selectedRegionName;
  Region? get selectedRegion => _selectedRegion;

  // 지역 검색
  Future<void> searchRegions(String keyword) async {
    if (keyword.trim().isEmpty) {
      setError('검색어를 입력해주세요.');
      return;
    }

    setLoading(true);
    clearError();

    try {
      final response = await ApiService.searchRegions(
        keyword: keyword.trim(),
        limit: 10,
      );
      
      _searchResults = response.items;
      _hasSearched = true; // 검색 완료 상태로 설정
      _selectedRegionName = keyword.trim();
      
      // 검색 결과가 있으면 첫 번째 결과를 선택된 지역으로 설정
      if (response.items.isNotEmpty) {
        _selectedRegion = response.items.first;
      }
      
      notifyListeners();

      // 검색 결과가 없으면 에러 메시지
      if (response.items.isEmpty) {
        setError('검색 결과가 없습니다.');
      }
    } catch (e) {
      setError('검색 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  // 지역 선택
  void selectRegion(BuildContext context, Region region) {
    Navigator.pushNamed(
      context, 
      '/bus-application-status',
      arguments: {
        'regionId': region.regionId,
        'regionName': region.name,
        'center': region.center,
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
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
