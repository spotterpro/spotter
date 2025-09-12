import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotter/features/authentication/data/services/auth_service.dart';
import 'package:spotter/features/home/presentation/screens/home_screen.dart';

// 카카오 로고 SVG 데이터를 코드로 저장
const String _kakaoLogoSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
    <path fill="#000000" fill-rule="evenodd" d="M12 4c-4.97 0-9 3.144-9 7.02c0 2.44 1.54 4.621 3.882 5.925L6 20l2.922-1.835C9.88 18.101 10.91 18.2 12 18.2c4.97 0 9-3.218 9-7.18S16.97 4 12 4z"/>
</svg>
''';

// 구글 로고 SVG 데이터를 코드로 저장
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
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
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
          _buildAgreementRow('전체 동의하기', _isAllChecked, _onAllCheckedChanged, "", isBold: true),
          Divider(color: Colors.grey.shade300, height: 20),
          _buildAgreementRow('[필수] 개인정보 처리방침 동의', _isPrivacyChecked, (v) => setState(() { _isPrivacyChecked = v ?? false; _updateAllCheckState(); }), _privacyPolicyText),
          _buildAgreementRow('[필수] 위치기반서비스 이용약관', _isLocationChecked, (v) => setState(() { _isLocationChecked = v ?? false; _updateAllCheckState(); }), _lbsTermsText),
          _buildAgreementRow('[선택] 마케팅 정보 수신 동의', _isMarketingChecked, (v) => setState(() { _isMarketingChecked = v ?? false; _updateAllCheckState(); }), _marketingTermsText),
        ],
      ),
    );
  }

  Widget _buildAgreementRow(String text, bool value, ValueChanged<bool?> onChanged, String termsContent, {bool isBold = false}) {
    return Row(
      children: [
        SizedBox(width: 24, height: 24, child: Checkbox(value: value, onChanged: onChanged, activeColor: const Color(0xFFFFA726))),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontWeight: isBold ? FontWeight.normal : FontWeight.normal)),
        const Spacer(),
        if (text != '전체 동의하기')
          TextButton(
            onPressed: () {
              _showTermsBottomSheet(context, text, termsContent);
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

  void _showTermsBottomSheet(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Text(
                        content,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}