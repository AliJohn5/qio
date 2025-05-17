// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:qio/providers/offer_provider.dart';
// import 'package:qio/screens/add_offer.dart';
// import 'package:qio/widgets/offer/my_product_card.dart';

// class OffersScreen extends StatelessWidget {
//   const OffersScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final offers = Provider.of<OfferProvider>(context).dummyOffers;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('العروض'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (ctx) => AddOffer(),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: offers.length,
//         itemBuilder: (ctx, i) => MyProductCard(
//           offer: offers[i],
//         ),
//       ),
//     );
//   }
// }
