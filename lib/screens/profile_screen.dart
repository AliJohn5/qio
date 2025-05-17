import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:qio/api/users.dart';
import 'package:qio/models/offer.dart';
//import 'package:qio/models/offer.dart';
import 'package:qio/models/users/users.dart';
import 'package:qio/screens/edit_profile.dart';
import 'package:qio/screens/loading.dart';
import 'package:qio/screens/login.dart';
import 'package:qio/widgets/explore/banner_ad_widget.dart';
import 'package:qio/widgets/offer/my_product_card.dart';
//import 'package:qio/widgets/offer/my_product_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

    final resProfile = await DioClient.instance.get("api/users/profile/");

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
      final res = await DioClient.instance.get("api/users/image/");

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
        "api/users/profile/followers/get/",
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
      "api/offer/offers/all/${offers.length}/${offers.length + 10}/",
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
      "api/offer/offers/all/${offers.length}/${offers.length + 10}/",
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => EditProfile()));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (ctx) => Scaffold(
                        appBar: AppBar(title: Text('الإعدادات')),
                        body: Align(
                          alignment: Alignment.topRight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton(
                                onPressed: _aboutUs,
                                child: Text(
                                  'اتصل بنا',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await DioClient.instance.post(
                                    "api/c/c/n/n/n/n/",
                                    data: {"token": "000000"},
                                  );
                                  await TokenManager.deleteTokens();

                                  if (!mounted) return;
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => Login(),
                                    ),
                                    (Route route) => false,
                                  );
                                },
                                child: Text(
                                  'تسجيل الخروج',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),

                              TextButton(
                                onPressed: _confirmAndDeleteUser,
                                child: Text(
                                  'حذف الحساب',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ),
              );
            },
          ),
        ],
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
                  canEdeit: true,
                );
              }).toList(),
        ),
      ),
    );
  }

  void _aboutUs() async {
    await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("تواصل معنا على:"),
            content: SelectableText(
              "email:  Qio.Sym@gmail.com\n\nfacebook:  https://www.facebook.com/share/1EEqwpnLMm/",
              textDirection: TextDirection.ltr,
              

            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Confirm
                child: Text("حسنا"),
              ),
            ],
          ),
    );
  }

  void _confirmAndDeleteUser() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("هل أنت متأكد؟"),
            content: Text("سيتم حذف الحساب بشكل دائم."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Cancel
                child: Text("إلغاء"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Confirm
                child: Text("حذف", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (shouldDelete == true) {
      await _deleteUser();
    }
  }

  Future<void> _deleteUser() async {
    showLoadingDialog(context);
    final res = await DioClient.instance.delete("api/users/delete/");
    if (!mounted) return;
    hideLoadingDialog(context);

    if (res.statusCode == 204) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login()),
        (Route route) => false,
      );
    }
  }
}
