import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qio/api/users.dart';
import 'package:qio/models/offer.dart';
import 'package:qio/screens/loading.dart';
import 'package:qio/screens/product_screen.dart';

class MyProductCard extends StatefulWidget {
  const MyProductCard({
    super.key,
    required this.offer,
    required this.parentstate,
    required this.canEdeit,
  });
  final Offer offer;
  final bool canEdeit;

  final void Function() parentstate;

  @override
  State<MyProductCard> createState() => _MyProductCardState();
}

class _MyProductCardState extends State<MyProductCard> {
  void _confirmAndDeleteOffer() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("هل أنت متأكد؟"),
            content: Text("سيتم حذف العرض بشكل دائم."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Cancel
                child: Text("إلغاء"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                },
                child: Text("حذف", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (shouldDelete == true) {
      await _deleteOffer();
    }
  }

  Future<void> _deleteOffer() async {
    showLoadingDialog(context);

    int? code;

    try {
      code =
          (await DioClient.instance.delete(
            "api/offer/offers/${widget.offer.pk}/delete/",
          )).statusCode;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    if (!mounted) return;
    hideLoadingDialog(context);

    if (code == 204) {
      widget.parentstate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => ProductScreen(offer: widget.offer),
            ),
          );
        },
        tileColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        dense: true,
        leading:
            widget.offer.images.isNotEmpty
                ? CachedNetworkImage(
                  imageUrl: widget.offer.images[0],
                  placeholder:
                      (context, url) =>
                          Center(child: CircularProgressIndicator()),
                  errorWidget:
                      (context, url, error) => Text(
                        widget.offer.user.substring(0, 1).toUpperCase(),
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                )
                : SizedBox(
                  width: 80,
                  height: 80,
                  child: Center(
                    child: Text(
                      widget.offer.user.substring(0, 1).toUpperCase(),
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
        title: Text(widget.offer.title, style: TextStyle(color: Colors.white)),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.offer.price.toString()} ${widget.offer.currency.name}',
              style: TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            //number of views and saved with icons
            Spacer(),

            SizedBox(width: 10),
            Icon(Icons.bookmark, size: 15),
            SizedBox(width: 5),
            Text(widget.offer.saves.toString()),
          ],
        ),

        trailing:
            widget.canEdeit
                ? IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: _confirmAndDeleteOffer,
                )
                : Text(""),
      ),
    );
  }
}
