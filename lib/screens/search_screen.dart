import 'package:flutter/material.dart';
import 'package:qio/api/users.dart';
import 'package:qio/models/offer.dart';
import 'package:qio/widgets/explore/search_product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.query});
  final String query;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Offer> offers = [];
  late ScrollController _scrollController;
  bool _isLoading = false, _hasMore = false;

  Future<void> _fetch() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasMore = true;
    });

    final res = await DioClient.instance.get(
      "api/offer/offers/search/0/10/",
      queryParameters: {'q': widget.query},
    );

    if (res.statusCode == 200) {
      List<Offer> offersTemp = [];

      for (var off in res.data) {
        offersTemp.add(Offer.fromJson(off));
      }
      if (!mounted) return;

      setState(() {
        offers = offersTemp;
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res.data.toString())));
    }
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _hasMore = offers.length >= 10;
    });
  }

  Future<void> _fetchMore() async {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    int cnt = offers.length;
    final res = await DioClient.instance.get(
      "api/offer/offers/search/${offers.length}/${offers.length + 10}/",
      queryParameters: {'q': widget.query},
    );

    if (res.statusCode == 200) {
      List<Offer> offersTemp = [];

      for (var off in res.data) {
        offersTemp.add(Offer.fromJson(off));
      }
      if (!mounted) return;

      setState(() {
        offers.addAll(offersTemp);
        _hasMore = cnt < offers.length;
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res.data.toString())));
    }
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

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
        await _fetchMore();
      }
    });
  }

  void reset() {
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('البحث عن ${widget.query}')),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10),
                
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 10,
                    childAspectRatio: 6 / 3,
                  ),
                  itemCount: _hasMore ? offers.length + 1 : offers.length,
                  itemBuilder: (ctx, i) {
                    if (i == offers.length) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return SearchProductCard(
                      offer: offers[i],
                      parentState: reset,
                      isSmall: false,
                    );
                  },
                ),
      ),
    );
  }
}
