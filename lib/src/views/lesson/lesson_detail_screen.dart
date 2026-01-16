import 'package:flutter/material.dart';
import '../../core/models/lesson_model.dart';
import 'lesson_player.dart';

class LessonDetailScreen extends StatelessWidget {
  final LessonModel lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LessonPlayer(lesson: lesson),
            ),
          ],
        ),
      ),
    );
  }
}
