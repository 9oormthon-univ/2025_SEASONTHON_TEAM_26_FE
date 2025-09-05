import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "../widgets/custom_text_field.dart";
import "../widgets/custom_button.dart";
import "../widgets/kakao_button.dart";
import "../viewmodels/login_viewmodel.dart";

class LoginScreen extends StatelessWidget {
    const LoginScreen({super.key});

    @override
    Widget build(BuildContext context) {
        return ChangeNotifierProvider(
            create: (context) => LoginViewModel(),
            child: _LoginScreenContent(),
        );
    }
}

class _LoginScreenContent extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        final viewModel = Provider.of<LoginViewModel>(context);

        // 에러 메시지가 있으면 다이얼로그 표시
        if (viewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
                viewModel.showErrorDialog(context, viewModel.errorMessage!);
                viewModel.clearError();
            });
        }

        return _buildLoginScreen(context, viewModel);
    }

    Future<void> _handleLogin(BuildContext context, LoginViewModel viewModel) async {
        final success = await viewModel.handleLogin(context);
        if (success) {
            Navigator.pushReplacementNamed(context, '/bus-search');
        }
    }

    Future<void> _handleKakaoLogin(BuildContext context, LoginViewModel viewModel) async {
        final success = await viewModel.handleKakaoLogin(context);
        if (success) {
            Navigator.pushReplacementNamed(context, '/bus-search');
        }
    }

    Widget _buildLoginScreen(BuildContext context, LoginViewModel viewModel) {
        return Scaffold(
            backgroundColor: Color(0xFFFFF5DF), // 크림색 배경
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                        children: [
                            // 상단 여백
                            SizedBox(height: 60),
                            
                            // 로고 및 타이틀
                            _buildLogo(),
                            
                            SizedBox(height: 60),
                            
                            // 입력 필드들
                            _buildInputFields(viewModel),
                            
                            SizedBox(height: 24),
                            
                            // 로그인 버튼
                            _buildLoginButton(context, viewModel),
                            
                            SizedBox(height: 16),
                            
                            // 회원가입 링크
                            _buildSignupLink(context),
                            
                            SizedBox(height: 40),
                            
                            // 구분선
                            _buildDivider(),
                            
                            SizedBox(height: 24),
                            
                            // 카카오 로그인 버튼
                            _buildKakaoButton(context, viewModel),
                            
                            Spacer(),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildLogo() {
        return Column(
            children: [
                // Dream Drivers 로고
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        // D 아이콘
                        Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: Color(0xFFF97316), // 오렌지색
                                borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                                child: Text(
                                    'D',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),
                            ),
                        ),
                        SizedBox(width: 8),
                        Text(
                            'ream',
                            style: TextStyle(
                                color: Color(0xFFF97316),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                        SizedBox(width: 8),
                        Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: Color(0xFFF97316), // 오렌지색
                                borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                                child: Text(
                                    'D',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),
                            ),
                        ),
                        SizedBox(width: 8),
                        Text(
                            'rivers',
                            style: TextStyle(
                                color: Color(0xFFF97316),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                    ],
                ),
                SizedBox(height: 16),
                // 환영 메시지
                Text(
                    '꿈과 희망을 싣고 가는',
                    style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 16,
                    ),
                ),
                Text(
                    '꿈마중 버스에 오신 것을 환영합니다!',
                    style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 16,
                    ),
                ),
            ],
        );
    }

    Widget _buildInputFields(LoginViewModel viewModel) {
        return Column(
            children: [
                // 아이디 입력 필드
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
                            SizedBox(width: 16),
                            Icon(Icons.person_outline, color: Color(0xFF9CA3AF), size: 20),
                            SizedBox(width: 12),
                            Expanded(
                                child: TextField(
                                    controller: viewModel.idController,
                                    decoration: InputDecoration(
                                        hintText: '아이디 입력',
                                        hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                        border: InputBorder.none,
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
                SizedBox(height: 16),
                // 비밀번호 입력 필드
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
                            SizedBox(width: 16),
                            Icon(Icons.lock_outline, color: Color(0xFF9CA3AF), size: 20),
                            SizedBox(width: 12),
                            Expanded(
                                child: TextField(
                                    controller: viewModel.pwController,
                                    obscureText: !viewModel.isPasswordVisible,
                                    decoration: InputDecoration(
                                        hintText: '비밀번호 입력',
                                        hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                        border: InputBorder.none,
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

    Widget _buildLoginButton(BuildContext context, LoginViewModel viewModel) {
        return Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
                color: Color(0xFFF97316), // 오렌지 500
                borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : () => _handleLogin(context, viewModel),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                    ),
                ),
                child: Text(
                    viewModel.isLoading ? '로그인 중...' : '로그인',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                    ),
                ),
            ),
        );
    }

    Widget _buildSignupLink(BuildContext context) {
        return Align(
            alignment: Alignment.centerRight,
            child: TextButton(
                onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                },
                child: Text(
                    '회원가입',
                    style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                    ),
                ),
            ),
        );
    }

    Widget _buildDivider() {
        return Row(
            children: [
                Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                        '또는',
                        style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                        ),
                    ),
                ),
                Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
            ],
        );
    }

    Widget _buildKakaoButton(BuildContext context, LoginViewModel viewModel) {
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
}