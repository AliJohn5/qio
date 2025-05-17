import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:qio/api/users.dart';
import 'package:qio/models/offer.dart';
import 'package:qio/screens/product_screen.dart';
import 'package:qio/services/location_service.dart';

class SimilarProductsList extends StatefulWidget {
  const SimilarProductsList({super.key, required this.offer});
  final Offer offer;
  @override
  State<SimilarProductsList> createState() => _SimilarProductsListState();
}

class _SimilarProductsListState extends State<SimilarProductsList> {
  List<Offer> offers = [];
  bool isLoading = false;
  List<String> countries = [];

  void _fetch() async {
    setState(() {
      isLoading = true;
    });

    List<Offer> offersTemp = [];
    List<String> countriesTemp = [];

    final res = await DioClient.instance.get(
      "api/offer/offers/${widget.offer.pk}/related/",
    );

    if (res.statusCode == 200) {
      for (var off in res.data) {
        offersTemp.add(Offer.fromJson(off));
        countriesTemp.add("");
      }
    }

    setState(() {
      isLoading = false;
      offers = offersTemp;
      countries = countriesTemp;
    });

    for (int i = 0; i < offers.length; ++i) {
      countriesTemp[i] = await getCountryFromCoordinates(
        offers[i].latitude,
        offers[i].longitude,
      );
    }

    setState(() {
      countries = countriesTemp;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: offers.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ProductScreen(offer: offers[index]),
                ),
              );
            },
            tileColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),

            leading:
                offers[index].images.isNotEmpty
                    ? CachedNetworkImage(
                      imageUrl: offers[index].images[0],
                      placeholder:
                          (context, url) =>
                              Center(child: CircularProgressIndicator()),
                      errorWidget:
                          (context, url, error) => Text(
                            offers[index].user.substring(0, 1).toUpperCase(),
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    )
                    : SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(
                        child: Text(
                          offers[index].user.substring(0, 1).toUpperCase(),
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),

            title: Text(
              offers[index].title,
              style: TextStyle(color: Colors.white),
            ),
            trailing: Text(
              "${offers[index].currency.toString().substring(offers[index].currency.toString().indexOf('.') + 1)} \n ${offers[index].price}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                countries[index] == ""
                    ? offers[index].date.toString().substring(0, 7)
                    : "${offers[index].date.toString().substring(0, 7)} / ${countries[index]}",
              ),
            ),
            dense: true,
            // SizedBox(width: 10),
            // Container(
            //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //   decoration: BoxDecoration(
            //       color: Colors.black54,
            //       borderRadius: BorderRadius.circular(8)),
            //   child:
          ),
        );
      },
    );
  }
}
