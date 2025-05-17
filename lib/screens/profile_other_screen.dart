import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:qio/api/users.dart';
import 'package:qio/models/offer.dart';
//import 'package:qio/models/offer.dart';
import 'package:qio/models/users/users.dart';

import 'package:qio/widgets/explore/banner_ad_widget.dart';
import 'package:qio/widgets/offer/my_product_card.dart';
//import 'package:qio/widgets/offer/my_product_card.dart';

class ProfileOtherScreen extends StatefulWidget {
  const ProfileOtherScreen({super.key, required this.userEmail});

  final String userEmail;
  @override
  State<ProfileOtherScreen> createState() => _ProfileOtherScreenState();
}

class _ProfileOtherScreenState extends State<ProfileOtherScreen> {
  User user = User(
    email: "email",
    userType: UserType.company,
    followersEmails: [],
    followingEmails: [],
  );
  List<Offer> offers = [];
  late ScrollController _scrollController;

  bool _isLoading = true;
  bool _hasMore = true;

  void _getUserData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    final resProfile = await DioClient.instance.get(
      "api/users/profile/${widget.userEmail}/",
    );

    User user1 = User(
      email: "email",
      userType: UserType.company,
      followersEmails: [],
      followingEmails: [],
    );

    if (resProfile.statusCode == 200) {
      user1.firstName = resProfile.data['first_name'] ?? '';
      user1.email = resProfile.data['email'] ?? '';
      user1.lastName = resProfile.data['last_name'] ?? '';
      user1.phoneNumber = resProfile.data['phone_number'] ?? '';
      user1.userType =
          resProfile.data['user_type'] == 'public'
              ? UserType.company
              : UserType.private;
      if (!mounted) return;

      setState(() {
        user = user1;
        _isLoading = false;
      });
      final res = await DioClient.instance.get(
        "api/users/image/${widget.userEmail}/",
      );

      if (res.statusCode == 200) {
        String imageURL = res.data[0]['image'] ?? "";
        if (imageURL.startsWith('/')) imageURL = imageURL.substring(1);
        user1.imageUrl = domain + imageURL;
        if (!mounted) return;

        setState(() {
          user = user1;
          _isLoading = false;
        });
      }
      final resCountFollwers = await DioClient.instance.get(
        "api/users/profile/followers/get/${widget.userEmail}/",
      );

      if (resCountFollwers.statusCode == 200) {
        for (var u in resCountFollwers.data) {
          user1.followersEmails.add(u['email']);
          //print(u['email']);
        }
        if (!mounted) return;

        setState(() {
          user = user1;
          _isLoading = false;
        });
      }
    }
    if (!mounted) return;

    setState(() {
      user = user1;
      _isLoading = false;
    });
  }

  Future<void> _getMyOffers() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasMore = true;
      });
    }

    offers.clear();

    final res = await DioClient.instance.get(
      "api/offer/offers/all/${widget.userEmail}/${offers.length}/${offers.length + 10}/",
    );

    if (res.statusCode == 200) {
      List<Offer> offersTemp = [];

      for (var off in res.data) {
        offersTemp.add(Offer.fromJson(off));
      }

      if (!mounted) return;
      setState(() {
        offers.addAll(offersTemp);
        _hasMore = offers.length < 10;
        _isLoading = false;
      });
    }
    if (!mounted) return;

    setState(() => _isLoading = false);
  }

  Future<void> _getMyOffersMore() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    int cnt = offers.length;

   final res = await DioClient.instance.get(
      "api/offer/offers/all/${widget.userEmail}/${offers.length}/${offers.length + 10}/",
    );

    if (res.statusCode == 200) {
      List<Offer> offersTemp = [];

      for (var off in res.data) {
        offersTemp.add(Offer.fromJson(off));
      }

      if (mounted) {
        setState(() {
          offers.addAll(offersTemp);
          _hasMore = cnt < offers.length;
          _isLoading = false;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void reset() {
    if (mounted) {
      _getUserData();
      _getMyOffers();
      if (!mounted) return;

      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
    _getMyOffers();
    _scrollController = ScrollController();

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !_isLoading &&
          _hasMore) {
        await _getMyOffersMore();
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
    if (_isLoading) return Center(child: CircularProgressIndicator());
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("الحساب"),
        actions: [],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            SizedBox(height: 20),
            BannerAdWidget(),
            SizedBox(height: 20),
            _productList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        // Updated CircleAvatar to show image if available
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey,
          child: ClipOval(
            child:
                user.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                      imageUrl: user.imageUrl,
                      placeholder:
                          (context, url) => CircularProgressIndicator(),
                      errorWidget:
                          (context, url, error) => Text(
                            user.email.substring(0, 1).toUpperCase(),
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                    )
                    : Text(
                      user.email.substring(0, 1).toUpperCase(),
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
          ),
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Icon(Icons.person_outline, color: Colors.grey, size: 15),
                SizedBox(width: 5),
                Text(
                  "نوع الحساب: ${user.userType == UserType.private ? "خاص" : "شركة"}",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  color: Colors.grey,
                  size: 15,
                ),
                SizedBox(width: 5),
                Text(
                  "الاسم: ${user.firstName} ${user.lastName}",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.people_alt_outlined, color: Colors.grey, size: 15),
                SizedBox(width: 5),
                Text(
                  "متابعون: ${user.followersEmails.length}",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _productList() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: _getMyOffers,
        child: ListView(
          children:
              offers.map((offer) {
                return MyProductCard(
                  offer: offer,
                  parentstate: reset,
                  canEdeit: false,
                );
              }).toList(),
        ),
      ),
    );
  }
}
