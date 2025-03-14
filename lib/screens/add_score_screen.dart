import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/score_model.dart';
import '../services/firebase_service.dart';
import '../widgets/app_theme.dart';

class AddScoreScreen extends StatefulWidget {
  final FirebaseService firebaseService;

  const AddScoreScreen({
    Key? key,
    required this.firebaseService,
  }) : super(key: key);

  @override
  State<AddScoreScreen> createState() => _AddScoreScreenState();
}

class _AddScoreScreenState extends State<AddScoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _scoreController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _studentNameController.dispose();
    _subjectController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มข้อมูลคะแนน'),
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
                      Icons.school,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ข้อมูลคะแนนนิสิต',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // ชื่อนิสิต
                    TextFormField(
                      controller: _studentNameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อนิสิต',
                        prefixIcon: Icon(Icons.person, color: AppTheme.accentColor),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาระบุชื่อนิสิต';
                        }
                        return null;
                      },
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
                        onPressed: _isLoading ? null : _saveScore,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'บันทึกข้อมูล',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                                
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

  Future<void> _saveScore() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final score = ScoreModel(
          studentName: _studentNameController.text.trim(),
          subject: _subjectController.text.trim(),
          score: double.parse(_scoreController.text.trim()),
        );

        await widget.firebaseService.addScore(score);
        
        if (!mounted) return;

        Fluttertoast.showToast(
          msg: "บันทึกข้อมูลสำเร็จ",
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