import 'package:flutter/material.dart';
import 'package:qio/api/users.dart';
import 'package:qio/models/category.dart';
import 'package:qio/models/offer.dart';
import 'package:qio/services/location_service.dart';
import 'package:qio/widgets/explore/banner_ad_widget.dart';
import 'package:qio/widgets/product/call_message_buttons.dart';
import 'package:qio/widgets/product/product_carousel_slider.dart';
import 'package:qio/widgets/product/product_info.dart';
import 'package:qio/widgets/product/publisher_widget.dart';
import 'package:qio/widgets/product/similar_products_list.dart';
import 'package:get/get.dart';

class OfferDeepScreen extends StatefulWidget {
  const OfferDeepScreen({super.key});

  @override
  State<OfferDeepScreen> createState() => _OfferDeepScreenState();
}

class _OfferDeepScreenState extends State<OfferDeepScreen> {
  String country = "";
  bool isLoading = true;

  Offer offer = Offer(
    longitude: 0,
    latitude: 0,
    title: "",
    user: "",
    type: OfferType.looking,
    description: "",
    images: [],
    phone: "",
    category: OfferCategory.allof,
    price: 0,
    currency: Currency.syrian,
    date: "",
    likes: 0,
    saves: 0,
    pk: -1,
  );

  void getCountry() async {
    String countryTemp = await getCountryFromCoordinates(
      offer.latitude,
      offer.longitude,
    );
    if (!mounted) return;

    setState(() {
      country = countryTemp;
    });
  }

  _getOffer() async {
    final String id = Get.arguments;
    final res = await DioClient.instance.get("api/offer/offers/$id/");
    if (res.statusCode == 200) {
      offer = Offer.fromJson(res.data);
      setState(() {
        isLoading = false;
      });
    } else {
      Future.delayed(Duration(seconds: 2), _getOffer());
    }
  }

  @override
  void initState() {
    super.initState();
    _getOffer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CallMessageButtons(offer: offer),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    ProductCarouselSlider(offer: offer),
                    ProductInfo(offer: offer, country: country),
                    BannerAdWidget(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          offer.description,
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                    PublisherWidget(user: offer.user),
                    //similar products
                    SimilarProductsList(offer: offer),
                  ],
                ),
              ),
    );
  }
}
