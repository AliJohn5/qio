import 'package:qio/api/users.dart';

class Message {
  final String sender;
  final String message;
  final String time;
  final String emailOther;
  final bool isReaded;

  Message({
    required this.sender,
    required this.message,
    required this.time,
    required this.emailOther,
    required this.isReaded,
  });

  static Future<Message> fromJson(json) async {
    final me = await TokenManager.getEmail();
    return Message(
      sender: json['author']['first_name'] ?? json['author']['email'],
      message: json['content'],
      time: json['date'],
      emailOther:
          json['to_one']['email'] == me
              ? json["from"]['email']
              : json["to_one"]['email'],
      isReaded: json['is_readed'] ?? false,
    );
  }

  static Message fromJsonReceive(json) {
    return Message(
      sender: json['from'],
      message: json['content'],
      time: DateTime.now().toString(),
      emailOther: json['from'],
      isReaded: json['is_readed'] ?? false,
    );
  }

  static Message fromJsonSend(json) {
    return Message(
      sender: "You",
      message: json['content'],
      time: json['date'],
      emailOther: json['to_one'],
      isReaded: json['is_readed'] ?? false,
    );
  }
}

List<Message> fixMessages(List<Message> messages, int cnt) {
  messages.sort(
    (a, b) => DateTime.parse(b.time).compareTo(DateTime.parse(a.time)),
  );

  final Map<String, Message> latestMessages = {};

  for (var message in messages) {
    if (!latestMessages.containsKey(message.emailOther)) {
      latestMessages[message.emailOther] = message;
    }
  }
  final result = latestMessages.values.toList();
  if (cnt < 0) return result;
  return result.length > cnt ? result.sublist(0, cnt) : result;
}
