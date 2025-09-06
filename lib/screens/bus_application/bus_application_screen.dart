import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../viewmodels/bus_application_viewmodel.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_constants.dart';

class BusApplicationScreen extends StatelessWidget {
  final VoidCallback? onApplicationComplete; // 신청 완료 콜백
  final String regionId;
  final String regionName;

  const BusApplicationScreen({
    this.onApplicationComplete,
    required this.regionId,
    required this.regionName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BusApplicationViewModel(),
      child: _BusApplicationScreenContent(
        onApplicationComplete: onApplicationComplete,
        regionId: regionId,
        regionName: regionName,
      ),
    );
  }
}

class _BusApplicationScreenContent extends StatelessWidget {
  final VoidCallback? onApplicationComplete;
  final String regionId;
  final String regionName;

  const _BusApplicationScreenContent({
    this.onApplicationComplete,
    required this.regionId,
    required this.regionName,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BusApplicationViewModel>(context);

    // 에러 메시지가 있으면 다이얼로그 표시
    if (viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.showErrorDialog(context, viewModel.errorMessage!);
        viewModel.clearError();
      });
    }

    return _buildBusApplicationScreen(context, viewModel);
  }

  Future<void> _handleApplication(
      BuildContext context, BusApplicationViewModel viewModel) async {
    final success = await viewModel.handleBusApplication(
      context,
      regionId: regionId,
      regionName: regionName,
    );

    if (success) {
      // 신청 완료 콜백 호출
      onApplicationComplete?.call();
      // ViewModel에서 팝업과 화면 전환을 처리하므로 여기서는 처리하지 않음
    }
  }

  Future<void> _handleAddressSearch(
      BuildContext context, BusApplicationViewModel viewModel) async {
    // 카카오 주소 검색 API 호출
    await viewModel.handleAddressSearch(context);
  }

  Widget _buildBusApplicationScreen(
      BuildContext context, BusApplicationViewModel viewModel) {
    return Scaffold(
      backgroundColor: AppColors.background, // 크림색 배경
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            height: 1.0,
            color: AppColors.primaryDisabled,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '버스 신청',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: viewModel.formKey,
            child: ListView(
              children: [
                SizedBox(height: 60),

                // 이름 입력
                _buildNameField(viewModel),

                SizedBox(height: 16),

                // 나이 입력
                _buildAgeField(viewModel),

                SizedBox(height: 16),

                // 전화번호 입력
                _buildPhoneField(viewModel),

                SizedBox(height: 16),

                // 주소 입력
                _buildAddressField(context, viewModel),

                SizedBox(height: 16),

                // 희망 도서 입력
                _buildDesiredBookField(viewModel),

                SizedBox(height: 16),

                // 프로그램 선택
                _buildProgramSelection(viewModel),

                SizedBox(height: 40),

                // 신청 버튼
                _buildApplicationButton(context, viewModel),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
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
                  '신청 지역',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  regionName,
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

  Widget _buildNameField(BusApplicationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/label.png',
              width: 16,
              height: 16,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 12),
            Text(
              '이름',
              style: AppTextStyles.inputLabel,
            ),
          ],
        ),
        SizedBox(height: 8),
        Center(
          child: Container(
            width: AppConstants.inputFieldWidth,
            height: AppConstants.inputFieldHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: viewModel.nameController.text.isNotEmpty
                    ? AppColors.primaryLight
                    : AppColors.grey300,
                width: 1.0,
              ),
            ),
            child: TextFormField(
              controller: viewModel.nameController,
              validator: viewModel.validateName,
              onChanged: (value) => viewModel.notifyListeners(),
              decoration: InputDecoration(
                hintText: '이름을 입력해주세요',
                hintStyle: AppTextStyles.inputHint,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeField(BusApplicationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/label.png',
              width: 16,
              height: 16,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 12),
            Text(
              '나이',
              style: AppTextStyles.inputLabel,
            ),
          ],
        ),
        SizedBox(height: 8),
        Center(
          child: Container(
            width: AppConstants.inputFieldWidth,
            height: AppConstants.inputFieldHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: viewModel.ageController.text.isNotEmpty
                    ? AppColors.primaryLight
                    : AppColors.grey300,
                width: 1.0,
              ),
            ),
            child: TextFormField(
              controller: viewModel.ageController,
              validator: viewModel.validateAge,
              keyboardType: TextInputType.number,
              onChanged: (value) => viewModel.notifyListeners(),
              decoration: InputDecoration(
                hintText: '나이를 입력해주세요',
                hintStyle: AppTextStyles.inputHint,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(BusApplicationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/label.png',
              width: 16,
              height: 16,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 12),
            Text(
              '전화번호',
              style: AppTextStyles.inputLabel,
            ),
          ],
        ),
        SizedBox(height: 8),
        Center(
          child: Container(
            width: AppConstants.inputFieldWidth,
            height: AppConstants.inputFieldHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: viewModel.phoneNumberController.text.isNotEmpty
                    ? AppColors.primaryLight
                    : AppColors.grey300,
                width: 1.0,
              ),
            ),
            child: TextFormField(
              controller: viewModel.phoneNumberController,
              validator: viewModel.validatePhoneNumber,
              keyboardType: TextInputType.phone,
              onChanged: (value) => viewModel.notifyListeners(),
              decoration: InputDecoration(
                hintText: '010-1234-5678',
                hintStyle: AppTextStyles.inputHint,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField(
      BuildContext context, BusApplicationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/label.png',
              width: 16,
              height: 16,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 12),
            Text(
              '주소',
              style: AppTextStyles.inputLabel,
            ),
          ],
        ),
        SizedBox(height: 8),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppConstants.inputFieldWidth - 100,
                height: AppConstants.inputFieldHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: viewModel.addressController.text.isNotEmpty
                        ? AppColors.primaryLight
                        : AppColors.grey300,
                    width: 1.0,
                  ),
                ),
                child: TextFormField(
                  controller: viewModel.addressController,
                  validator: viewModel.validateAddress,
                  onChanged: (value) => viewModel.notifyListeners(),
                  decoration: InputDecoration(
                    hintText: '주소를 입력해주세요',
                    hintStyle: AppTextStyles.inputHint,
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                height: AppConstants.inputFieldHeight,
                width: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () => _handleAddressSearch(context, viewModel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '검색',
                    style: AppTextStyles.customButton.copyWith(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgramSelection(BusApplicationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/label.png',
              width: 16,
              height: 16,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 12),
            Text(
              '희망 프로그램',
              style: AppTextStyles.inputLabel,
            ),
          ],
        ),
        SizedBox(height: 8),
        Center(
          child: Container(
            width: AppConstants.inputFieldWidth,
            height: AppConstants.inputFieldHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (viewModel.selectedProgram?.isNotEmpty ?? false)
                    ? AppColors.primaryLight
                    : AppColors.grey300,
                width: 1.0,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: (viewModel.selectedProgram?.isEmpty ?? true)
                    ? null
                    : viewModel.selectedProgram,
                isExpanded: true,
                hint: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '프로그램을 선택해주세요',
                    style: AppTextStyles.inputHint,
                  ),
                ),
                items: viewModel.programs
                    .map((program) => DropdownMenuItem(
                          value: program,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              program,
                              style: AppTextStyles.inputText,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  viewModel.setSelectedProgram(value);
                  viewModel.notifyListeners();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesiredBookField(BusApplicationViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/label.png',
              width: 16,
              height: 16,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 12),
            Text(
              '희망 도서',
              style: AppTextStyles.inputLabel,
            ),
          ],
        ),
        SizedBox(height: 8),
        Center(
          child: Container(
            width: AppConstants.inputFieldWidth,
            height: AppConstants.inputFieldHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: viewModel.desiredBookController.text.isNotEmpty
                    ? AppColors.primaryLight
                    : AppColors.grey300,
                width: 1.0,
              ),
            ),
            child: TextFormField(
              controller: viewModel.desiredBookController,
              validator: viewModel.validateDesiredBook,
              maxLines: 1,
              onChanged: (value) => viewModel.notifyListeners(),
              decoration: InputDecoration(
                hintText: '읽고 싶은 도서를 입력해주세요',
                hintStyle: AppTextStyles.inputHint,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationButton(
      BuildContext context, BusApplicationViewModel viewModel) {
    // 필수 필드만 확인 (희망 도서와 희망 프로그램 제외)
    bool isAllFieldsFilled = viewModel.nameController.text.isNotEmpty &&
        viewModel.ageController.text.isNotEmpty &&
        viewModel.phoneNumberController.text.isNotEmpty &&
        viewModel.addressController.text.isNotEmpty;

    return Center(
      child: Container(
        width: AppConstants.buttonWidth,
        height: AppConstants.buttonHeight,
        decoration: BoxDecoration(
          color:
              isAllFieldsFilled ? AppColors.primary : AppColors.primaryDisabled,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          onPressed: (viewModel.isLoading || !isAllFieldsFilled)
              ? null
              : () => _handleApplication(context, viewModel),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            viewModel.isLoading ? '신청 중...' : '버스 신청하기',
            style: AppTextStyles.customButton.copyWith(
              color: isAllFieldsFilled ? AppColors.grey50 : AppColors.grey50,
            ),
          ),
        ),
      ),
    );
  }
}
