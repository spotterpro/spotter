import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kpostal/kpostal.dart';
import 'package:spotter/features/owner/presentation/screens/application_complete_screen.dart';

class StoreApplicationScreen extends StatefulWidget {
  const StoreApplicationScreen({super.key});

  @override
  State<StoreApplicationScreen> createState() => _StoreApplicationScreenState();
}

class _StoreApplicationScreenState extends State<StoreApplicationScreen> {
  final _addressController = TextEditingController();
  final _addressDetailController = TextEditingController();

  final List<bool> _selectedDays = List.generate(7, (_) => false);
  final List<String> _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  bool _showBreakTime = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
      }
    } catch (e) {
      print("이미지 선택 중 오류 발생: $e");
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _addressDetailController.dispose();
    super.dispose();
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRegistrationProcessStepper(),
              const SizedBox(height: 24),
              _buildTextField(label: '가게 이름', hint: '예: 스포터 카페'),
              _buildTextField(label: '카테고리', hint: '예: 카페, 음식점, 여가...'),
              _buildImagePickerField(context),
              _buildTextField(label: '가게 이야기', hint: '손님들에게 가게를 소개해 주세요.', maxLines: 5),
              _buildAddressField(context),
              _buildBusinessHoursField(context),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Firestore에 심사 신청 정보 저장 로직

                  // 신청 완료 화면으로 이동
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ApplicationCompleteScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('심사 신청하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationProcessStepper() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color stepperBackgroundColor = isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.orange.withOpacity(0.05);
    final Color stepperBorderColor = isDarkMode ? Colors.grey.shade700 : Colors.orange.withOpacity(0.2);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: stepperBackgroundColor,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: stepperBorderColor),
      ),
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
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.orange,
                child: Text('$number', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              if (!isLast)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: DashedLine(color: Colors.orange.withOpacity(0.5)),
                  ),
                ),
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

  Widget _buildTextField({required String label, required String hint, int maxLines = 1, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerField(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
    final pickerBackgroundColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;

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
              decoration: BoxDecoration(
                color: pickerBackgroundColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: _image == null
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(text: '파일 업로드', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('PNG, JPG, GIF up to 10MB', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(_image!.path),
                  fit: BoxFit.cover,
                ),
              ),
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
                child: TextField(
                  controller: _addressController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: '오른쪽 버튼으로 주소를 검색하세요.',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KpostalView(
                        callback: (Kpostal result) {
                          setState(() {
                            _addressController.text = result.address;
                          });
                        },
                      ),
                    ),
                  );
                },
                child: const Text('주소 검색'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _addressDetailController,
            decoration: InputDecoration(
              hintText: '상세주소 입력 (2층, 101호 등)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
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
          ToggleButtons(
            isSelected: _selectedDays,
            onPressed: (int index) {
              setState(() {
                _selectedDays[index] = !_selectedDays[index];
              });
            },
            borderRadius: BorderRadius.circular(8),
            constraints: BoxConstraints(minWidth: (MediaQuery.of(context).size.width - 48) / 7, minHeight: 40),
            children: List.generate(_dayLabels.length, (index) => Text(_dayLabels[index])),
          ),
          const SizedBox(height: 12),
          _buildTimeInputRow(label: '영업 시간'),
          if (_showBreakTime)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildTimeInputRow(label: '브레이크'),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _showBreakTime = !_showBreakTime),
              icon: Icon(_showBreakTime ? Icons.remove_circle_outline : Icons.add_circle_outline, size: 18),
              label: Text(_showBreakTime ? '브레이크 타임 제거' : '브레이크 타임 추가'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInputRow({required String label}) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 14)),
        Expanded(
          child: TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '09:00',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('~'),
        ),
        Expanded(
          child: TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '22:00',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.all(12),
            ),
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
    return CustomPaint(
      painter: _DashedLinePainter(color),
      size: Size(1, height),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
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