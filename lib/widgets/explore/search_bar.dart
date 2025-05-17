import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:qio/api/users.dart';
import 'package:qio/controllers/notification_controller.dart';
import 'package:qio/screens/search_screen.dart';
import 'package:qio/services/local_storage_service.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final ExpansionTileController _controller = ExpansionTileController();
  final _notificationController = Get.find<NotificationsController>();
  final ScrollController _scrollController = ScrollController();
  final _searchController = TextEditingController();

  bool isCollapesed = true;
  bool _isLoading = false;
  bool _hasMore = true;
  List<String> toShowSearches = [];
  final prefsService = SharedPreferencesService();

  Future<void> _getLastSearch() async {
    final res = await DioClient.instance.get(
      "api/offer/offers/search/getlast/",
    );

    List<String> toShowSearchesTemp = [];

    if (res.statusCode == 200) {
      for (var s in res.data['searches']) {
        toShowSearchesTemp.add(s);
      }
      toShowSearchesTemp = await prefsService.syncWithList(toShowSearchesTemp);

      setState(() {
        toShowSearches = toShowSearchesTemp;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _fetch();

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !_isLoading &&
          _hasMore) {
        await _loadMoreMessages();
      }
    });

    _getLastSearch();
  }

  Future<void> _loadMoreMessages() async {
    setState(() => _isLoading = true);

    int cnt = _notificationController.notifications.length;

    final hasNew = await _notificationController.getMore(10);

    if (!hasNew) _hasMore = false;
    if (_notificationController.notifications.length <= cnt) {
      _hasMore = false;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _hasMore = true;
    });
    await _getLastSearch();
    await _notificationController.fetch();

    setState(() {
      _isLoading = false;
      if (_notificationController.notifications.length < 10) {
        _hasMore = false;
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
    return ExpansionTile(
      showTrailingIcon: false,
      tilePadding: EdgeInsets.zero,
      controller: _controller,
      title: Row(
        children: [
          if (!isCollapesed)
            IconButton(
              onPressed: () {
                _controller.collapse();

                setState(() {
                  isCollapesed = true;
                  _searchController.clear();
                });
              },
              icon: Icon(Icons.close),
            ),
          if (isCollapesed)
            Obx(() {
              final controller = _notificationController;

              return IconButton(
                icon:
                    controller.isReadedAll.value
                        ? Icon(
                          Icons.notifications_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        )
                        : Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ), // base icon
                            Positioned(
                              right: 0,
                              child: Icon(
                                Icons.circle,
                                color: Colors.red,
                                size: 10,
                              ), // unread dot
                            ),
                          ],
                        ),
                onPressed: () {
                  // Inside the IconButton's onPressed:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => Scaffold(
                            appBar: AppBar(title: Text('التحديثات')),
                            body: Center(
                              child: RefreshIndicator(
                                onRefresh: _fetch,
                                child: Obx(() {
                                  if (_notificationController
                                          .notifications
                                          .isEmpty &&
                                      _isLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.all(10),
                                    itemCount:
                                        _notificationController
                                            .notifications
                                            .length +
                                        (_hasMore ? 1 : 0),
                                    itemBuilder: (ctx, i) {
                                      if (i >=
                                          _notificationController
                                              .notifications
                                              .length) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 20,
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 5,
                                        ),
                                        child: ListTile(
                                          tileColor: Colors.grey[900],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          leading: CircleAvatar(
                                            child: Icon(
                                              Icons.notifications_outlined,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            ),
                                          ),
                                          title: Text(
                                            _notificationController
                                                .notifications[i]
                                                .title,
                                          ),
                                          subtitle: Text(
                                            _notificationController
                                                .notifications[i]
                                                .content,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ),
                            ),
                          ),
                    ),
                  );
                },
              );
            }),
          Expanded(
            child: TextField(
              onSubmitted: (s) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(query: s),
                  ),
                );
              },
              controller: _searchController,
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
              onTap: () async {
                _controller.expand();
                setState(() {
                  isCollapesed = false;
                });
                await _getLastSearch();
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, size: 25),
                suffixIcon: Container(
                  margin: EdgeInsets.all(5),
                  child: IconButton.filled(
                    icon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 25,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  SearchScreen(query: _searchController.text),
                        ),
                      );
                    },
                  ),
                ),

                hintText: 'إبحث عن أي شيء',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5000),
                ),
              ),
            ),
          ),
        ],
      ),
      children: [
        for (var s in toShowSearches) ...{
          ListTile(
            title: InkWell(
              child: Text(s),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(query: s),
                  ),
                );
              },
            ),
            leading: Icon(Icons.history),
            trailing: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () async {
                await prefsService.addString(s);
                toShowSearches.remove(s);
                await _getLastSearch();
                if (!mounted) return;
              },
            ),
          ),
        },
        //show search suggestions
      ],
    );
  }
}
