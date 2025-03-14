class ScoreModel {
  String? id;
  final String studentName;
  final String subject;
  final double score;

  ScoreModel({
    this.id,
    required this.studentName,
    required this.subject,
    required this.score,
  });

  // แปลงข้อมูลเป็น Map สำหรับเก็บใน Firestore
  Map<String, dynamic> toMap() {
    return {
      'studentName': studentName,
      'subject': subject,
      'score': score,
    };
  }

  // แปลงข้อมูลจาก Map ใน Firestore มาเป็น ScoreModel
  factory ScoreModel.fromMap(String id, Map<String, dynamic> map) {
    return ScoreModel(
      id: id,
      studentName: map['studentName'] ?? '',
      subject: map['subject'] ?? '',
      score: (map['score'] is int) 
          ? (map['score'] as int).toDouble() 
          : (map['score'] ?? 0.0),
    );
  }
}