import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/score_model.dart';
import '../services/firebase_service.dart';
import '../widgets/app_theme.dart';

class EditScoreScreen extends StatefulWidget {
  final ScoreModel score;
  final FirebaseService firebaseService;

  const EditScoreScreen({
    Key? key,
    required this.score,
    required this.firebaseService,
  }) : super(key: key);

  @override
  State<EditScoreScreen> createState() => _EditScoreScreenState();
}

class _EditScoreScreenState extends State<EditScoreScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _subjectController;
  late TextEditingController _scoreController;
  late String _studentName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.score.subject);
    _scoreController = TextEditingController(text: widget.score.score.toString());
    _studentName = widget.score.studentName;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูลคะแนน'),
        centerTitle: true,
      ),
      body: Container(
        color: AppTheme.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.edit_note,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'แก้ไขคะแนนของ $_studentName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // แสดงชื่อนิสิต (ไม่สามารถแก้ไขได้)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGreenColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: AppTheme.accentColor),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ชื่อนิสิต',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _studentName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // ชื่อวิชา
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อวิชา',
                        prefixIcon: Icon(Icons.book, color: AppTheme.accentColor),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาระบุชื่อวิชา';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // คะแนนสอบ
                    TextFormField(
                      controller: _scoreController,
                      decoration: const InputDecoration(
                        labelText: 'คะแนนสอบ',
                        prefixIcon: Icon(Icons.score, color: AppTheme.accentColor),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาระบุคะแนนสอบ';
                        }
                        
                        final score = double.tryParse(value);
                        if (score == null) {
                          return 'กรุณาระบุคะแนนในรูปแบบตัวเลข';
                        }
                        
                        if (score < 0 || score > 100) {
                          return 'คะแนนต้องอยู่ระหว่าง 0-100';
                        }
                        
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // ปุ่มบันทึก
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateScore,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'บันทึกการแก้ไข',
                                style: TextStyle(fontSize: 18,color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateScore() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedScore = ScoreModel(
          id: widget.score.id,
          studentName: _studentName,
          subject: _subjectController.text.trim(),
          score: double.parse(_scoreController.text.trim()),
        );

        await widget.firebaseService.updateScore(updatedScore);
        
        if (!mounted) return;

        Fluttertoast.showToast(
          msg: "แก้ไขข้อมูลสำเร็จ",
          backgroundColor: Colors.green,
        );
        
        Navigator.pop(context);
      } catch (e) {
        Fluttertoast.showToast(
          msg: "เกิดข้อผิดพลาด: $e",
          backgroundColor: Colors.red,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}