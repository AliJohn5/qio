import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:qio/api/users.dart';
import 'package:qio/models/offer.dart';

class ProductCarouselSlider extends StatefulWidget {
  const ProductCarouselSlider({super.key, required this.offer});
  final Offer offer;

  @override
  State<ProductCarouselSlider> createState() => _ProductCarouselSliderState();
}

class _ProductCarouselSliderState extends State<ProductCarouselSlider> {
  int _currentIndex = 0;

  bool isLikedByMe = false;

  Future<void> _getLiked() async {
    final res = await DioClient.instance.get(
      "api/offer/offers/${widget.offer.pk}/like/",
    );
    bool temp = false;
    if (res.statusCode == 200) {
      temp = true;
    }
    setState(() {
      isLikedByMe = temp;
    });
  }

  Future<void> _createLike() async {
    bool isLikedByMeTemp = isLikedByMe;
    if (!isLikedByMe) {
      await DioClient.instance.post(
        "api/offer/offers/${widget.offer.pk}/like/",
      );
      isLikedByMeTemp = true;
    } else {
      await DioClient.instance.delete(
        "api/offer/offers/${widget.offer.pk}/like/",
      );
      isLikedByMeTemp = false;
    }

    _getLiked();
    setState(() {
      isLikedByMe = isLikedByMeTemp;
    });
  }

  @override
  void initState() {
    super.initState();
    _getLiked();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 300,
            autoPlay: true,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items:
              widget.offer.images
                  .map(
                    (item) => GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => Scaffold(
                                  appBar: AppBar(),
                                  body: Center(
                                    child: CarouselSlider(
                                      options: CarouselOptions(
                                        height: 300,
                                        autoPlay: true,
                                        viewportFraction: 1,
                                        onPageChanged: (index, reason) {
                                          setState(() {
                                            _currentIndex = index;
                                          });
                                        },
                                      ),
                                      items:
                                          widget.offer.images
                                              .map(
                                                (item) => Image.network(
                                                  item,
                                                  width: double.infinity,
                                                  fit: BoxFit.fill,
                                                ),
                                              )
                                              .toList(),
                                    ),
                                  ),
                                ),
                          ),
                        );
                      },
                      child: Image.network(
                        item,
                        width: double.infinity,
                        fit: BoxFit.fill,
                      ),
                    ),
                  )
                  .toList(),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Icon(Icons.photo, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  '${_currentIndex + 1} / ${widget.offer.images.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 30,
          right: 10,
          child: IconButton(
            icon: Icon(
              isLikedByMe ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: _createLike,
          ),
        ),
        //Positioned(
        //  top: 30,
        //  right: 50,
        //  child: IconButton(
        //    icon: Icon(Icons.share, color: Colors.white),
        //    onPressed: () {
        //      //TODO Handle share button press
        //    },
        //  ),
        //),
        Positioned(
          top: 30,
          left: 10,
          child: IconButton(
            icon: Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}
