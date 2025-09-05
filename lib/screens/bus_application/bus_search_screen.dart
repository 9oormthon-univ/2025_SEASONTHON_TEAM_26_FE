import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/search_field.dart';
import '../../widgets/navigation_tabs.dart';
import '../../models/region.dart';
import '../../viewmodels/bus_search_viewmodel.dart';

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
        if (searchQuery.isNotEmpty) {
            await viewModel.searchRegions(searchQuery);
            
            // 검색 결과가 있으면 신청 현황 페이지로 이동
            if (viewModel.searchResults.isNotEmpty && viewModel.selectedRegion != null) {
        Navigator.pushNamed(
            context, 
            '/bus-application-status',
            arguments: {
                        'regionId': viewModel.selectedRegion!.regionId,
                        'regionName': viewModel.selectedRegion!.name,
                        'center': viewModel.selectedRegion!.center,
                    },
                );
            }
        }
    }

    Widget _buildBusSearchScreen(BuildContext context, BusSearchViewModel viewModel) {
        return Scaffold(
            backgroundColor: Color(0xFFFFF5DF), // 크림색 배경
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                        children: [
                            // Dream Drivers 로고
                            _buildLogo(),
                            
                            SizedBox(height: 20),
                            
                            // 상단 네비게이션 탭
                            NavigationTabs(
                                onBusStatusPressed: () {
                                    // 버스 현황 버튼 - 아직 기능 없음
                                    // 나중에 다른 프론트엔드가 설정할 예정
                                },
                                onBusApplicationPressed: () {
                                    // 버스 신청 버튼 클릭 시 서치 스크린으로 이동 (현재 화면)
                                    // 아무 동작 안 함
                                },
                                isBusApplicationSelected: true,
                            ),
                            
                            SizedBox(height: 20),
                            
                            // 검색 필드
                            _buildSearchField(context, viewModel),
                            
                            SizedBox(height: 24),
                            
                            // 버스 상태 카드 (검색 전 상태만 표시)
                            Expanded(child: _buildInitialContent()),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildLogo() {
        return Row(
            children: [
                Text(
                    'Dream',
                    style: TextStyle(
                        color: Color(0xFFF97316),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                    ),
                ),
                SizedBox(width: 8),
                Text(
                    'Drivers',
                    style: TextStyle(
                        color: Color(0xFFF97316),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                    ),
                ),
            ],
        );
    }


    Widget _buildSearchField(BuildContext context, BusSearchViewModel viewModel) {
        return Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFE5E7EB)),
            ),
            child: _buildSearchInputField(context, viewModel),
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
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                        // 큰 버스 아이콘
                        Container(
                            width: 200,
                            height: 120,
                            child: Image.asset(
                                'assets/images/bus1.png',
                                fit: BoxFit.contain,
                            ),
                        ),
                        
                        SizedBox(height: 24),
                        
                        // 안내 메시지
                                            Text(
                                                '우리 지역의 버스를 확인해 보세요!',
                                                style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFFF97316),
                                fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.center,
                                            ),
                                        ],
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