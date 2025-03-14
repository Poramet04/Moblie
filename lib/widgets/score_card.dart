import 'package:flutter/material.dart';
import '../models/score_model.dart';
import '../screens/edit_score_screen.dart';
import '../services/firebase_service.dart';
import 'app_theme.dart';

class ScoreCard extends StatelessWidget {
  final ScoreModel score;
  final FirebaseService firebaseService;

  const ScoreCard({
    Key? key,
    required this.score,
    required this.firebaseService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          score.studentName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('วิชา: ${score.subject}'),
            const SizedBox(height: 4),
            Text(
              'คะแนน: ${score.score}',
              style: TextStyle(
                color: _getScoreColor(score.score),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ปุ่มแก้ไข
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.accentColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditScoreScreen(
                      score: score, 
                      firebaseService: firebaseService,
                    ),
                  ),
                );
              },
            ),
            // ปุ่มลบ
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  // แสดง dialog ยืนยันการลบ
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: Text('คุณต้องการลบข้อมูลคะแนนของ ${score.studentName} ใช่หรือไม่?'),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('ลบ', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await firebaseService.deleteScore(score.id!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ลบข้อมูลเรียบร้อยแล้ว')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // กำหนดสีตามระดับคะแนน
  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}