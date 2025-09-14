import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotter/features/authentication/data/services/auth_service.dart';
import 'package:spotter/features/main_navigation/presentation/screens/main_screen.dart';
import 'package:spotter/features/policy/presentation/screens/policies_screen.dart';
import 'package:spotter/features/policy/presentation/screens/policy_detail_screen.dart';


const String _kakaoLogoSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
    <path fill="#000000" fill-rule="evenodd" d="M12 4c-4.97 0-9 3.144-9 7.02c0 2.44 1.54 4.621 3.882 5.925L6 20l2.922-1.835C9.88 18.101 10.91 18.2 12 18.2c4.97 0 9-3.218 9-7.18S16.97 4 12 4z"/>
</svg>
''';

const String _googleLogoSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 48 48">
    <path fill="#FFC107" d="M43.611 20.083H42V20H24v8h11.303c-1.649 4.657-6.08 8-11.303 8c-6.627 0-12-5.373-12-12s5.373-12 12-12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4C12.955 4 4 12.955 4 24s8.955 20 20 20s20-8.955 20-20c0-1.341-.138-2.65-.389-3.917z"/>
    <path fill="#FF3D00" d="M6.306 14.691l6.571 4.819C14.655 15.108 18.961 12 24 12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4C16.318 4 9.656 8.337 6.306 14.691z"/>
    <path fill="#4CAF50" d="M24 44c5.166 0 9.86-1.977 13.409-5.192l-6.19-5.238C29.211 35.091 26.715 36 24 36c-5.223 0-9.657-3.356-11.303-8l-6.571 4.819C9.656 39.663 16.318 44 24 44z"/>
    <path fill="#1976D2" d="M43.611 20.083H42V20H24v8h11.303c-.792 2.237-2.231 4.166-4.087 5.574l6.19 5.238C42.012 36.49 44 30.686 44 24c0-1.341-.138-2.65-.389-3.917z"/>
</svg>
''';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  bool _isAllChecked = false;
  bool _isPrivacyChecked = false;
  bool _isLocationChecked = false;
  bool _isMarketingChecked = false;

  bool _areRequiredTermsAgreed() {
    return _isPrivacyChecked && _isLocationChecked;
  }

  void _onAllCheckedChanged(bool? value) {
    if (value == null) return;
    setState(() {
      _isAllChecked = value;
      _isPrivacyChecked = value;
      _isLocationChecked = value;
      _isMarketingChecked = value;
    });
  }

  void _updateAllCheckState() {
    setState(() {
      if (_isPrivacyChecked && _isLocationChecked && _isMarketingChecked) {
        _isAllChecked = true;
      } else {
        _isAllChecked = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              const Text('Spotter', textAlign: TextAlign.center, style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Color(0xFFFFA726))),
              const SizedBox(height: 8),
              const Text('내 동네의 재발견, 스포터와 함께', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey)),
              const Spacer(flex: 3),
              _buildTermsAgreementBox(),
              const SizedBox(height: 24),
              _buildSvgLoginButton(
                svgIconString: _kakaoLogoSvg,
                text: '카카오로 시작하기',
                onPressed: _areRequiredTermsAgreed() && !_isLoading ? () {} : null,
                backgroundColor: const Color(0xFFFEE500),
                foregroundColor: Colors.black87,
              ),
              const SizedBox(height: 12),
              _buildSvgLoginButton(
                svgIconString: _googleLogoSvg,
                text: 'Google로 시작하기',
                onPressed: _areRequiredTermsAgreed() && !_isLoading
                    ? () async {
                  setState(() { _isLoading = true; });
                  final userCredential = await _authService.signInWithGoogle();
                  setState(() { _isLoading = false; });

                  if (userCredential != null && mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('로그인에 실패했습니다. 다시 시도해주세요.')),
                    );
                  }
                }
                    : null,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
              ),
              if (_isLoading) ...[
                const SizedBox(height: 20),
                const Center(child: CircularProgressIndicator()),
              ],
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsAgreementBox() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        children: [
          _buildAgreementRow( '전체 동의하기', _isAllChecked, _onAllCheckedChanged, title: '', content: '', isBold: true),
          Divider(color: Colors.grey.shade300, height: 20),
          _buildAgreementRow('[필수] 개인정보 처리방침 동의', _isPrivacyChecked, (v) => setState(() { _isPrivacyChecked = v ?? false; _updateAllCheckState(); }), title: '개인정보 처리방침', content: privacyPolicyText),
          _buildAgreementRow('[필수] 위치기반서비스 이용약관', _isLocationChecked, (v) => setState(() { _isLocationChecked = v ?? false; _updateAllCheckState(); }), title: '위치기반서비스 이용약관', content: lbsTermsText),
          _buildAgreementRow('[선택] 마케팅 정보 수신 동의', _isMarketingChecked, (v) => setState(() { _isMarketingChecked = v ?? false; _updateAllCheckState(); }), title: '마케팅 정보 수신 동의', content: marketingTermsText),
        ],
      ),
    );
  }

  Widget _buildAgreementRow(String text, bool value, ValueChanged<bool?> onChanged, {required String title, required String content, bool isBold = false}) {
    return Row(
      children: [
        SizedBox(width: 24, height: 24, child: Checkbox(value: value, onChanged: onChanged, activeColor: const Color(0xFFFFA726))),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        const Spacer(),
        if (!isBold)
          TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => PolicyDetailScreen(title: title, content: content),
              ));
            },
            child: const Text('보기', style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
          ),
      ],
    );
  }

  Widget _buildSvgLoginButton({
    required String svgIconString,
    required String text,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 52.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          side: backgroundColor == Colors.white ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
          elevation: 1.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.string(svgIconString, height: 22.0),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}