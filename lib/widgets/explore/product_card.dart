import 'package:flutter/material.dart';
import 'package:qio/api/users.dart';
import 'package:qio/models/offer.dart';
import 'package:qio/screens/product_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.offer,
    required this.parentState,
  });

  final Offer offer;
  final Function() parentState;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int likesCounter = 0;
  bool isLikedByMe = false;

  Future<void> _getLiked() async {
    try {
      final res = await DioClient.instance.get(
        "api/offer/offers/${widget.offer.pk}/like/",
      );

      bool temp = false;
      if (res.statusCode == 200) {
        temp = true;
      }
      if (!mounted) return;

      setState(() {
        isLikedByMe = temp;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLikedByMe = false;
      });
    }
  }

  Future<void> _unSave() async {
    final res = await DioClient.instance.delete(
      "api/offer/offers/${widget.offer.pk}/save/",
    );
    if (res.statusCode == 204) {
      widget.parentState();
    }
  }

  Future<void> _createLike() async {
    int temp = likesCounter;

    if (!isLikedByMe) {
      await DioClient.instance.post(
        "api/offer/offers/${widget.offer.pk}/like/",
      );
      if (!mounted) return;
      setState(() {
        isLikedByMe = true;
        temp++;
      });
      
    } else {
      await DioClient.instance.delete(
        "api/offer/offers/${widget.offer.pk}/like/",
      );
      if (!mounted) return;
      setState(() {
        isLikedByMe = false;
        temp--;
      });
    }

    _getLiked();
    setState(() {
      likesCounter = temp;
    });
  }

  @override
  void initState() {
    super.initState();
    likesCounter = widget.offer.likes;
    _getLiked();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => ProductScreen(offer: widget.offer),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (widget.offer.images.isNotEmpty &&
                          widget.offer.images[0].isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: widget.offer.images[0],
                          fit: BoxFit.cover,

                          placeholder:
                              (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                          errorWidget:
                              (context, url, error) => Image.asset(
                                'assets/images/placeholder.png',
                                fit: BoxFit.cover,
                              ),
                        )
                      else
                        Image.asset(
                          'assets/images/placeholder.png',
                          fit: BoxFit.cover,
                        ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                          label: Text(likesCounter.toString()),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black38,
                            foregroundColor: Colors.white,
                          ),
                          icon: Icon(
                            isLikedByMe
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.white,
                          ),
                          onPressed: _createLike,
                        ),
                      ),

                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton.icon(
                          label: Text("تجاهل"),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black38,
                            foregroundColor: Colors.white,
                          ),
                          icon: Icon(Icons.bookmark, color: Colors.white),
                          onPressed: _unSave,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.offer.title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.offer.price} ${widget.offer.currency.name}', // Replace with actual product price
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
