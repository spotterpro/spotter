// 📁 lib/src/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:spotter/services/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;
  final AuthService _authService = AuthService();

  bool _agreedToPrivacy = false;
  bool _agreedToLBS = false;
  bool _agreedToMarketing = false;
  bool _agreedToAll = false;

  bool get _isLoginEnabled => _agreedToPrivacy && _agreedToLBS;

  void _onAgreeToAll(bool? value) {
    if (value == null) return;
    setState(() {
      _agreedToAll = value;
      _agreedToPrivacy = value;
      _agreedToLBS = value;
      _agreedToMarketing = value;
    });
  }

  void _updateAgreeToAllState() {
    if (_agreedToPrivacy && _agreedToLBS && _agreedToMarketing) {
      _agreedToAll = true;
    } else {
      _agreedToAll = false;
    }
  }

  Future<void> _showTermsDialog(String title, String content) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(content, style: const TextStyle(fontSize: 14)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signInWithGoogle() async {
    if (!_isLoginEnabled) return;
    setState(() { _isSigningIn = true; });

    try {
      // TODO: 마케팅 정보 수신 동의 여부(_agreedToMarketing)를 Firestore에 저장하는 로직 추가 필요
      await _authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 중 문제가 발생했습니다: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isSigningIn = false; });
      }
    }
  }

  void _onKakaoPressed() {
    if (!_isLoginEnabled) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('카카오 로그인은 현재 준비 중입니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.orange);
    final subtitleStyle = TextStyle(fontSize: 14, color: Colors.grey[700]);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              Text('Spotter', style: titleStyle),
              const SizedBox(height: 8),
              Text('내 동네의 재발견, 스포터와 함께', style: subtitleStyle, textAlign: TextAlign.center),
              const Spacer(flex: 4),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildTermsRow(
                      isHeader: true,
                      title: '전체 동의하기',
                      value: _agreedToAll,
                      onChanged: _onAgreeToAll,
                    ),
                    const Divider(),
                    _buildTermsRow(
                      title: '[필수] 개인정보 처리방침 동의',
                      value: _agreedToPrivacy,
                      onChanged: (value) {
                        setState(() {
                          _agreedToPrivacy = value ?? false;
                          _updateAgreeToAllState();
                        });
                      },
                      onView: () => _showTermsDialog('개인정보 처리방침', _privacyPolicyText),
                    ),
                    _buildTermsRow(
                      title: '[필수] 위치기반서비스 이용약관',
                      value: _agreedToLBS,
                      onChanged: (value) {
                        setState(() {
                          _agreedToLBS = value ?? false;
                          _updateAgreeToAllState();
                        });
                      },
                      onView: () => _showTermsDialog('위치기반서비스 이용약관', _lbsTermsText),
                    ),
                    _buildTermsRow(
                      title: '[선택] 마케팅 정보 수신 동의',
                      value: _agreedToMarketing,
                      onChanged: (value) {
                        setState(() {
                          _agreedToMarketing = value ?? false;
                          _updateAgreeToAllState();
                        });
                      },
                      onView: () => _showTermsDialog('마케팅 정보 수신 동의', _marketingTermsText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: Opacity(
                  opacity: _isLoginEnabled ? 1.0 : 0.5,
                  child: GestureDetector(
                    onTap: _onKakaoPressed,
                    child: Image.asset('assets/images/kakao_signin_button.png', fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_isSigningIn)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Opacity(
                    opacity: _isLoginEnabled ? 1.0 : 0.5,
                    child: SignInButton(
                      Buttons.Google,
                      text: 'Google로 시작하기',
                      onPressed: _signInWithGoogle,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  // --- 형님의 요청대로 수정된 부분 ---
  Widget _buildTermsRow({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    bool isHeader = false,
    VoidCallback? onView,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.orange,
        ),
        // Text 위젯을 Expanded로 감싸서 공간 문제를 해결합니다.
        Expanded(
          child: Text(title, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
        ),
        if (onView != null)
          TextButton(
            onPressed: onView,
            child: const Text('보기', style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
          ),
      ],
    );
  }

  final String _privacyPolicyText = """
  제1조 (목적)
  본 개인정보 처리방침은 스포터(이하 '회사')가 제공하는 스포터 서비스(이하 '서비스')를 이용하는 회원(이하 '회원')의 개인정보를 보호하고, 이와 관련한 고충을 신속하고 원활하게 처리할 수 있도록 하기 위하여 필요한 사항을 규정함을 목적으로 합니다.

  제2조 (수집하는 개인정보의 항목 및 수집 방법)
  ① 회사는 최초 회원가입 시 다음과 같은 최소한의 개인정보를 필수항목으로 수집합니다.
  - 소셜 로그인 이용 시: 이름(닉네임), 이메일 주소, 프로필 사진
  ② 서비스 이용 과정에서 아래와 같은 정보들이 자동으로 생성되거나 추가로 수집될 수 있습니다.
  - 기기 정보 (OS, 기기 식별자), 접속 로그, 쿠키, IP 주소
  - 위치 정보 (GPS, Wi-Fi 등)
  - 서비스 이용 기록 (방문 가게, 스탬프/리워드 획득 내역, 게시물 작성 등)

  제3조 (개인정보의 수집 및 이용 목적)
  회사는 수집한 개인정보를 다음의 목적을 위해 활용합니다.
  - 회원 식별 및 관리, 서비스 제공
  - 위치기반서비스 제공 (주변 가게 추천, 스탬프 투어 등)
  - 서비스 부정 이용 방지 및 비인가 사용 방지
  - 통계 작성, 연구 또는 시장조사를 통한 서비스 개선
  - 고지사항 전달, 불만 처리 등 원활한 의사소통 경로 확보
  - 신규 서비스 개발 및 맞춤 서비스 제공, 이벤트 및 광고성 정보 제공 (마케팅 정보 수신 동의 시)

  제4조 (개인정보의 보유 및 이용 기간)
  회사는 원칙적으로 개인정보 수집 및 이용목적이 달성된 후에는 해당 정보를 지체 없이 파기합니다. 단, 관계법령의 규정에 의하여 보존할 필요가 있는 경우 회사는 아래와 같이 관계법령에서 정한 일정한 기간 동안 회원정보를 보관합니다.
  - 계약 또는 청약철회 등에 관한 기록 : 5년 (전자상거래 등에서의 소비자보호에 관한 법률)
  - 대금결제 및 재화 등의 공급에 관한 기록 : 5년 (전자상거래 등에서의 소비자보호에 관한 법률)
  - 소비자의 불만 또는 분쟁처리에 관한 기록 : 3년 (전자상거래 등에서의 소비자보호에 관한 법률)
  - 통신사실확인자료 : 3개월 (통신비밀보호법)
  """;

  final String _lbsTermsText = """
  제1조 (목적)
  본 약관은 스포터(이하 '회사')가 제공하는 위치기반서비스(이하 '서비스')를 이용함에 있어 회사와 회원의 권리·의무 및 책임사항을 규정함을 목적으로 합니다.

  제2조 (용어의 정의)
  ① '위치기반서비스'라 함은 회사가 회원의 위치정보를 수집하여 이를 기반으로 제공하는 다음 각 호의 서비스를 의미합니다.
      1. 주변 장소 및 정보 검색: 현재 위치를 기준으로 주변 가게, 스탬프, 투어 등의 정보를 제공하는 서비스
      2. 사용자 콘텐츠 위치 기록: 회원이 작성하는 게시물, 인증샷 등에 위치를 기록하고 공유하는 기능
      3. 위치 정보 공유: 회원이 동의하는 경우, 다른 이용자에게 자신의 위치나 장소 정보를 공유하는 기능
  ② '위치정보'라 함은 GPS, Wi-Fi, 기지국 정보 등을 통해 수집된 회원의 단말기 위치를 의미합니다.

  제3조 (서비스의 내용)
  회사는 위치정보를 이용하여 다음과 같은 내용의 서비스를 제공합니다.
  - 현재 위치를 활용한 주변 가게, 스탬프, 투어 정보 제공
  - 장소에 대한 스탬프 획득 및 인증 기능
  - 위치가 기록된 게시물 작성 및 조회
  """;

  final String _marketingTermsText = """
  제1조 (목적)
  본 약관은 스포터(이하 '회사')가 제공하는 이벤트, 혜택, 광고 등 마케팅 목적의 정보를 회원에게 전달하는 것에 대한 동의 사항을 규정합니다. 본 동의는 선택 사항이며, 동의하지 않으셔도 스포터의 기본 서비스 이용에는 제한이 없습니다.

  제2조 (수신 정보의 내용)
  회사는 회원의 서비스 이용 경험을 풍부하게 하기 위해 아래와 같은 정보를 전송할 수 있습니다.
  - 회사가 제공하는 신규 서비스 또는 기능 업데이트 안내
  - 회사가 진행하는 이벤트, 프로모션, 쿠폰 등 혜택 정보
  - 스포터에 입점한 소상공인 파트너의 광고 및 프로모션 정보
  - 기타 회원의 동의를 얻은 광고성 정보
  """;
}