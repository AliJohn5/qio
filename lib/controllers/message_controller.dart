import 'package:get/get.dart';
import 'package:qio/models/message.dart';
import 'package:qio/api/users.dart'; // Assuming you're using Dio for API calls

class MessagesController extends GetxController {
  var chats = <String, List<Message>>{}.obs;
  bool isLoading = false;

  // Method to receive a new message
  void receiveMessage(Message msg) {
    Message ms1 = Message(
      sender: msg.sender,
      message: msg.message,
      time: msg.time,
      emailOther: msg.emailOther,
      isReaded: false,
    );
    final chat = chats[ms1.emailOther] ?? [];
    chat.add(ms1);
    chats[ms1.emailOther] = chat;
  }

  // Method to send a message
  void sendMessage(String userEmail, String content) async {
    final me = await TokenManager.getEmail() ?? "";

    if (me == userEmail) {
      return;
    }
    final msg = Message(
      sender: 'You',
      emailOther: userEmail,
      message: content,
      time: DateTime.now().toString(),
      isReaded: true,
    );

    chats[userEmail] = [...?chats[userEmail], msg];
  }

  // Method to get messages from the backend
  Future<bool> fetch(String email) async {
    isLoading = true;
    chats[email] = chats[email] ?? [];
    try {
      final res = await DioClient.instance.get('api/c/$email/0/10/');
      isLoading = false;
      if (res.statusCode == 200) {
        List<Message> fetched = [];
        String me = await TokenManager.getEmail() ?? "me";
        if (me == "me") {
          
          return false;
        }

        for (var mes in res.data) {
          final other = mes['author']['email'] != me ? "author" : "to_one";
          fetched.add(
            Message(
              sender:
                  mes['author']['email'] == me
                      ? "You"
                      : mes[other]['first_name'] ?? mes[other]['email'],
              message: mes['content'],
              time: mes['date'],
              emailOther: mes[other]['email'],
              isReaded: mes['is_readed'] ?? true,
            ),
          );
        }
        fetched = fetched.reversed.toList();
        chats[email]!.assignAll(fetched);
        return true;
      } else if (res.statusCode == 204) {
        chats[email] = chats[email] ?? [];
        return true;
      }
    } catch (e) {
      isLoading = false;
      return false;
    }
    isLoading = false;
    return false;
  }

  Future<bool> getMore(String email, int cnt) async {
    if (isLoading) return true;
    isLoading = true;

    //chats[email] = chats[email] ?? [];
    final res = await DioClient.instance.get(
      'api/c/$email/${chats[email]?.length}/${chats[email]!.length + 10}/',
    );
    isLoading = false;


    if (res.statusCode == 200) {
      List<Message> fetched = [];
      String me = await TokenManager.getEmail() ?? "me";

      if (me == "me") {
        
        return false;
      }

      for (var mes in res.data) {
        final other = mes['author']['email'] != me ? "author" : "to_one";
        fetched.add(
          Message(
            sender:
                mes['author']['email'] == me
                    ? "You"
                    : mes[other]['first_name'] ?? mes[other]['email'],
            message: mes['content'],
            time: mes['date'],
            emailOther: mes[other]['email'],
            isReaded: mes['is_readed'] ?? false,
          ),
        );
      }
      if (fetched.isEmpty) return false;

      fetched = fetched.reversed.toList();
      chats[email]!.insertAll(0, fetched);
      isLoading = false;
      return true;
    }
    isLoading = false;
    return false;
  }
}
