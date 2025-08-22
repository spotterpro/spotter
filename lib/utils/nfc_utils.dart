// 📁 lib/utils/nfc_utils.dart

import 'package:nfc_manager/nfc_manager.dart';

/// NfcTag 객체에서 여러 종류의 ID를 순차적으로 확인하여 가장 신뢰도 높은 ID를 일관되게 반환합니다.
/// 이렇게 하면 스캔 상황에 따라 태그 정보가 다르게 읽히더라도 동일한 ID를 얻을 수 있습니다.
String? getConsistentNfcId(NfcTag tag) {
  String? identifier;
  final techData = tag.data;

  try {
    // NDEF 타입의 고유 식별자를 최우선으로 확인합니다.
    if (techData.containsKey('ndef') && techData['ndef']['identifier'] != null) {
      identifier = (techData['ndef']['identifier'] as List<Object?>)
          .map((e) => (e as int).toRadixString(16).padLeft(2, '0'))
          .join('');
      if (identifier.isNotEmpty) return identifier;
    }

    // NDEF 정보가 없을 경우, 다른 기술 사양(예: NfcA, Mifare)의 ID를 확인합니다.
    if (techData.containsKey('nfca') && techData['nfca']['identifier'] != null) {
      identifier = (techData['nfca']['identifier'] as List<Object?>)
          .map((e) => (e as int).toRadixString(16).padLeft(2, '0'))
          .join('');
      if (identifier.isNotEmpty) return identifier;
    }

    if (techData.containsKey('mifare') && techData['mifare']['identifier'] != null) {
      identifier = (techData['mifare']['identifier'] as List<Object?>)
          .map((e) => (e as int).toRadixString(16).padLeft(2, '0'))
          .join('');
      if (identifier.isNotEmpty) return identifier;
    }
  } catch (e) {
    print('NFC ID 파싱 중 오류: $e');
    return null;
  }

  return null; // 모든 방법으로 ID를 찾지 못한 경우
}