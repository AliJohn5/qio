import 'package:flutter/material.dart';

import 'package:qio/api/users.dart';
import 'package:qio/models/category.dart';
import 'package:qio/models/offer.dart';
import 'package:qio/widgets/explore/banner_ad_widget.dart';
import 'package:qio/widgets/explore/category_box.dart';
import 'package:qio/widgets/explore/main_product_card.dart';
import 'package:qio/widgets/explore/search_bar.dart';


class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String selectedSort = 'allof';
  bool isLoading = false;
  final _scrollControllerOffers = ScrollController();
  final _scrollControllerRec1 = ScrollController();
  final _scrollControllerRec2 = ScrollController();

  List<Offer> recommendedOffer1 = [];
  List<Offer> recommendedOffer2 = [];
  List<Offer> offers = [];

  List<Offer> recommendedOffer1Sort = [];
  List<Offer> recommendedOffer2Sort = [];
  List<Offer> offersSort = [];

  bool _isLoadingRecommended = false;
  bool _isLoadingoffer = false;

  bool _hasMoreRecommended1 = true;

  bool _hasMoreRecommended2 = true;
  bool _hasMoreOffer = true;

  bool _isLoadingRecommended1 = false;
  bool _isLoadingRecommended2 = false;

  void _resetRecom1() {
    if (!mounted) return;
    setState(() {
      recommendedOffer1 = recommendedOffer1;
    });
  }

  void _resetRecom2() {
    if (!mounted) return;
    setState(() {
      recommendedOffer2 = recommendedOffer2;
    });
  }

  void _resetOffers() {
    if (!mounted) return;
    setState(() {
      offers = offers;
    });
  }

 

  @override
  void initState() {
    super.initState();
  
    _fetch();

    _scrollControllerOffers.addListener(() async {
      if (_scrollControllerOffers.position.pixels >=
              _scrollControllerOffers.position.maxScrollExtent - 300 &&
          !_isLoadingoffer &&
          _hasMoreOffer) {
        await _fetchOffersMore();
      }
    });

    _scrollControllerRec1.addListener(() async {
      if (_scrollControllerRec1.position.pixels >=
              _scrollControllerRec1.position.maxScrollExtent - 300 &&
          !_isLoadingRecommended1 &&
          _hasMoreRecommended1) {
        await _fetchRecomended1More();
      }
    });

    _scrollControllerRec2.addListener(() async {
      if (_scrollControllerRec2.position.pixels >=
              _scrollControllerRec2.position.maxScrollExtent - 300 &&
          !_isLoadingRecommended2 &&
          _hasMoreRecommended2) {
        await _fetchRecomended2More();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetch,
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomSearchBar(),
            const SizedBox(height: 10),
            BannerAdWidget(),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    child: CategoryBox(
                      category: OfferCategory.allof,
                      isSelected: selectedSort == 'allof',
                    ),
                    onTap: () {
                      _changeSelectedSort("allof");
                    },
                  ),
                  InkWell(
                    child: CategoryBox(
                      category: OfferCategory.books,
                      isSelected: selectedSort == 'books',
                    ),
                    onTap: () {
                      _changeSelectedSort("books");
                    },
                  ),
                  InkWell(
                    child: CategoryBox(
                      category: OfferCategory.cars,
                      isSelected: selectedSort == 'cars',
                    ),
                    onTap: () {
                      _changeSelectedSort("cars");
                    },
                  ),
                  InkWell(
                    child: CategoryBox(
                      category: OfferCategory.toys,
                      isSelected: selectedSort == 'toys',
                    ),
                    onTap: () {
                      _changeSelectedSort("toys");
                    },
                  ),
                  InkWell(
                    child: CategoryBox(
                      category: OfferCategory.furniture,
                      isSelected: selectedSort == 'furniture',
                    ),
                    onTap: () {
                      _changeSelectedSort("furniture");
                    },
                  ),

                  InkWell(
                    child: CategoryBox(
                      category: OfferCategory.electronics,
                      isSelected: selectedSort == 'electronics',
                    ),
                    onTap: () {
                      _changeSelectedSort("electronics");
                    },
                  ),
                  InkWell(
                    child: CategoryBox(
                      category: OfferCategory.clothes,
                      isSelected: selectedSort == 'clothes',
                    ),
                    onTap: () {
                      _changeSelectedSort("clothes");
                    },
                  ),
                ],
              ),
            ),

            Divider(thickness: 1),

            Align(
              alignment: Alignment.centerRight,

              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 20,
                ),
                child: Text(
                  'منتجات موصى بها',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollControllerRec1,
              padding: EdgeInsets.all(2),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var off in recommendedOffer1Sort) ...{
                    SizedBox(
                      height: 175,
                      width: 150,
                      child: MainProductCard(
                        offer: off,
                        parentState: _resetRecom1,
                        isSmall: true,
                      ),
                    ),
                  },
                ],
              ),
            ),
            Divider(thickness: 1),
            SingleChildScrollView(
              padding: EdgeInsets.all(2),

              scrollDirection: Axis.horizontal,
              controller: _scrollControllerRec2,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  for (var off in recommendedOffer2Sort) ...{
                    SizedBox(
                      height: 175,
                      width: 150,
                      child: MainProductCard(
                        offer: off,
                        parentState: _resetRecom2,
                        isSmall: true,
                      ),
                    ),
                  },
                ],
              ),
            ),
            if (recommendedOffer1Sort.isEmpty &&
                recommendedOffer2Sort.isEmpty) ...{
              Text("لا يوجد"),
            },
            const SizedBox(height: 5),
            Divider(thickness: 1),
            //RecommendedProducts(),
            Align(
              alignment: Alignment.centerRight,

              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 20,
                ),
                child: Text(
                  'أحدث العروض',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            GridView.builder(
              controller: _scrollControllerOffers,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2 / 3,
              ),
              itemCount:
                  _hasMoreOffer ? offersSort.length + 2 : offersSort.length,
              itemBuilder: (ctx, i) {
                if (i >= offersSort.length) {
                  return Center(child: CircularProgressIndicator());
                }

                return MainProductCard(
                  offer: offersSort[i],
                  parentState: _resetOffers,
                  isSmall: false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetch() async {
    await _fetchRecomended();
    await _fetchOffers();
  }

  Future<void> _fetchRecomended() async {
    if (!mounted) return;
    if (_isLoadingRecommended) return;
    setState(() {
      _isLoadingRecommended = true;
    });

    recommendedOffer1.clear();
    recommendedOffer2.clear();

    final res = await DioClient.instance.get(
      "api/offer/offers/recommended/0/20",
    );
    int i = 0;

    if (res.statusCode == 200) {
      for (var off in res.data) {
        if (i % 2 == 0) {
          recommendedOffer1.add(Offer.fromJson(off));
        } else {
          recommendedOffer2.add(Offer.fromJson(off));
        }
        i++;
      }
      _changeSelectedSort(selectedSort);
    }

    if (!mounted) return;
    setState(() {
      _isLoadingRecommended = false;
    });
  }

  Future<void> _fetchRecomended1More() async {
    if (_isLoadingRecommended2) return;
    if (!mounted) return;
    if (!_hasMoreRecommended1) return;
    if (!_hasMoreRecommended2) return;
    setState(() {
      _isLoadingRecommended1 = true;
    });
    int cnt = recommendedOffer1.length + recommendedOffer2.length;

    final res = await DioClient.instance.get(
      "api/offer/offers/recommended/$cnt/${cnt + 20}",
    );

    if (res.statusCode == 200) {
      for (var off in res.data) {
        recommendedOffer1.add(Offer.fromJson(off));
      }
      _changeSelectedSort(selectedSort);
    }

    int cnt2 = recommendedOffer1.length + recommendedOffer2.length;

    if (!mounted) return;
    setState(() {
      _hasMoreRecommended1 = cnt + 20 > cnt2;
      _isLoadingRecommended1 = false;
    });
  }

  Future<void> _fetchRecomended2More() async {
    if (_isLoadingRecommended1) return;
    if (!mounted) return;
    if (!_hasMoreRecommended2) return;
    if (!_hasMoreRecommended1) return;
    setState(() {
      _isLoadingRecommended2 = true;
    });

    int cnt = recommendedOffer1.length + recommendedOffer2.length;

    final res = await DioClient.instance.get(
      "api/offer/offers/recommended/$cnt/${cnt + 20}",
    );

    if (res.statusCode == 200) {
      for (var off in res.data) {
        recommendedOffer2.add(Offer.fromJson(off));
      }
      _changeSelectedSort(selectedSort);
    }

    int cnt2 = recommendedOffer1.length + recommendedOffer2.length;

    if (!mounted) return;
    setState(() {
      _hasMoreRecommended2 = cnt + 20 > cnt2;
      _isLoadingRecommended2 = false;
    });
  }

  Future<void> _fetchOffers() async {
    if (!mounted) return;
    if (_isLoadingoffer) return;
    _hasMoreOffer = true;
    setState(() {
      _isLoadingoffer = true;
    });

    offers.clear();

    final res = await DioClient.instance.get("api/offer/offers/allit/0/20");

    if (res.statusCode == 200) {
      for (var off in res.data) {
        offers.add(Offer.fromJson(off));
      }
      _changeSelectedSort(selectedSort);
    }

    if (!mounted) return;
    if (offers.length < 20) _hasMoreOffer = false;
    setState(() {
      _isLoadingoffer = false;
    });
  }

  Future<void> _fetchOffersMore() async {
    if (!mounted) return;
    if (!_hasMoreOffer) return;

    int cnt = offers.length;
    final res = await DioClient.instance.get(
      "api/offer/offers/allit/${offers.length}/${offers.length + 20}",
    );

    if (res.statusCode == 200) {
      for (var off in res.data) {
        offers.add(Offer.fromJson(off));
      }
      _changeSelectedSort(selectedSort);
    }

    if (!mounted) return;
    setState(() {
      _hasMoreOffer = cnt + 20 > offers.length;
    });
  }

  void _changeSelectedSort(String val) {
    selectedSort = val;

    if (selectedSort == "allof") {
      if (!mounted) return;
      setState(() {
        recommendedOffer1Sort = recommendedOffer1;
        recommendedOffer2Sort = recommendedOffer2;
        offersSort = offers;
      });
      return;
    }

    List<Offer> recommendedOffer1SortTemp = [];
    List<Offer> recommendedOffer2SortTemp = [];
    List<Offer> offersSortTemp = [];

    for (var off in recommendedOffer1) {
      if (off.category == selectedSort) {
        recommendedOffer1SortTemp.add(off);
      }
    }

    for (var off in recommendedOffer2) {
      if (off.category == selectedSort) {
        recommendedOffer2SortTemp.add(off);
      }
    }

    for (var off in offers) {
      if (off.category == selectedSort) {
        offersSortTemp.add(off);
      }
    }

    if (!mounted) return;
    setState(() {
      recommendedOffer1Sort = recommendedOffer1SortTemp;
      recommendedOffer2Sort = recommendedOffer2SortTemp;
      offersSort = offersSortTemp;
    });
  }
}
