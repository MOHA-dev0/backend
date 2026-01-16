class PersonalNotification {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  PersonalNotification({
    required this.id,
    required this.type,
    required this.data,
    this.readAt,
    required this.createdAt,
  });

  factory PersonalNotification.fromJson(Map<String, dynamic> json) {
    return PersonalNotification(
      id: json['id'],
      type: json['type'],
      data: json['data'] is Map<String, dynamic>
          ? json['data']
          : {}, // Handle if data is not a map
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
