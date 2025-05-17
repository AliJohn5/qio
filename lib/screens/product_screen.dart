import 'package:flutter/material.dart';
import 'package:qio/models/offer.dart';
import 'package:qio/services/location_service.dart';
import 'package:qio/widgets/explore/banner_ad_widget.dart';
import 'package:qio/widgets/product/call_message_buttons.dart';
import 'package:qio/widgets/product/product_carousel_slider.dart';
import 'package:qio/widgets/product/product_info.dart';
import 'package:qio/widgets/product/publisher_widget.dart';
import 'package:qio/widgets/product/similar_products_list.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, required this.offer});

  final Offer offer;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String country = "";

  void getCountry() async {
    String countryTemp = await getCountryFromCoordinates(
      widget.offer.latitude,
      widget.offer.longitude,
    );
    if (!mounted) return;

    setState(() {
      country = countryTemp;
    });
  }

  @override
  void initState() {
    super.initState();
    getCountry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CallMessageButtons(offer: widget.offer),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProductCarouselSlider(offer: widget.offer),
            ProductInfo(offer: widget.offer, country: country),
            BannerAdWidget(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  widget.offer.description,
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            PublisherWidget(user: widget.offer.user),
            //similar products
            SimilarProductsList(offer: widget.offer),
          ],
        ),
      ),
    );
  }
}
