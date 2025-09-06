import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "../widgets/custom_text_field.dart";
import "../widgets/custom_button.dart";
import "../viewmodels/signup_viewmodel.dart";
import "../theme/app_text_styles.dart";
import "../theme/app_constants.dart";
import "../theme/app_colors.dart";

class SignupScreen extends StatelessWidget {
    const SignupScreen({super.key});

    @override
    Widget build(BuildContext context) {
        return ChangeNotifierProvider(
            create: (context) => SignupViewModel(),
            child: _SignupScreenContent(),
        );
    }
}

class _SignupScreenContent extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        final viewModel = Provider.of<SignupViewModel>(context);

        // 에러 메시지가 있으면 다이얼로그 표시
        if (viewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
                viewModel.showErrorDialog(context, viewModel.errorMessage!);
                viewModel.clearError();
            });
        }

        return _buildSignupScreen(context, viewModel);
    }

    Future<void> _handleSignup(BuildContext context, SignupViewModel viewModel) async {
        await viewModel.handleSignup(context);
        // ViewModel에서 성공 시 자동으로 로그인 화면으로 이동하므로 여기서는 처리하지 않음
    }

    Widget _buildSignupScreen(BuildContext context, SignupViewModel viewModel) {
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
                    '회원가입',
                    style: AppTextStyles.appBarTitle,    
                ),
                centerTitle: true,
            ),
            body: SafeArea(
                    child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                        key: viewModel.formKey,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                
                                // 이름 입력
                                _buildNameField(viewModel),
                                
                                SizedBox(height: 16),
                                
                                // 아이디 입력 및 중복 검사
                                _buildUserIdField(context, viewModel),
                                
                                SizedBox(height: 16),
                                
                                // 비밀번호 입력
                                _buildPasswordField(viewModel),
                                
                                SizedBox(height: 16),
                                
                                // 비밀번호 확인
                                _buildPasswordCheckField(viewModel),
                                
                                SizedBox(height: 16),
                                
                                // 이메일 입력
                                _buildEmailField(context, viewModel),
                                
                                SizedBox(height: 40),
                                
                                // 회원가입 버튼
                                _buildSignupButton(context, viewModel),
                                
                                SizedBox(height: 20),
                                
                                // 구분선
                                _buildDivider(),
                                
                                SizedBox(height: 20),
                                
                                // 카카오 로그인 버튼
                                _buildKakaoButton(context, viewModel),
                                
                                SizedBox(height: 20),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }

    Widget _buildNameField(SignupViewModel viewModel) {
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
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                        ),
                    ),
                ),
            ],
        );
    }

    Widget _buildUserIdField(BuildContext context, SignupViewModel viewModel) {
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
                            '아이디',
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
                                color: viewModel.idController.text.isNotEmpty 
                                    ? AppColors.primaryLight 
                                    : AppColors.grey300,
                                width: 1.0,
                            ),
                        ),
                        child: TextFormField(
                            controller: viewModel.idController,
                            validator: viewModel.validateUserId,
                            onChanged: (value) => viewModel.notifyListeners(),
                            decoration: InputDecoration(
                                hintText: '아이디를 입력해주세요',
                                hintStyle: AppTextStyles.inputHint,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                        ),
                    ),
                ),
                if (viewModel.usernameCheckMessage != null) ...[
                    SizedBox(height: 8),
                    Center(
                        child: Text(
                            viewModel.usernameCheckMessage!,
                            style: viewModel.isUsernameAvailable 
                                ? AppTextStyles.inputError.copyWith(color: AppColors.success)
                                : AppTextStyles.inputError,
                        ),
                    ),
                ],
            ],
        );
    }

    Widget _buildPasswordField(SignupViewModel viewModel) {
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
                            '비밀번호',
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
                                color: viewModel.pwController.text.isNotEmpty 
                                    ? AppColors.primaryLight 
                                    : AppColors.grey300,
                                width: 1.0,
                            ),
                        ),
                        child: Row(
                            children: [
                                Expanded(
                                    child: TextFormField(
                                        controller: viewModel.pwController,
                                        validator: viewModel.validatePassword,
                                        obscureText: !viewModel.isPasswordVisible,
                                        onChanged: (value) => viewModel.notifyListeners(),
                                        decoration: InputDecoration(
                                            hintText: '비밀번호를 입력해주세요',
                                            hintStyle: AppTextStyles.inputHint,
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        ),
                                    ),
                                ),
                                IconButton(
                                    icon: Icon(
                                        viewModel.isPasswordVisible 
                                            ? Icons.visibility_outlined 
                                            : Icons.visibility_off_outlined, 
                                        color: Color(0xFF9CA3AF), 
                                        size: 20
                                    ),
                                    onPressed: () => viewModel.togglePasswordVisibility(),
                                ),
                                SizedBox(width: 8),
                            ],
                        ),
                    ),
                ),
            ],
        );
    }

    Widget _buildPasswordCheckField(SignupViewModel viewModel) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                                Center(
                    child: Container(
                        width: AppConstants.inputFieldWidth,
                        height: AppConstants.inputFieldHeight,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: viewModel.pwcheckController.text.isNotEmpty 
                                    ? AppColors.primaryLight 
                                    : AppColors.grey300,
                                width: 1.0,
                            ),
                        ),
                                    child: Row(
                            children: [
                                Expanded(
                                                child: TextFormField(
                                        controller: viewModel.pwcheckController,
                                        validator: viewModel.validatePasswordCheck,
                                        obscureText: !viewModel.isPasswordCheckVisible,
                                        onChanged: (value) => viewModel.notifyListeners(),
                                                    decoration: InputDecoration(
                                            hintText: '비밀번호를 다시 입력해주세요',
                                            hintStyle: AppTextStyles.inputHint,
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        ),
                                    ),
                                ),
                                IconButton(
                                    icon: Icon(
                                        viewModel.isPasswordCheckVisible 
                                            ? Icons.visibility_outlined 
                                            : Icons.visibility_off_outlined, 
                                        color: Color(0xFF9CA3AF), 
                                        size: 20
                                    ),
                                    onPressed: () => viewModel.togglePasswordCheckVisibility(),
                                ),
                                SizedBox(width: 8),
                            ],
                        ),
                    ),
                ),
            ],
        );
    }

    Widget _buildEmailField(BuildContext context, SignupViewModel viewModel) {
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
                            '이메일',
                            style: AppTextStyles.inputLabel,
                        ),
                    ],
                ),
                SizedBox(height: 8),
                                Center(
                                    child: Container(
                                        width: AppConstants.inputFieldWidth,
                                        height: AppConstants.inputFieldHeight,
                                        child: Row(
                                            children: [
                                                Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                        height: AppConstants.inputFieldHeight,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(12),
                                                            border: Border.all(
                                                                color: viewModel.emailPrefixController.text.isNotEmpty 
                                                                    ? AppColors.primaryLight 
                                                                    : AppColors.grey300,
                                                                width: 1.0,
                                                            ),
                                                        ),
                                                        child: TextFormField(
                                                            controller: viewModel.emailPrefixController,
                                                            validator: viewModel.validateEmailPrefix,
                                                            onChanged: (value) => viewModel.notifyListeners(),
                                                            decoration: InputDecoration(
                                                                hintText: '이메일',
                                                                hintStyle: AppTextStyles.inputHint,
                                                                border: InputBorder.none,
                                                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                                SizedBox(width: 8),
                                                Container(
                                                    width: 20,
                                                    child: Text(
                                                        '@',
                                                        style: AppTextStyles.inputText,
                                                        textAlign: TextAlign.center,
                                                    ),
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                        height: AppConstants.inputFieldHeight,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(12),
                                                            border: Border.all(
                                                                color: (viewModel.isCustomDomain 
                                                                        ? viewModel.customDomainController.text.isNotEmpty 
                                                                        : viewModel.selectedEmailDomain.isNotEmpty) 
                                                                    ? AppColors.primaryLight 
                                                                    : AppColors.grey300,
                                                                width: 1.0,
                                                            ),
                                                        ),
                                                        child: viewModel.isCustomDomain
                                                            ? TextFormField(
                                                                controller: viewModel.customDomainController,
                                                                validator: viewModel.validateCustomDomain,
                                                                onChanged: (value) => viewModel.notifyListeners(),
                                                                decoration: InputDecoration(
                                                                    hintText: '직접 입력',
                                                                    hintStyle: AppTextStyles.inputHint,
                                                                    border: InputBorder.none,
                                                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                                                ),
                                                            )
                                                            : DropdownButtonHideUnderline(
                                                                child: DropdownButton<String>(
                                                                    value: viewModel.isCustomDomain ? '직접 입력' : (viewModel.selectedEmailDomain.isEmpty ? 'naver.com' : viewModel.selectedEmailDomain),
                                                                    isExpanded: true,
                                                                    style: AppTextStyles.inputText,
                                                                    icon: Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textHint),
                                                                    items: ['naver.com', 'gmail.com', 'daum.net', 'kakao.com', '직접 입력']
                                                                        .map((domain) => DropdownMenuItem(
                                                                            value: domain,
                                                                            child: Padding(
                                                                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                                                                child: Text(
                                                                                    domain,
                                                                                    style: AppTextStyles.inputText,
                                                                                ),
                                                                            ),
                                                                        ))
                                                                        .toList(),
                                                                    onChanged: (value) {
                                                                        if (value != null) {
                                                                            viewModel.setEmailDomain(value);
                                                                            viewModel.notifyListeners();
                                                                        }
                                                                    },
                                                                ),
                                                            ),
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                ),
            ],
        );
    }

    Widget _buildSignupButton(BuildContext context, SignupViewModel viewModel) {
        // 모든 필드가 입력되었는지 확인
        bool isAllFieldsFilled = viewModel.nameController.text.isNotEmpty &&
                                viewModel.idController.text.isNotEmpty &&
                                viewModel.pwController.text.isNotEmpty &&
                                viewModel.pwcheckController.text.isNotEmpty &&
                                viewModel.emailPrefixController.text.isNotEmpty &&
                                (viewModel.isCustomDomain 
                                    ? viewModel.customDomainController.text.isNotEmpty 
                                    : viewModel.selectedEmailDomain.isNotEmpty);

        return Center(
            child: Container(
                width: AppConstants.buttonWidth,
                height: AppConstants.buttonHeight,
                decoration: BoxDecoration(
                    color: isAllFieldsFilled ? AppColors.primary : AppColors.primaryDisabled,
                    borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                    onPressed: (viewModel.isLoading || !isAllFieldsFilled) ? null : () => _handleSignup(context, viewModel),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                        ),
                    ),
                    child: Text(
                        viewModel.isLoading ? '회원가입 중...' : '회원가입',
                        style: AppTextStyles.customButton.copyWith(
                            color: isAllFieldsFilled ? AppColors.grey50 : AppColors.grey50,
                        ),
                    ),
                ),
            ),
        );
    }
    
    Widget _buildDivider() {
        return Row(
            children: [
                Expanded(
                    child: Container(
                        height: 1,
                        color: Color(0xFFFB923C), // Orange-400
                    ),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                        '또는',
                        style: AppTextStyles.dividerText,
                    ),
                ),
                Expanded(
                    child: Container(
                        height: 1,
                        color: Color(0xFFFB923C), // Orange-400
                    ),
                ),
            ],
        );
    }
    
    Widget _buildKakaoButton(BuildContext context, SignupViewModel viewModel) {
        return Center(
            child: Container(
                width: AppConstants.buttonWidth,
                height: AppConstants.buttonHeight,
                decoration: BoxDecoration(
                    color: AppColors.kakaoYellow, // 카카오 옐로우
                    borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                    onPressed: viewModel.isLoading ? null : () => _handleKakaoLogin(context, viewModel),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                        ),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            // 카카오 로고
                            Container(
                                width: 20,
                                height: 20,
                                child: Image.asset(
                                    'assets/images/kakao_logo.png',
                                    fit: BoxFit.contain,
                                ),
                            ),
                            SizedBox(width: 12),
                            Text(
                                '카카오로 계속하기',
                                style: AppTextStyles.kakaoButton,
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
    
    Future<void> _handleKakaoLogin(BuildContext context, SignupViewModel viewModel) async {
        final success = await viewModel.handleKakaoLogin(context);
        if (success) {
            // 성공 시 ViewModel의 콜백에서 처리됨
        }
    }
}