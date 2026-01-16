import 'package:flutter/material.dart';
import '../../core/models/lesson_model.dart';
import '../lesson/lesson_player.dart'; // Adjust path if needed

class LessonDetailScreen extends StatelessWidget {
  final LessonModel lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: Column(
        children: [
          // Video/PDF Player
          Expanded(
            flex: 2,
            child: LessonPlayer(lesson: lesson),
          ),
          
          // Chat / Comments Section (Placeholder)
          if (lesson.chatEnabled)
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey[100],
                child: Center(
                  child: Text('Chat Enabled for ${lesson.title}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
