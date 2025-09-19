// features/owner/presentation/screens/store_application_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kpostal/kpostal.dart';
import 'package:spotter/features/owner/presentation/screens/application_complete_screen.dart';

// 전화번호 자동 하이픈 포맷터
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 11 && !text.startsWith('0507')) { text = text.substring(0, 11); }
    else if (text.length > 12 && text.startsWith('0507')) { text = text.substring(0, 12); }
    if (text.isEmpty) { return newValue.copyWith(text: '');}

    String formattedText;
    if (text.startsWith('02')) {
      if (text.length < 3) { formattedText = text; }
      else if (text.length < 6) { formattedText = '${text.substring(0, 2)}-${text.substring(2)}';}
      else if (text.length < 10) { formattedText = '${text.substring(0, 2)}-${text.substring(2, 5)}-${text.substring(5)}';}
      else { formattedText = '${text.substring(0, 2)}-${text.substring(2, 6)}-${text.substring(6, 10)}';}
    } else if (text.startsWith('0507')) {
      if (text.length < 5) { formattedText = text;}
      else if (text.length < 9) { formattedText = '${text.substring(0, 4)}-${text.substring(4)}';}
      else { formattedText = '${text.substring(0, 4)}-${text.substring(4, 8)}-${text.substring(8)}';}
    } else if (text.length <= 8) {
      if (text.length < 5) { formattedText = text;}
      else { formattedText = '${text.substring(0, 4)}-${text.substring(4)}';}
    } else {
      if (text.length < 4) { formattedText = text;}
      else if (text.length < 7) { formattedText = '${text.substring(0, 3)}-${text.substring(3)}';}
      else if (text.length < 11) { formattedText = '${text.substring(0, 3)}-${text.substring(3, 6)}-${text.substring(6)}';}
      else { formattedText = '${text.substring(0, 3)}-${text.substring(3, 7)}-${text.substring(7)}';}
    }
    return newValue.copyWith(text: formattedText, selection: TextSelection.collapsed(offset: formattedText.length));
  }
}

// 시간 자동 콜론(:) 포맷터
class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 4) {
      digitsOnly = digitsOnly.substring(0, 4);
    }
    var newString = StringBuffer();
    if (digitsOnly.length <= 2) {
      newString.write(digitsOnly);
    } else {
      newString.write(digitsOnly.substring(0, 2));
      newString.write(':');
      newString.write(digitsOnly.substring(2));
    }
    return TextEditingValue(
      text: newString.toString(),
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}


class StoreApplicationScreen extends StatefulWidget {
  const StoreApplicationScreen({super.key});
  @override
  State<StoreApplicationScreen> createState() => _StoreApplicationScreenState();
}

