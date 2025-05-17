/*
import 'package:flutter/material.dart';
import 'package:qio/models/offer.dart';


class OfferProvider with ChangeNotifier {
  final List<Offer> _offers = [];

  List<Offer> get offers => _offers;


  List<Offer> get dummyOffers => [
    Offer(
      pk: 2,
      longitude: 0.0,
      latitude: 0.0,
      user: 'jane@example.com',

      title: 'Offer 1',
      phone: '123456789',
      description: 'Description for offer 1',
      images: [
        'https://picsum.photos/500/500',
        'https://picsum.photos/500/500',
      ],
      category: 'Electronics',
      price: 100,
      currency: Currency.syrian,
      date: DateTime.now().toString(),
      likes: 5,
      saves: 2,
      type: OfferType.looking,
    ),
    Offer(
      pk: 1,
      longitude: 0.0,
      latitude: 0.0,
      user: 'jane@example.com',
      title: 'Offer 2',
      phone: '987654321',
      description: 'Description for offer 2',
      images: [
        'https://picsum.photos/500/500',
        'https://picsum.photos/500/500',
      ],
      category: 'Books',
      price: 50,
      currency: Currency.syrian,
      date: DateTime.now().toString(),
      likes: 10,
      saves: 5,
      type: OfferType.offering,
    ),
    ..._offers,
  ];

  void addOffer(Offer offer) {
    _offers.add(offer);
    notifyListeners();
  }

  void removeOffer(Offer offer) {
    _offers.remove(offer);
    notifyListeners();
  }

  void updateOffer(Offer oldOffer, Offer newOffer) {
    final index = _offers.indexOf(oldOffer);
    if (index != -1) {
      _offers[index] = newOffer;
      notifyListeners();
    }
  }
}
*/