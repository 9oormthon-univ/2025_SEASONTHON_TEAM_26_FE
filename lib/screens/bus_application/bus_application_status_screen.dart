import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/search_field.dart';
import '../../widgets/navigation_tabs.dart';
import '../../models/region.dart';
import '../../models/bus_application_summary.dart';
import '../../viewmodels/bus_application_status_viewmodel.dart';

class BusApplicationStatusScreen extends StatelessWidget {
    final String? regionId;
    final String? regionName;
    final RegionCenter? center;

    const BusApplicationStatusScreen({
        this.regionId,
        this.regionName,
        this.center,
        super.key,
    });

    @override
    Widget build(BuildContext context) {
        return ChangeNotifierProvider(
            create: (context) => BusApplicationStatusViewModel()..initialize(
                regionName, 
                regionId: regionId, 
                center: center != null ? {'latitude': center!.latitude, 'longitude': center!.longitude} : null
            ),
            child: _BusApplicationStatusScreenContent(
                regionId: regionId,
                regionName: regionName,
                center: center,
            ),
        );
    }
}

class _BusApplicationStatusScreenContent extends StatelessWidget {
    final String? regionId;
    final String? regionName;
    final RegionCenter? center;

    const _BusApplicationStatusScreenContent({
        this.regionId,
        this.regionName,
        this.center,
    });

    @override
    Widget build(BuildContext context) {
        final viewModel = Provider.of<BusApplicationStatusViewModel>(context);

        // 에러 메시지가 있으면 스낵바 표시
        if (viewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(viewModel.errorMessage!)),
                );
                viewModel.clearError();
            });
        }

        return _buildBusApplicationStatusScreen(context, viewModel);
    }

    Future<void> _handleSearch(BuildContext context, BusApplicationStatusViewModel viewModel) async {
        final searchQuery = viewModel.searchController.text.trim();
        if (searchQuery.isNotEmpty) {
            await viewModel.searchRegions(searchQuery);
            
            // 검색 결과가 있으면 첫 번째 결과를 자동으로 선택
            if (viewModel.searchResults.isNotEmpty) {
                final firstRegion = viewModel.searchResults.first;
                viewModel.selectRegion(context, firstRegion);
            }
        }
    }

    void _handleApplication(BuildContext context, BusApplicationStatusViewModel viewModel) {
        // 버스 신청 버튼을 눌렀을 때 BusApplication 페이지로 이동
        Navigator.pushNamed(
            context, 
            '/bus-application',
            arguments: {
                'regionId': viewModel.regionId,
                'regionName': viewModel.regionName,
                'center': viewModel.center,
            },
        ).then((_) {
            // 신청 완료 후 돌아왔을 때 데이터 새로고침
            if (viewModel.regionId != null) {
                viewModel.loadBusApplicationSummary(regionId: viewModel.regionId!);
            }
        });
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


    Widget _buildBusApplicationStatusScreen(BuildContext context, BusApplicationStatusViewModel viewModel) {
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
                                    // 버스 신청 버튼 클릭 시 서치 스크린으로 이동
                                    Navigator.pushNamed(context, '/bus-search');
                                },
                                isBusApplicationSelected: true,
                            ),
                            
                            SizedBox(height: 20),
                            // 검색 필드
                            _buildSearchField(context, viewModel),
                            
                            SizedBox(height: 24),
                            
                            // 상태 콘텐츠만 표시 (검색 결과 카드 제거)
                            Expanded(child: _buildStatusContent(context, viewModel)),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildSearchField(BuildContext context, BusApplicationStatusViewModel viewModel) {
        return Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFE5E7EB)),
            ),
            child: SearchField(
                hintText: '지역을 검색하세요',
                controller: viewModel.searchController,
                suggestions: viewModel.suggestions,
                onSearchPressed: () => _handleSearch(context, viewModel),
                onSuggestionSelected: (String selected) {
                    viewModel.setSearchText(selected);
                },
            ),
        );
    }



    Widget _buildStatusContent(BuildContext context, BusApplicationStatusViewModel viewModel) {
        if (viewModel.isLoading) {
            return Center(
                child: CircularProgressIndicator(
                    color: Color(0xFFF97316),
                ),
            );
        }

        return SingleChildScrollView(
            child: Column(
                children: [
                    // 버스 신청 현황
                    _buildApplicationStatus(viewModel),
                    
                    SizedBox(height: 24),
                    
                    // 신청 버튼
                    if (regionId != null && regionName != null && center != null)
                        _buildApplicationButton(context, viewModel),
                ],
            ),
        );
    }

    Widget _buildRegionInfo() {
        return Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFE5E7EB)),
            ),
            child: Row(
                children: [
                    Icon(
                        Icons.location_on,
                        color: Color(0xFFF97316),
                        size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                    '선택된 지역',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9CA3AF),
                                    ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                    regionName!,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF374151),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildApplicationStatus(BusApplicationStatusViewModel viewModel) {
        final summary = viewModel.summary;
        
        return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 60),
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
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                children: summary != null ? _buildStatusWithData(summary) : _buildStatusWithoutData(),
            ),
        );
    }

    // 데이터가 있을 때의 상태 표시 (퍼센트 + 잔여인원)
    List<Widget> _buildStatusWithData(summary) {
        return [
            // 퍼센트 표시 (구름 모양)
            Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: Color(0xFFF97316).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                    '${summary.fillRatePercent.toInt()}%',
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFFF97316),
                        fontWeight: FontWeight.bold,
                    ),
                ),
            ),
            
            SizedBox(height: 24),
            
            // 버스 이미지
            Container(
                width: 120,
                height: 80,
                child: Image.asset(
                    'assets/images/bus1.png',
                    fit: BoxFit.contain,
                ),
            ),
            
            SizedBox(height: 24),
            
            // 프로그레스 바
            Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                    color: Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: summary.fillRatePercent / 100.0,
                    child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xFFF97316),
                            borderRadius: BorderRadius.circular(4),
                        ),
                    ),
                ),
            ),
            
            SizedBox(height: 16),
            
            // 남은 인원 표시
            Text(
                '버스 출발까지 ${summary.remaining}명 남았어요!',
                style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
            ),
        ];
    }

    // 데이터가 없을 때의 상태 표시
    List<Widget> _buildStatusWithoutData() {
        return [
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
                '신청 현황 데이터를 불러올 수 없습니다.',
                                                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFF97316),
                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                              ),
        ];
    }

    Widget _buildStatusItem(String label, String value) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                                              Text(
                    label,
                                                  style: TextStyle(
                                                      fontSize: 14,
                        color: Color(0xFF6B7280),
                    ),
                ),
                Text(
                    value,
                                                  style: TextStyle(
                                                    fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                                                ),
                                              ),
                                            ],
        );
    }

    Widget _buildApplicationButton(BuildContext context, BusApplicationStatusViewModel viewModel) {
        return Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
                color: Color(0xFFF97316), // 오렌지 500
                borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
                onPressed: () => _handleApplication(context, viewModel),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                    ),
                ),
                child: Text(
                    '버스 신청하기',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                    ),
                ),
            ),
        );
    }
}