class _StoreApplicationScreenState extends State<StoreApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _storeNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _storyController = TextEditingController();
  final _addressController = TextEditingController();
  final _addressDetailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _openTimeController = TextEditingController();
  final _closeTimeController = TextEditingController();
  final _breakStartTimeController = TextEditingController();
  final _breakEndTimeController = TextEditingController();

  final _openTimeFocusNode = FocusNode();
  final _closeTimeFocusNode = FocusNode();
  final _breakStartTimeFocusNode = FocusNode();
  final _breakEndTimeFocusNode = FocusNode();

  final List<bool> _selectedDays = List.generate(7, (_) => false);
  final List<String> _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];
  bool _showBreakTime = false;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _setupFocusNodeListener(_openTimeFocusNode, _openTimeController);
    _setupFocusNodeListener(_closeTimeFocusNode, _closeTimeController);
    _setupFocusNodeListener(_breakStartTimeFocusNode, _breakStartTimeController);
    _setupFocusNodeListener(_breakEndTimeFocusNode, _breakEndTimeController);
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _categoryController.dispose();
    _storyController.dispose();
    _addressController.dispose();
    _addressDetailController.dispose();
    _phoneNumberController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _breakStartTimeController.dispose();
    _breakEndTimeController.dispose();
    _openTimeFocusNode.dispose();
    _closeTimeFocusNode.dispose();
    _breakStartTimeFocusNode.dispose();
    _breakEndTimeFocusNode.dispose();
    super.dispose();
  }

  void _setupFocusNodeListener(FocusNode focusNode, TextEditingController controller) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus && controller.text.length == 2) {
        setState(() {
          controller.text = '${controller.text}:00';
        });
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) { setState(() { _image = pickedFile; }); }
    } catch (e) {
      print("이미지 선택 중 오류 발생: $e");
    }
  }

  Future<void> _submitApplication() async {
    // 1. Form 위젯에 연결된 모든 TextFormField들의 유효성을 검사합니다.
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('빨간색 글씨로 표시된 필수 항목을 모두 입력해주세요.'), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. Form으로 검사할 수 없는 이미지, 영업 요일을 별도로 검사합니다.
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('가게 대표 사진을 등록해주세요.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (!_selectedDays.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('영업 요일을 하루 이상 선택해주세요.'), backgroundColor: Colors.red),
      );
      return;
    }

    // --- 모든 유효성 검사를 통과한 경우에만 아래 로직이 실행됩니다 ---
    final user = FirebaseAuth.instance.currentUser!;

    setState(() { _isLoading = true; });

    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('store_images').child(user.uid).child(fileName);
      await ref.putFile(File(_image!.path));
      final imageUrl = await ref.getDownloadURL();

      final List<String> selectedDayLabels = [];
      for (int i = 0; i < _selectedDays.length; i++) {
        if (_selectedDays[i]) { selectedDayLabels.add(_dayLabels[i]); }
      }

      final operatingHours = '${_openTimeController.text} ~ ${_closeTimeController.text}';
      final breakTime = _showBreakTime ? '${_breakStartTimeController.text} ~ ${_breakEndTimeController.text}' : '없음';

      await FirebaseFirestore.instance.collection('store_applications').add({
        'ownerId': user.uid,
        'userEmail': user.email,
        'storeName': _storeNameController.text,
        'category': _categoryController.text,
        'story': _storyController.text,
        'address': _addressController.text,
        'addressDetail': _addressDetailController.text,
        'phoneNumber': _phoneNumberController.text,
        'imageUrl': imageUrl,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'operatingDays': selectedDayLabels,
        'operatingHours': operatingHours,
        'breakTime': breakTime,
      });

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ApplicationCompleteScreen()), (route) => false,
        );
      }
    } catch (e) {
      print("Error submitting application: $e");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('신청 중 오류가 발생했습니다: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('가게 심사 신청', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRegistrationProcessStepper(),
                const SizedBox(height: 24),
                _buildTextFormField(
                  label: '가게 이름',
                  hint: '예: 스포터 치킨',
                  controller: _storeNameController,
                  validator: (value) => (value == null || value.trim().isEmpty) ? '가게 이름은 필수 항목입니다.' : null,
                ),
                _buildTextFormField(
                  label: '카테고리',
                  hint: '예: 치킨, 한식, 카페...',
                  controller: _categoryController,
                  validator: (value) => (value == null || value.trim().isEmpty) ? '카테고리는 필수 항목입니다.' : null,
                ),
                _buildImagePickerField(context),
                _buildTextFormField(
                    label: '가게 이야기',
                    hint: '손님들에게 가게를 소개해 주세요.',
                    maxLines: 5,
                    controller: _storyController
                ),
                _buildAddressField(context),
                _buildTextFormField(
                  label: '가게 전화번호',
                  hint: '010-1234-5678',
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [PhoneNumberFormatter()],
                  validator: (value) => (value == null || value.trim().isEmpty) ? '가게 전화번호는 필수 항목입니다.' : null,
                ),
                _buildBusinessHoursField(context),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _submitApplication,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('심사 신청하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationProcessStepper() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final stepperBackgroundColor = isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.orange.withOpacity(0.05);
    final stepperBorderColor = isDarkMode ? Colors.grey.shade700 : Colors.orange.withOpacity(0.2);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(color: stepperBackgroundColor, borderRadius: BorderRadius.circular(15.0), border: Border.all(color: stepperBorderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Spotter 가게 등록 절차 🚀', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildStep(1, '가게 심사 신청', '이 페이지에서 가게 정보를 입력하여 제출해주세요.'),
          _buildStep(2, '심사 및 NFC 키트 발송', 'Spotter팀의 심사 통과 후 가게로 NFC 키트를 보내드립니다.'),
          _buildStep(3, 'NFC 활성화 & 리워드 등록', '가게 모드에서 키트를 활성화하고 고객 리워드를 등록합니다.'),
          _buildStep(4, '지도에 가게 노출', '모든 준비가 끝나면 Spotter 지도에 가게가 표시됩니다!', isLast: true),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String title, String subtitle, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(radius: 14, backgroundColor: Colors.orange, child: Text('$number', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              if (!isLast)
                Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: DashedLine(color: Colors.orange.withOpacity(0.5)))),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                if (!isLast) const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({required String label, required String hint, int maxLines = 1, TextEditingController? controller, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.all(12),
              errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('가게 대표 사진', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
              child: _image == null ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey), SizedBox(height: 8), Text('사진을 업로드 해주세요', style: TextStyle(color: Colors.grey))])) : ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(_image!.path), fit: BoxFit.cover)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('가게 주소', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField( // 주소 필드도 TextFormField로 변경하여 validator 적용
                  controller: _addressController,
                  readOnly: true,
                  decoration: InputDecoration(hintText: '주소 검색', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12)),
                  validator: (value) => (value == null || value.trim().isEmpty) ? '가게 주소는 필수 항목입니다.' : null,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => KpostalView(callback: (Kpostal result) { setState(() { _addressController.text = result.address; }); }))); }, child: const Text('검색')),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(controller: _addressDetailController, decoration: InputDecoration(hintText: '상세주소 입력 (선택)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12))),
        ],
      ),
    );
  }

  Widget _buildBusinessHoursField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('영업 요일 및 시간', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          ToggleButtons(isSelected: _selectedDays, onPressed: (int index) { setState(() { _selectedDays[index] = !_selectedDays[index]; }); }, borderRadius: BorderRadius.circular(8), constraints: BoxConstraints(minWidth: (MediaQuery.of(context).size.width - 48) / 7, minHeight: 40), children: List.generate(_dayLabels.length, (index) => Text(_dayLabels[index]))),
          const SizedBox(height: 12),
          _buildTimeInputRow(label: '영업 시간', startController: _openTimeController, endController: _closeTimeController, startFocusNode: _openTimeFocusNode, endFocusNode: _closeTimeFocusNode),
          if (_showBreakTime)
            Padding(padding: const EdgeInsets.only(top: 8.0), child: _buildTimeInputRow(label: '브레이크', startController: _breakStartTimeController, endController: _breakEndTimeController, startFocusNode: _breakStartTimeFocusNode, endFocusNode: _breakEndTimeFocusNode)),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(onPressed: () => setState(() => _showBreakTime = !_showBreakTime), icon: Icon(_showBreakTime ? Icons.remove_circle_outline : Icons.add_circle_outline, size: 18), label: Text(_showBreakTime ? '브레이크 타임 제거' : '브레이크 타임 추가')),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInputRow({required String label, required TextEditingController startController, required TextEditingController endController, required FocusNode startFocusNode, required FocusNode endFocusNode}) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 14)),
        Expanded(
          child: TextFormField( // 시간 필드도 TextFormField로 변경
            controller: startController,
            focusNode: startFocusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4), TimeInputFormatter()],
            decoration: InputDecoration(hintText: '09:00', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12)),
            validator: (value) {
              if (value == null || value.trim().isEmpty) { return '필수'; }
              if (value.length < 5) { return '형식오류';}
              return null;
            },
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('~')),
        Expanded(
          child: TextFormField( // 시간 필드도 TextFormField로 변경
            controller: endController,
            focusNode: endFocusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4), TimeInputFormatter()],
            decoration: InputDecoration(hintText: '22:00', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12)),
            validator: (value) {
              if (value == null || value.trim().isEmpty) { return '필수'; }
              if (value.length < 5) { return '형식오류';}
              return null;
            },
          ),
        ),
      ],
    );
  }
}

class DashedLine extends StatelessWidget {
  final double height;
  final Color color;
  const DashedLine({super.key, this.height = 24, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DashedLinePainter(color), size: Size(1, height));
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1;
    const dashHeight = 4;
    const dashSpace = 4;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}