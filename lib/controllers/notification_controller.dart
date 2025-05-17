import 'package:get/get.dart';
import 'package:qio/api/users.dart';
import 'package:qio/models/notification.dart';

class NotificationsController extends GetxController {
  var notifications = <Notification>[].obs;
  var isReadedAll = false.obs;

  void addNotification(Notification notification) async {
    notifications.insert(0, notification);
    //print("object");
    //await NotiService.initNotification();
    //await NotiService.showNotification(
    //  title: notification.title,
    //  body: notification.content,
    //);
    if (!notification.isReaded) {
      isReadedAll.value = false;
    }
  }

  Future<bool> getMore(int cnt) async {
    final res = await DioClient.instance.get(
      "api/c/c/n/${notifications.length}/${notifications.length + cnt}/",
    );

    List<Notification> notis = [];

    if (res.statusCode == 200) {
      for (var noti in res.data) {
        notis.add(
          Notification(
            content: noti["content"],
            title: noti["title"],
            time: noti["date"],
            isReaded: noti['is_readed'],
          ),
        );
      }
      notifications.addAll(notis);

      return true;
    }

    return false;
  }

  Future<bool> fetch() async {
    notifications.clear();
    isReadedAll.value = true;
    int cnt = 10;
    final res = await DioClient.instance.get(
      "api/c/c/n/${notifications.length}/${notifications.length + cnt}/",
    );

    List<Notification> notis = [];

    if (res.statusCode == 200) {
      for (var noti in res.data) {
        notis.add(
          Notification(
            content: noti["content"],
            title: noti["title"],
            time: noti["date"],
            isReaded: noti["is_readed"] ?? false,
          ),
        );
        if (!noti["is_readed"]) {
          isReadedAll.value = false;
        }
      }
      notifications.assignAll(notis);

      return true;
    }

    return false;
  }
}
