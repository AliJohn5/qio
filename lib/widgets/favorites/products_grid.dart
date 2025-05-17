import 'package:flutter/material.dart';
import 'package:qio/api/users.dart';
import 'package:qio/models/offer.dart';
import 'package:qio/screens/loading.dart';
import 'package:qio/widgets/explore/product_card.dart';

class ProductsGrid extends StatefulWidget {
  const ProductsGrid({super.key});
  @override
  State<ProductsGrid> createState() => _ProductsGridState();
}

class _ProductsGridState extends State<ProductsGrid> {
  List<Offer> offers = [];
  late ScrollController _scrollController;
  bool _isLoading = false, _hasMore = false;

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _hasMore = true;
    });

    showLoadingDialog(context);
    final res = await DioClient.instance.get("api/offer/offers/saved/0/10/");
    if (!mounted) return;
    hideLoadingDialog(context);

    if (res.statusCode == 200) {
      List<Offer> offersTemp = [];

      for (var off in res.data) {
        offersTemp.add(Offer.fromRequest(off));
      }
      setState(() {
        offers = offersTemp;
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res.data.toString())));
    }

    setState(() {
      _isLoading = false;
      _hasMore = offers.length >= 10;
    });
  }

  Future<void> _fetchMore() async {
    setState(() {
      _isLoading = false;
    });

    int cnt = offers.length;
    showLoadingDialog(context);
    final res = await DioClient.instance.get(
      "api/offer/offers/saved/${offers.length}/${offers.length + 10}/",
    );
    if (!mounted) return;
    hideLoadingDialog(context);

    if (res.statusCode == 200) {
      List<Offer> offersTemp = [];

      for (var off in res.data) {
        offersTemp.add(Offer.fromRequest(off));
      }
      setState(() {
        offers.addAll(offersTemp);
        _hasMore = cnt <= offers.length;
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res.data.toString())));
    }

    setState(() {
      _isLoading = false;
    });
  }

  void reset() {
    _fetch();
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetch,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(10),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2 / 3,
        ),
        itemCount: offers.length,
        itemBuilder: (ctx, i) => ProductCard(offer: offers[i],parentState: reset,),
      ),
    );
  }
}
