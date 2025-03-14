import 'package:flutter/material.dart';
import '../models/score_model.dart';
import '../services/firebase_service.dart';
import '../widgets/score_card.dart';
import '../widgets/app_theme.dart';
import 'add_score_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('คะแนนนิสิต'),
        centerTitle: true,
      ),
      body: Container(
        color: AppTheme.backgroundColor,
        child: StreamBuilder<List<ScoreModel>>(
          stream: _firebaseService.getScores(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
            }

            final scores = snapshot.data ?? [];
            
            if (scores.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ยังไม่มีข้อมูลคะแนนนิสิต',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 84),
              itemCount: scores.length,
              itemBuilder: (context, index) {
                return ScoreCard(
                  score: scores[index],
                  firebaseService: _firebaseService,
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddScoreScreen(
                firebaseService: _firebaseService,
              ),
            ),
          );
        },
      ),
    );
  }
}