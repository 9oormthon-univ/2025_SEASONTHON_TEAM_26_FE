import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/search_field.dart';
import '../../widgets/navigation_tabs.dart';
import '../../models/region.dart';
import '../../viewmodels/bus_search_viewmodel.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_constants.dart';

class BusSearchScreen extends StatelessWidget {
    const BusSearchScreen({super.key});

    @override
    Widget build(BuildContext context) {
        return ChangeNotifierProvider(
            create: (context) => BusSearchViewModel(),
            child: _BusSearchScreenContent(),
        );
    }
}

class _BusSearchScreenContent extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        final viewModel = Provider.of<BusSearchViewModel>(context);

        // 에러 메시지가 있으면 스낵바 표시
        if (viewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(viewModel.errorMessage!)),
                );
                viewModel.clearError();
            });
        }

        return _buildBusSearchScreen(context, viewModel);
    }

    Future<void> _handleSearch(BuildContext context, BusSearchViewModel viewModel) async {
        final searchQuery = viewModel.searchController.text.trim();
        print('검색 시작: $searchQuery'); // 디버깅용 로그
        
        if (searchQuery.isNotEmpty) {
            await viewModel.searchRegions(searchQuery);
            
            print('검색 결과 개수: ${viewModel.searchResults.length}'); // 디버깅용 로그
            print('선택된 지역: ${viewModel.selectedRegion?.name}'); // 디버깅용 로그
            
            // 검색 결과가 있으면 신청 현황 페이지로 이동
            if (viewModel.searchResults.isNotEmpty && viewModel.selectedRegion != null) {
                print('페이지 이동 시작'); // 디버깅용 로그
                Navigator.pushNamed(
                    context, 
                    '/bus-application-status',
                    arguments: {
                        'regionId': viewModel.selectedRegion!.regionId,
                        'regionName': viewModel.selectedRegion!.name,
                        'center': viewModel.selectedRegion!.center,
                    },
                );
            } else {
                // 검색 결과가 없으면 에러 메시지 표시
                print('검색 결과 없음 - 스낵바 표시'); // 디버깅용 로그
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('검색 결과가 없습니다. 다른 지역을 검색해보세요.'),
                        backgroundColor: AppColors.error,
                    ),
                );
            }
        } else {
            // 검색어가 비어있으면 에러 메시지 표시
            print('검색어 비어있음 - 스낵바 표시'); // 디버깅용 로그
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('검색할 지역을 입력해주세요.'),
                    backgroundColor: AppColors.error,
                ),
            );
        }
    }

    Widget _buildBusSearchScreen(BuildContext context, BusSearchViewModel viewModel) {
        return Scaffold(
            backgroundColor: AppColors.background, // Ivory-100 배경
            body: SafeArea(
                child: Column(
                    children: [
                        // 통합된 앱바 (로고 + 네비게이션 탭)
                        _buildIntegratedAppBar(context),
                        
                        // 메인 콘텐츠 영역
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                    children: [
                                        SizedBox(height: 20),
                                        
                                        // 검색 필드
                                        _buildSearchField(context, viewModel),
                                        
                                        SizedBox(height: 24), // 24dp 간격 추가
                                        
                                        // 버스 상태 카드 (검색 전 상태만 표시)
                                        Expanded(child: _buildInitialContent()),
                                    ],
                                ),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }

    Widget _buildIntegratedAppBar(BuildContext context) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: AppColors.appBarBackground,
      border: Border(
        bottom: BorderSide(
          color: AppColors.primaryDisabled,
          width: 1.0,
        ),
      ),
    ),
    child: Column(
      children: [
        // Dream Drivers 로고
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/images/dreamdrivers_orange.png',
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // 네비게이션 탭
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              // 버스 현황 탭
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final cur = ModalRoute.of(context)?.settings.name;
                    if (cur == '/bus-status') return; // 중복 네비 방지
                    Navigator.of(context).pushReplacementNamed('/bus-status');
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        '버스 현황',
                        style: AppTextStyles.navigatorTabInactive,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),

              // 버스 신청 탭 (현재 화면)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final cur = ModalRoute.of(context)?.settings.name;
                    if (cur == '/bus-search') return; // 현재면 무시
                    Navigator.of(context).pushReplacementNamed('/bus-search');
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '버스 신청',
                        style: AppTextStyles.navigatorTab,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


    Widget _buildSearchField(BuildContext context, BusSearchViewModel viewModel) {
        return Center(
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    // 검색 필드
                    Container(
                        width: AppConstants.searchFieldWidth,
                        height: AppConstants.searchFieldHeight,
                        decoration: BoxDecoration(
                            color: AppColors.grey50, // Grayscale/Gray-50
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                                BoxShadow(
                                    color: Color(0x1AFFB06F), // spotColor = Color(0x1AFFB06F)
                                    blurRadius: 10, // elevation = 10.dp
                                    offset: Offset(0, 4),
                                ),
                                BoxShadow(
                                    color: Color(0x1AFFB06F), // ambientColor = Color(0x1AFFB06F)
                                    blurRadius: 10, // elevation = 10.dp
                                    offset: Offset(0, 4),
                                ),
                            ],
                        ),
                        child: _buildSearchInputField(context, viewModel),
                    ),
                    
                    SizedBox(width: 12),
                    
                    // 검색 아이콘 버튼
                    Container(
                        width: AppConstants.searchFieldHeight,
                        height: AppConstants.searchFieldHeight,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                                BoxShadow(
                                    color: Color(0x1AFFB06F), // spotColor = Color(0x1AFFB06F)
                                    blurRadius: 10, // elevation = 10.dp
                                    offset: Offset(0, 4),
                                ),
                                BoxShadow(
                                    color: Color(0x1AFFB06F), // ambientColor = Color(0x1AFFB06F)
                                    blurRadius: 10, // elevation = 10.dp
                                    offset: Offset(0, 4),
                                ),
                            ],
                        ),
                        child: IconButton(
                            onPressed: () => _handleSearch(context, viewModel),
                            icon: Icon(
                                Icons.search,
                                color: AppColors.primary, // Primary 색상으로 아이콘만 색상 적용
                                size: 24,
                            ),
                        ),
                    ),
                ],
            ),
        );
    }

    // 검색 입력 필드 (검색 후에는 지역명 고정)
    Widget _buildSearchInputField(BuildContext context, BusSearchViewModel viewModel) {
        // 검색된 상태라면 선택된 지역명을 표시
        if (viewModel.hasSearched && viewModel.selectedRegionName != null) {
            viewModel.searchController.text = viewModel.selectedRegionName!;
        }
        
        return SearchField(
            hintText: '지역을 검색하세요',
            controller: viewModel.searchController,
            suggestions: viewModel.suggestions,
            onSearchPressed: () => _handleSearch(context, viewModel),
            onSuggestionSelected: (String selected) {
                viewModel.setSearchText(selected);
            },
        );
    }



    Widget _buildInitialContent() {
        return Center(
            child: Container(
                width: AppConstants.searchCardWidth,
                height: AppConstants.searchCardHeight,
                decoration: BoxDecoration(
                    color: AppColors.surface, // surface 배경색
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                        BoxShadow(
                            color: Color(0x1AFFB06F), // spotColor = Color(0x1AFFB06F)
                            blurRadius: 10, // elevation = 10.dp
                            offset: Offset(0, 4),
                        ),
                        BoxShadow(
                            color: Color(0x1AFFB06F), // ambientColor = Color(0x1AFFB06F)
                            blurRadius: 10, // elevation = 10.dp
                            offset: Offset(0, 4),
                        ),
                    ],
                ),
                    child: Padding(
                    padding: EdgeInsets.all(32),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            // 큰 버스 아이콘 (bus_front로 변경)
                            Container(
                                width: 200,
                                height: 120,
                                child: Image.asset(
                                    'assets/images/bus_front.png',
                                    fit: BoxFit.contain,
                                ),
                            ),
                            
                            SizedBox(height: 24),
                            
                            // 안내 메시지 (두 번째 이미지에 맞게 수정)
                                            Text(
                                                '우리 지역의 버스를 확인해 보세요!',
                                style: AppTextStyles.searchScreenBody,
                                                textAlign: TextAlign.center,
                                            ),
                                        ],
                                    ),
                                ),
            ),
        );
    }

    Widget _buildBusStatusCard(BuildContext context, BusSearchViewModel viewModel) {
        return Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFFE5E7EB)),
                boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                    ),
                ],
            ),
            child: Padding(
                padding: EdgeInsets.all(32),
                child: _buildInitialContent(), // 항상 초기 상태만 표시
            ),
        );
    }





}