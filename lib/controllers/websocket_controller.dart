import 'package:get/instance_manager.dart';
import 'package:qio/api/users.dart';
import 'package:qio/controllers/message_controller.dart';
import 'package:qio/controllers/persons_controller.dart';

/*
class WebSocketController extends GetxController {
  @override
  void onInit() async {
    super.onInit();

    //Pushy.listen();
    //String deviceToken = await Pushy.register();
//
    //await DioClient.instance.post(
    //  "api/c/c/n/n/n/n/",
    //  data: {"token": deviceToken},
    //);

    //Pushy.setNotificationListener((Map<String, dynamic> data) {
    //  _onDataReceived(data);
    //});
  }

  void _onDataReceived(dynamic data) async {
    await NotiService.initNotification();

    switch (data['message_type']) {
      case 'notification':
        Get.find<NotificationsController>().addNotification(
          Notification.fromJson(data),
        );

        break;
      case 'message':
        Get.find<MessagesController>().receiveMessage(
          Message.fromJsonReceive(data),
        );
        Get.find<PersonsController>().receiveMessage(
          Message.fromJsonReceive(data),
        );
        await NotiService.showNotification(
          title: 'Message from ${data['from']}',
          body: data['content'],
        );
        break;
    }
  }

  Future<void> sendMessage(String userEmail, String content) async {
    final msg = {
      "message_type": "message",
      "to_one": userEmail,
      "content": content,
      "date": DateTime.now().toString(),
      "is_readed": false,
    };
    Get.find<MessagesController>().sendMessage(userEmail, content);
    Get.find<PersonsController>().sendMessage(userEmail, content);

    await DioClient.instance.post("api/c/c/n/n/n/n/n/", data: msg);
  }
}
*/

Future<void> sendMessage(String userEmail, String content) async {
  final msg = {
    "message_type": "message",
    "to_one": userEmail,
    "content": content,
    "date": DateTime.now().toString(),
    "is_readed": false,
  };
  Get.find<MessagesController>().sendMessage(userEmail, content);
  Get.find<PersonsController>().sendMessage(userEmail, content);

  await DioClient.instance.post("api/c/c/n/n/n/n/n/", data: msg);
}
