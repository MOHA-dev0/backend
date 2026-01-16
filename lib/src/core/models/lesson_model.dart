class LessonModel {
  final int id;
  final String title;
  final String type; // 'text', 'video', 'audio', 'pdf'
  final String? content; // for text
  final String? mediaUrl; // for video/audio/pdf
  final bool isFree;
  final bool chatEnabled;

  LessonModel({
    required this.id,
    required this.title,
    required this.type,
    this.content,
    this.mediaUrl,
    required this.isFree,
    required this.chatEnabled,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      content: json['content'],
      mediaUrl: json['media_url'],
      isFree: json['is_free'] == 1 || json['is_free'] == true,
      chatEnabled: json['chat_enabled'] == 1 || json['chat_enabled'] == true,
    );
  }
}
