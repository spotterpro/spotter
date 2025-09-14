import 'package:flutter/material.dart';
import 'package:spotter/features/policy/presentation/screens/policy_detail_screen.dart';

// 각 정책의 전체 텍스트
const String privacyPolicyText = """
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

const String lbsTermsText = """
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

const String marketingTermsText = """
 제1조 (목적)
 본 약관은 스포터(이하 '회사')가 제공하는 이벤트, 혜택, 광고 등 마케팅 목적의 정보를 회원에게 전달하는 것에 대한 동의 사항을 규정합니다. 본 동의는 선택 사항이며, 동의하지 않으셔도 스포터의 기본 서비스 이용에는 제한이 없습니다.

 제2조 (수신 정보의 내용)
 회사는 회원의 서비스 이용 경험을 풍부하게 하기 위해 아래와 같은 정보를 전송할 수 있습니다.
 - 회사가 제공하는 신규 서비스 또는 기능 업데이트 안내
 - 회사가 진행하는 이벤트, 프로모션, 쿠폰 등 혜택 정보
 - 스포터에 입점한 소상공인 파트너의 광고 및 프로모션 정보
 - 기타 회원의 동의를 얻은 광고성 정보
 """;

class PoliciesScreen extends StatelessWidget {
  const PoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('약관 및 정책', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildPolicyTile(
            context: context,
            title: '개인정보 처리방침',
            content: privacyPolicyText,
          ),
          _buildPolicyTile(
            context: context,
            title: '위치기반서비스 이용약관',
            content: lbsTermsText,
          ),
          _buildPolicyTile(
            context: context,
            title: '마케팅 정보 수신 동의',
            content: marketingTermsText,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyTile({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PolicyDetailScreen(title: title, content: content),
        ));
      },
    );
  }
}