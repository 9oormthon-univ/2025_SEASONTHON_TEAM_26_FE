import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../viewmodels/bus_application_viewmodel.dart';

class BusApplicationScreen extends StatelessWidget {
    final VoidCallback? onApplicationComplete; // 신청 완료 콜백
    final String regionId;
    final String regionName;
    final Map<String, double> center;

    const BusApplicationScreen({
        this.onApplicationComplete,
        required this.regionId,
        required this.regionName,
        required this.center,
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
                center: center,
            ),
        );
    }
}

class _BusApplicationScreenContent extends StatelessWidget {
    final VoidCallback? onApplicationComplete;
    final String regionId;
    final String regionName;
    final Map<String, double> center;

    const _BusApplicationScreenContent({
        this.onApplicationComplete,
        required this.regionId,
        required this.regionName,
        required this.center,
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

    Future<void> _handleApplication(BuildContext context, BusApplicationViewModel viewModel) async {
        final success = await viewModel.handleBusApplication(
            context,
            regionId: regionId,
            regionName: regionName,
            center: center,
        );
        
        if (success) {
            // 신청 완료 콜백 호출
            onApplicationComplete?.call();
            // ViewModel에서 팝업과 화면 전환을 처리하므로 여기서는 처리하지 않음
        }
    }

    Future<void> _handleAddressSearch(BuildContext context, BusApplicationViewModel viewModel) async {
        // 카카오 주소 검색 API 호출
        await viewModel.handleAddressSearch(context);
    }

    Widget _buildBusApplicationScreen(BuildContext context, BusApplicationViewModel viewModel) {
        return Scaffold(
            backgroundColor: Color(0xFFFFF5DF), // 크림색 배경
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Color(0xFF6B7280)),
                    onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                    '버스 신청',
                    style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                    ),
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
                                SizedBox(height: 20),
                                
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
                Text(
                    '이름',
                    style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                    ),
                ),
                SizedBox(height: 8),
                Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFE5E7EB)),
                    ),
                    child: TextFormField(
                        controller: viewModel.nameController,
                        validator: viewModel.validateName,
                        decoration: InputDecoration(
                            hintText: '이름을 입력해주세요',
                            hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                Text(
                    '나이',
                    style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                    ),
                ),
                SizedBox(height: 8),
                Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFE5E7EB)),
                    ),
                    child: TextFormField(
                        controller: viewModel.ageController,
                        validator: viewModel.validateAge,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: '나이를 입력해주세요',
                            hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                Text(
                    '전화번호',
                    style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                    ),
                ),
                SizedBox(height: 8),
                Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFE5E7EB)),
                    ),
                    child: TextFormField(
                        controller: viewModel.phoneNumberController,
                        validator: viewModel.validatePhoneNumber,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            hintText: '010-1234-5678',
                            hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                    ),
                ),
            ],
        );
    }

    Widget _buildAddressField(BuildContext context, BusApplicationViewModel viewModel) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                    '주소',
                    style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                    ),
                ),
                SizedBox(height: 8),
                Row(
                    children: [
                        Expanded(
                            child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Color(0xFFE5E7EB)),
                                ),
                                child: TextFormField(
                                    controller: viewModel.addressController,
                                    validator: viewModel.validateAddress,
                                    decoration: InputDecoration(
                                        hintText: '주소를 입력해주세요',
                                        hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                ),
                            ),
                        ),
                        SizedBox(width: 12),
                        Container(
                            height: 56,
                            width: 80,
                            decoration: BoxDecoration(
                                color: Color(0xFFF97316),
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
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                    ),
                                ),
                            ),
                        ),
                    ],
                ),
            ],
        );
    }

    Widget _buildProgramSelection(BusApplicationViewModel viewModel) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                    '희망 프로그램',
                    style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                    ),
                ),
                SizedBox(height: 8),
                Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFE5E7EB)),
                    ),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            value: viewModel.selectedProgram,
                            isExpanded: true,
                            hint: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                    '프로그램을 선택해주세요',
                                    style: TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                    ),
                                ),
                            ),
                            items: viewModel.programs.map((program) => DropdownMenuItem(
                                value: program,
                                child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                        program,
                                        style: TextStyle(
                                            color: Color(0xFF374151),
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                        ),
                                    ),
                                ),
                            )).toList(),
                            onChanged: (value) {
                                viewModel.setSelectedProgram(value);
                            },
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
                Text(
                    '희망 도서',
                    style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                    ),
                ),
                SizedBox(height: 8),
                Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFE5E7EB)),
                    ),
                    child: TextFormField(
                        controller: viewModel.desiredBookController,
                        validator: viewModel.validateDesiredBook,
                        maxLines: 1,
                        decoration: InputDecoration(
                            hintText: '읽고 싶은 도서를 입력해주세요',
                            hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                    ),
                ),
            ],
        );
    }

    Widget _buildApplicationButton(BuildContext context, BusApplicationViewModel viewModel) {
        return Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
                color: Color(0xFFF97316), // 오렌지 500
                borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : () => _handleApplication(context, viewModel),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                    ),
                ),
                child: Text(
                    viewModel.isLoading ? '신청 중...' : '버스 신청하기',
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
