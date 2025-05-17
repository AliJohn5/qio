import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qio/controllers/persons_controller.dart';
import 'package:qio/models/message.dart';
import 'package:qio/screens/chat_screen.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, required this.setIsReadedAll});
  final Function(bool) setIsReadedAll;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late ScrollController _scrollController;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isReadedAll = true;

  final PersonsController _personsController = Get.find<PersonsController>();
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();

    _fetch();

    _scrollController = ScrollController();

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !_isLoading &&
          _hasMore) {
        await _loadMoreMessages();
      }
    });
  }

  Future<void> _loadMoreMessages() async {
    int cnt = _personsController.chats.length;
    final hasNew = await _personsController.getMore(10);
    if (!mounted) return;

    setState(() {
      if (!hasNew) _hasMore = false;
      if (_personsController.chats.length <= cnt) _hasMore = false;
      _isLoading = false;
    });
  }

  Future<void> _fetch() async {
    _isReadedAll = true;
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasMore = true;
    });

    await _personsController.fetch();
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      messages = _personsController.chats;
      _hasMore = _personsController.chats.length >= 10;
      _isReadedAll = _personsController.isReadedAll;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.setIsReadedAll(_isReadedAll);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonsController>(
      builder: (_) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add_comment),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  String email = '';
                  return AlertDialog(
                    title: Text('أدخل إيميل الشخص المراد مراسلته'),
                    content: TextField(
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        email = value;
                      },
                      decoration: InputDecoration(hintText: "example@mail.com"),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('إلغاء'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (email != "") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ChatScreen(sender: email, email: email),
                              ),
                            );
                          }
                        },
                        child: Text('دردشة'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          appBar: AppBar(title: const Text('الرسائل')),
          body: RefreshIndicator(
            onRefresh: _fetch,
            child:
                messages.isEmpty && _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      itemCount: messages.length + (_hasMore ? 1 : 0),
                      itemBuilder: (ctx, i) {
                        if (i >= messages.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (!messages[i].isReaded) {
                          _isReadedAll = false;
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatScreen(
                                        sender: messages[i].sender,
                                        email: messages[i].emailOther,
                                      ),
                                ),
                              );
                              //print("object");
                              await _personsController.MyUpdate();
                              if (!mounted) return;
                              setState(() {
                                messages = _personsController.chats;
                              });
                            },
                            tileColor:
                                messages[i].isReaded
                                    ? Colors.grey[900]
                                    : Colors.grey[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            leading: CircleAvatar(
                              child: Text(messages[i].emailOther[0]),
                            ),
                            title: Text(
                              fixTitle(messages[i].emailOther),
                            ),
                            subtitle: Text(
                              fixContent(messages[i].message),
                            ),
                            trailing: Text(fixDate(messages[i].time)),
                          ),
                        );
                      },
                    ),
          ),
        );
      },
    );
  }

  String fixContent(String val) =>
      val.length > 20 ? '${val.substring(0, 20)}..' : val;

  String fixTitle(String val) =>
      val.length > 8 ? '${val.substring(0, 8)}..' : val;

  String fixDate(String val) {
    DateTime dateTime = DateTime.parse(val).toLocal();
    DateTime now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return DateFormat('hh:mm a').format(dateTime);
    } else if (dateTime.year == now.year && dateTime.month == now.month) {
      return DateFormat('dd, hh:mm a').format(dateTime);
    } else if (dateTime.year == now.year) {
      return DateFormat('MM/dd, hh:mm a').format(dateTime);
    } else {
      return DateFormat('yy/MM/dd, hh:mm a').format(dateTime);
    }
  }
}
