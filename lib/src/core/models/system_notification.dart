class SystemNotification {
  final int id;
  final String title;
  final String body;
  final String? image;
  final String? link;
  final DateTime createdAt;

  SystemNotification({
    required this.id,
    required this.title,
    required this.body,
    this.image,
    this.link,
    required this.createdAt,
  });

  factory SystemNotification.fromJson(Map<String, dynamic> json) {
    return SystemNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      image: json['image'],
      link: json['link'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
