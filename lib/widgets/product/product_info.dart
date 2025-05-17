import 'package:flutter/material.dart';
import 'package:qio/models/offer.dart';

class ProductInfo extends StatelessWidget {
  const ProductInfo({super.key, required this.offer, required this.country});

  final Offer offer;
  final String country;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${getTypeArabic(offer.type.name)} ${offer.title}",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 10),

          Text(
            'السعر: ${offer.price} ${offer.currency.name}',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 10),
          //location
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
              SizedBox(width: 5),
              Text(country),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20),
              SizedBox(width: 5),
              Text(offer.date.toString().substring(0, 10)),
            ],
          ),
        ],
      ),
    );
  }
}
