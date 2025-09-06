import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/search_field.dart';
import '../../widgets/navigation_tabs.dart';
import '../../models/region.dart';
import '../../models/bus_application_summary.dart';
import '../../viewmodels/bus_application_status_viewmodel.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_constants.dart';

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
            
            // 검색 결과가 있으면 첫 번째 결과를 자동으로 선택하고 카드 내용 업데이트
            if (viewModel.searchResults.isNotEmpty) {
                final firstRegion = viewModel.searchResults.first;
                viewModel.selectRegion(context, firstRegion);
                
                // 새로운 지역의 신청 현황 데이터 로드
                if (firstRegion.regionId != null) {
                    await viewModel.loadBusApplicationSummary(regionId: firstRegion.regionId!);
                }
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
                                        
                                        SizedBox(height: 24),
                                        
                                        // 상태 콘텐츠만 표시 (검색 결과 카드 제거)
                                        Expanded(child: _buildStatusContent(context, viewModel)),
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
                color: AppColors.appBarBackground, // Ivory-300 배경
                border: Border(
                    bottom: BorderSide(
                        color: AppColors.primaryDisabled, // Primary/Orange-200
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
                            alignment: Alignment.centerLeft, // 왼쪽 정렬
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
                                // 버스 현황 탭 (비활성화)
                                Expanded(
                                    child: GestureDetector(
                                        onTap: () {
                                            // 버스 현황 버튼 - 아직 기능 없음
                                        },
                                        child: Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                                color: AppColors.surface, // Neutral/Ivory-300
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: AppColors.primary, width: 1), // Primary 테두리
                                            ),
                                            child: Center(
                                                child: Text(
                                                    '버스 현황',
                                                    style: AppTextStyles.navigatorTabInactive, // 두번째 폰트 스타일
                                                ),
                                            ),
                                        ),
                                    ),
                                ),
                                SizedBox(width: 12),
                                // 버스 신청 탭 (활성화)
                                Expanded(
                                    child: GestureDetector(
                                        onTap: () {
                                            // 버스 신청 버튼 클릭 시 서치 스크린으로 이동
                                            Navigator.pushNamed(context, '/bus-search');
                                        },
                                        child: Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                                color: AppColors.primary, // Primary/Orange-500
                                                borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Center(
                                                child: Text(
                                                    '버스 신청',
                                                    style: AppTextStyles.navigatorTab, // 첫번째 폰트 스타일
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

    Widget _buildSearchField(BuildContext context, BusApplicationStatusViewModel viewModel) {
        // 초기 로드 시에만 지역명 설정 (사용자가 입력 중일 때는 덮어쓰지 않음)
        if (viewModel.regionName != null && viewModel.searchController.text.isEmpty) {
            viewModel.searchController.text = viewModel.regionName!;
        }
        
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
                                color: AppColors.primary, // Icon itself is primary color
                                size: 24,
                            ),
                        ),
                    ),
                ],
            ),
        );
    }

    // 검색 입력 필드 (사용자가 자유롭게 입력 가능)
    Widget _buildSearchInputField(BuildContext context, BusApplicationStatusViewModel viewModel) {
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
                    // 버스 신청 현황 카드만 표시
                    _buildApplicationStatus(viewModel),
                    
                    SizedBox(height: 40),
                    
                    // 신청 버튼
                    _buildApplicationButton(context, viewModel),
                ],
            ),
        );
    }

    Widget _buildRegionInfo(BusApplicationStatusViewModel viewModel) {
        return Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.surface, // Ivory-200 배경
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFE5E7EB)),
            ),
            child: Row(
                children: [
                    Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                    '선택된 지역',
                                    style: AppTextStyles.inputHint,
                                ),
                                SizedBox(height: 4),
                                Text(
                                    viewModel.regionName ?? '지역을 선택해주세요',
                                    style: AppTextStyles.searchScreenBody,
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
        
        return Center(
            child: Container(
                width: AppConstants.applicationStatusCardWidth,
                height: AppConstants.applicationStatusCardHeight,
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                    color: AppColors.surface, // Ivory-200 배경
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
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: summary != null ? _buildStatusWithData(summary) : _buildStatusWithoutData(),
                ),
            ),
        );
    }

    // 데이터가 있을 때의 상태 표시 (퍼센트 + 잔여인원)
    List<Widget> _buildStatusWithData(summary) {
        return [
            // 퍼센트 표시 (cloud 이미지 위에 텍스트)
            SizedBox(
                width: 100,
                height: 70,
                child: Stack(
                    alignment: Alignment.center,
                    children: [
                        // cloud 이미지
                        Image.asset(
                            'assets/images/cloud.png',
                            fit: BoxFit.contain,
                        ),
                        // 퍼센트 텍스트
                        Text(
                            '${summary.fillRatePercent.toInt()}%',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16.0,
                                height: 1.5, // lineHeight 24.sp / fontSize 16.sp = 1.5
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFF9FAFB), // GrayscaleGray50
                            ),
                        ),
                    ],
                ),
            ),
            
            SizedBox(height: 32),
            
            // 버스 이미지 (bus_side로 변경)
            Container(
                width: 140,
                height: 90,
                child: Image.asset(
                    'assets/images/bus_side.png',
                    fit: BoxFit.contain,
                ),
            ),
            
            SizedBox(height: 32),
            
            // 프로그레스 바
            Container(
                width: double.infinity,
                height: 10,
                decoration: BoxDecoration(
                    color: Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(5),
                ),
                child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: summary.fillRatePercent / 100.0,
                    child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xFFF97316),
                            borderRadius: BorderRadius.circular(5),
                        ),
                    ),
                ),
            ),
            
            SizedBox(height: 20),
            
            // 남은 인원 표시 또는 출발 메시지
            Text(
                summary.remaining == 0 
                    ? '버스가 출발하였습니다'
                    : '버스 출발까지 ${summary.remaining}명 남았어요!',
                style: AppTextStyles.applicationStatusBody,
                textAlign: TextAlign.center,
            ),
        ];
    }

    // 데이터가 없을 때의 상태 표시
    List<Widget> _buildStatusWithoutData() {
        return [
            // 큰 버스 아이콘 (bus_side로 변경)
            Container(
                width: 220,
                height: 140,
                child: Image.asset(
                    'assets/images/bus_side.png',
                    fit: BoxFit.contain,
                ),
            ),
            
            SizedBox(height: 32),
            
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
        // 100% 차면 버튼 비활성화
        final summary = viewModel.summary;
        final isFull = summary?.remaining == 0;
        
        return Center(
            child: Container(
                width: AppConstants.buttonWidth,
                height: AppConstants.buttonHeight,
                decoration: BoxDecoration(
                    color: isFull ? AppColors.primaryDisabled : AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                    onPressed: isFull ? null : () => _handleApplication(context, viewModel),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                        ),
                    ),
                    child: Text(
                        isFull ? '신청 마감' : '꿈마중 버스 신청하기',
                        style: AppTextStyles.customButton.copyWith(
                            color: isFull ? AppColors.grey50 : AppColors.grey50,
                        ),
                    ),
                ),
            ),
        );
    }
}
