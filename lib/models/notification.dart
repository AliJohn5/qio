class Notification {
  final String content;
  final String time;
  final String title;
  final bool isReaded;

  Notification({
    required this.content,
    required this.title,
    required this.time,
    required this.isReaded,
  });

  static Notification fromJson(json) {
    return Notification(
      content: json['content'],
      title: json['title'],
      time: DateTime.now().toString(),
      isReaded: json['is_readed'] ?? false,
    );
  }
}
