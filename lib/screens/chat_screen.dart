import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/instance_manager.dart';
import 'package:intl/intl.dart';
import 'package:qio/controllers/message_controller.dart';
import 'package:qio/controllers/websocket_controller.dart';
import 'package:qio/widgets/custom_component/custom_text_field.dart';

class ChatScreen extends StatefulWidget {
  final String sender;
  final String email;

  const ChatScreen({super.key, required this.sender, required this.email});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isAvailable = true;
  bool isLoading = false;
  bool isLoadingMore = true;
  final MessagesController _messagesController = Get.find<MessagesController>();
  //final WebSocketController _webSocketController =
  //    Get.find<WebSocketController>();

  @override
  void initState() {
    super.initState();
    _fetch();

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !isLoading &&
          isLoadingMore) {
        await _getMore();
      }
    });
  }

  Future<void> _fetch() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      isLoadingMore = true;
    });
    bool isAvailableTemp = await _messagesController.fetch(widget.email);
    if (!mounted) return;

    setState(() {
      isAvailable = isAvailableTemp;
    });
    if (!mounted) return;

    setState(() {
      isLoading = false;
      if (_messagesController.chats[widget.email]!.length < 10) {
        isLoadingMore = false;
      }
    });
    _scrollToBottom(); // load latest messages
  }

  Future<void> _getMore() async {
    if (!mounted) return;

    setState(() => isLoading = true);
    int cnt = _messagesController.chats.length;
    final hasNew = await _messagesController.getMore(widget.email, 10);
    if (!hasNew) isLoadingMore = false;
    if (_messagesController.chats.length <= cnt) isLoadingMore = false;
    if (!mounted) return;

    setState(() => isLoading = false);
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      sendMessage(widget.email, _controller.text);
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages1 = _messagesController.chats[widget.email] ?? [];

    if (!isAvailable) {
      return Scaffold(
        appBar: AppBar(title: Text('حدث خطأ ما')),
        body: Center(child: Text("ربما لا يوجد حساب لهذا الإيميل")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        
        title: Text('محادثة مع ${widget.email}'),
        actions: [

          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetch,
            tooltip: 'Refresh Chat',
          ),
        ],
      ),

      body:
          isLoading && messages1.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: Obx(() {
                      final messages =
                          _messagesController.chats[widget.email] ?? [];
                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.all(10),
                        itemCount: messages.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (ctx, i) {
                          if (i >= messages.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final message = messages[messages.length - 1 - i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Align(
                              alignment:
                                  message.sender == 'You'
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      message.sender == 'You'
                                          ? Colors.blue
                                          : Colors.grey[700],

                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.sender,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      message.message,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      fixDate(message.time),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _controller,
                            title: 'Type a message',
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
