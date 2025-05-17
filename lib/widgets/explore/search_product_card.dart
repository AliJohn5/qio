import 'package:flutter/material.dart';
import 'package:qio/api/users.dart';
import 'package:qio/models/offer.dart';
import 'package:qio/screens/product_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchProductCard extends StatefulWidget {
  const SearchProductCard({
    super.key,
    required this.offer,
    required this.parentState,
    required this.isSmall,
  });

  final Offer offer;
  final Function() parentState;
  final bool isSmall;

  @override
  State<SearchProductCard> createState() => _SearchProductCardState();
}

class _SearchProductCardState extends State<SearchProductCard> {
  int likesCounter = 0;
  bool isLikedByMe = false;
  bool isSavedByne = false;

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
      if (!mounted) return;
      setState(() {
        isSavedByne = false;
      });
    }
  }

  Future<void> _save() async {
    final res = await DioClient.instance.post(
      "api/offer/offers/${widget.offer.pk}/save/",
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      if (!mounted) return;
      setState(() {
        isSavedByne = true;
      });
    }
  }

  Future<void> _getSaved() async {
    try {
      final res = await DioClient.instance.get(
        "api/offer/offers/${widget.offer.pk}/save/",
      );
      bool temp = false;
      if (res.statusCode == 200) {
        temp = true;
      }
      if (!mounted) return;

      setState(() {
        isSavedByne = temp;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSavedByne = false;
      });
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
        temp = temp + 1;
      });
    } else {
      await DioClient.instance.delete(
        "api/offer/offers/${widget.offer.pk}/like/",
      );
      if (!mounted) return;
      setState(() {
        isLikedByMe = false;
        temp = temp - 1;
      });
    }

    await _getLiked();
    if (!mounted) return;
    setState(() {
      likesCounter = temp;
    });
  }

  Future<void> _savedAction() async {
    if (isSavedByne) {
      await _unSave();
    } else {
      await _save();
    }
  }

  @override
  void initState() {
    super.initState();
    likesCounter = widget.offer.likes;
    _getLiked();
    _getSaved();
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
        shape: RoundedRectangleBorder(
          borderRadius:
              widget.isSmall
                  ? BorderRadius.circular(5)
                  : BorderRadius.circular(10),
        ),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150,
                height: 175,
                child: Container(
               
                  decoration: BoxDecoration(
                    borderRadius:
                        widget.isSmall
                            ? BorderRadius.circular(5)
                            : BorderRadius.circular(10),
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
                        alignment: Alignment.bottomLeft,
                        child: TextButton.icon(
                          label: Text(
                            _fixLikes(likesCounter),
                            style: TextStyle(fontSize: 15),
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black38,
                            foregroundColor: Colors.white,
                          ),
                          icon: Icon(
                            isLikedByMe
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.white,
                            size: widget.isSmall ? 15 : 20,
                          ),
                          onPressed: _createLike,
                        ),
                      ),

                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black38,
                            foregroundColor: Colors.white,
                          ),
                          icon: Icon(
                            isSavedByne
                                ? Icons.bookmark
                                : Icons.bookmark_add_outlined,
                            color: Colors.white,
                            size: widget.isSmall ? 15 : 20,
                          ),
                          onPressed: _savedAction,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // const SizedBox(height: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,

                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        "${getTypeArabic(widget.offer.type.name)} ${widget.offer.title}",
                        style: TextStyle(
                          fontSize: widget.isSmall ? 12 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                     SizedBox(height: widget.isSmall ? 2 : 4),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        widget.offer.description, // Replace with actual product price
                        style: TextStyle(
                          fontSize: widget.isSmall ? 12 : 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),

                    SizedBox(height: widget.isSmall ? 2 : 4),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '${widget.offer.price} ${widget.offer.currency.name}', // Replace with actual product price
                        style: TextStyle(
                          fontSize: widget.isSmall ? 12 : 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fixLikes(int cnt) {
    if (cnt < 100) return cnt.toString();
    if (cnt < 1000) return "${(cnt / 100).toString()}H";
    if (cnt < 10000) return "${(cnt / 1000).toString()}K";
    if (cnt < 10000000) return "${(cnt / 1000000).toString()}M";
    return "0";
  }
}
