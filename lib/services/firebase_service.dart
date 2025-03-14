import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/score_model.dart';

class FirebaseService {
  final CollectionReference _scoresCollection = 
      FirebaseFirestore.instance.collection('Scores');

  // เพิ่มคะแนนใหม่
  Future<void> addScore(ScoreModel score) async {
    await _scoresCollection.add(score.toMap());
  }

  // อ่านข้อมูลคะแนนทั้งหมด
  Stream<List<ScoreModel>> getScores() {
    return _scoresCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ScoreModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // แก้ไขข้อมูลคะแนน
  Future<void> updateScore(ScoreModel score) async {
    await _scoresCollection.doc(score.id).update({
      'subject': score.subject,
      'score': score.score,
    });
  }

  // ลบข้อมูลคะแนน
  Future<void> deleteScore(String id) async {
    await _scoresCollection.doc(id).delete();
  }
}