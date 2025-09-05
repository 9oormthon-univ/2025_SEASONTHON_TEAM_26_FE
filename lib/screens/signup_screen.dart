import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "../widgets/custom_text_field.dart";
import "../widgets/custom_button.dart";
import "../viewmodels/signup_viewmodel.dart";

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
            backgroundColor: Color(0xFFFFF5DF), // 크림색 배경
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Color(0xFF6B7280)),
                    onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                    '회원가입',
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

    Widget _buildUserIdField(BuildContext context, SignupViewModel viewModel) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                    '아이디',
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
                        controller: viewModel.idController,
                        validator: viewModel.validateUserId,
                        decoration: InputDecoration(
                            hintText: '아이디를 입력해주세요',
                            hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                    ),
                ),
                if (viewModel.usernameCheckMessage != null) ...[
                    SizedBox(height: 8),
                    Text(
                        viewModel.usernameCheckMessage!,
                        style: TextStyle(
                            color: viewModel.isUsernameAvailable ? Color(0xFF10B981) : Color(0xFFEF4444),
                            fontSize: 12,
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
                Text(
                    '비밀번호',
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
                                    child: Row(
                                        children: [
                            Expanded(
                                                child: TextFormField(
                                    controller: viewModel.pwController,
                                    validator: viewModel.validatePassword,
                                    obscureText: !viewModel.isPasswordVisible,
                                                    decoration: InputDecoration(
                                        hintText: '비밀번호를 입력해주세요',
                                        hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
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
            ],
        );
    }

    Widget _buildPasswordCheckField(SignupViewModel viewModel) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                        children: [
                            Expanded(
                                child: TextFormField(
                                    controller: viewModel.pwcheckController,
                                    validator: viewModel.validatePasswordCheck,
                                    obscureText: !viewModel.isPasswordCheckVisible,
                                    decoration: InputDecoration(
                                        hintText: '비밀번호를 다시 입력해주세요',
                                        hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
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
            ],
        );
    }

    Widget _buildEmailField(BuildContext context, SignupViewModel viewModel) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                    '이메일',
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
                            flex: 2,
                            child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Color(0xFFE5E7EB)),
                                ),
                                                    child: TextFormField(
                                    controller: viewModel.emailPrefixController,
                                    validator: viewModel.validateEmailPrefix,
                                                        decoration: InputDecoration(
                                        hintText: '이메일',
                                        hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                ),
                            ),
                        ),
                        SizedBox(width: 8),
                        Text(
                            '@',
                            style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                            ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                            flex: 2,
                            child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Color(0xFFE5E7EB)),
                                ),
                                child: viewModel.isCustomDomain
                                    ? TextFormField(
                                        controller: viewModel.customDomainController,
                                        validator: viewModel.validateCustomDomain,
                                        decoration: InputDecoration(
                                            hintText: '직접 입력',
                                            hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        ),
                                    )
                                    : DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                            value: viewModel.isCustomDomain ? '직접 입력' : (viewModel.selectedEmailDomain.isEmpty ? 'naver.com' : viewModel.selectedEmailDomain),
                                            isExpanded: true,
                                            items: ['naver.com', 'gmail.com', 'daum.net', 'kakao.com', '직접 입력']
                                                .map((domain) => DropdownMenuItem(
                                                    value: domain,
                                                    child: Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                                        child: Text(
                                                            domain,
                                                            style: TextStyle(
                                                                color: Colors.black,
                                                            ),
                                                        ),
                                                    ),
                                                ))
                                                .toList(),
                                                        onChanged: (value) {
                                                            if (value != null) {
                                                    viewModel.setEmailDomain(value);
                                                            }
                                                        },
                                                    ),
                                                ),
                                                    ),
                                                ),
                                        ],
                                    ),
            ],
        );
    }

    Widget _buildSignupButton(BuildContext context, SignupViewModel viewModel) {
        return Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
                color: Color(0xFFF97316), // 오렌지 500
                borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : () => _handleSignup(context, viewModel),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                    ),
                ),
                child: Text(
                    viewModel.isLoading ? '회원가입 중...' : '회원가입',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
                        color: Color(0xFFE5E7EB),
                    ),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                        '또는',
                        style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                        ),
                    ),
                ),
                Expanded(
                    child: Container(
                        height: 1,
                        color: Color(0xFFE5E7EB),
                    ),
                ),
            ],
        );
    }
    
    Widget _buildKakaoButton(BuildContext context, SignupViewModel viewModel) {
        return Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
                color: Color(0xFFFEE500), // 카카오 옐로우
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
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                            ),
                        ),
                    ],
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
