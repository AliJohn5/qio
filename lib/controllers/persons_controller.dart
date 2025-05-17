import 'package:get/get.dart';
import 'package:qio/models/message.dart';
import 'package:qio/api/users.dart';

class PersonsController extends GetxController {
  var chats = <Message>[];
  var isReadedAll = false;
  bool isLoading = false;
  List<Message> received = [];
  List<Message> send = [];

  // Method to receive a new message
  void receiveMessage(Message msg) {
    received.add(msg);
  }

  Future<void> receiveMessageUpdate()async  {
    List<Message> chatTemp = chats.toList();

    for (var msg in received) {
      chatTemp.add(msg);
      if (!msg.isReaded) {
        isReadedAll = false;
      }
    }
    received.clear();

    chatTemp = fixMessages(chatTemp, -1);
    chats.assignAll(chatTemp);
  }

  // Method to send a message
  Future<void> sendMessage(String userEmail, String content) async {
    final msg = Message(
      sender: 'You',
      emailOther: userEmail,
      message: content,
      time: DateTime.now().toString(),
      isReaded: true,
    );
    send.add(msg);
  }

  Future<void> sendMessageUpdate() async {
    List<Message> chatTemp = chats.toList();
    chatTemp.addAll(send);
    chatTemp = fixMessages(chatTemp.toList(), -1);
    send.clear();
    chats.assignAll(chatTemp);
  }

  // Method to get messages from the backend
  Future<bool> fetch() async {
    bool isReadedAllTemp = true;

    final res = await DioClient.instance.get("api/c/c/p/0/10/");
    String me = await TokenManager.getEmail() ?? "me";
    if (me == "me") return false;

    if (res.statusCode == 200) {
      List<Message> newMessages = [];
      String other = "";

      for (var person in res.data) {
        if (person['author']['email'] != me) {
          other = "author";
        } else {
          other = "to_one";
        }

        newMessages.add(
          Message(
            sender: person[other]['first_name'] ?? person[other]['email'],
            message: person['content'],
            time: person['date'],
            emailOther: person[other]['email'],
            isReaded: person['is_readed'] ?? false,
          ),
        );

        if (!(person['is_readed'] ?? true)) {
          isReadedAllTemp = false;
        }
      }

      final fixed = fixMessages(newMessages, -1);
      chats.assignAll(fixed);
      isReadedAll = isReadedAllTemp;

      return true;
    }
    List<Message> newMessages = [];
    chats.assignAll(newMessages);
    isReadedAll = isReadedAllTemp;
    return false;
  }

  Future<bool> getMore(int cnt) async {
    if (isLoading) return true;
    isLoading = true;
    bool isReadedAllTemp = true;

    final res = await DioClient.instance.get(
      "api/c/c/p/${chats.length}/${chats.length + cnt}/",
    );

    String me = await TokenManager.getEmail() ?? "me";
    if (me == "me") return false;

    if (res.statusCode == 200) {
      List<Message> newMessages = [];
      String other = "";

      for (var person in res.data) {
        if (person['author']['email'] != me) {
          other = "author";
        } else {
          other = "to_one";
        }

        newMessages.add(
          Message(
            sender: person[other]['first_name'] ?? person[other]['email'],
            message: person['content'],
            time: person['date'],
            emailOther: person[other]['email'],
            isReaded: person['is_readed'] ?? false,
          ),
        );
        if (!(person['is_readed'] ?? true)) {
          isReadedAllTemp = false;
        }
      }
      if (newMessages.isEmpty) return false;
      chats.addAll(newMessages);
      isReadedAll = isReadedAllTemp;
      isLoading = false;

      return true;
    }
    isLoading = false;

    return false;
  }

  // ignore: non_constant_identifier_names
  Future<void> MyUpdate() async {
    await sendMessageUpdate();
    await receiveMessageUpdate();

  }
}
