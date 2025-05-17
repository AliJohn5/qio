import 'package:qio/api/users.dart';
import 'package:qio/models/category.dart';

class Offer {
  final String user;
  final OfferType type;
  final String title;
  final String description;
  final List<String> images;
  final String category;
  final int price;
  final Currency currency;
  final double latitude;
  final double longitude;
  final String date;
  final String phone;
  final int likes;
  final int saves;
  final int pk;

  Offer({
    required this.longitude,
    required this.latitude,
    required this.title,
    required this.user,
    required this.type,
    required this.description,
    required this.images,
    required this.phone,
    required this.category,
    required this.price,
    required this.currency,
    required this.date,
    required this.likes,
    required this.saves,
    required this.pk,
  });

  factory Offer.fromJson(Map<String, dynamic> off) {
    List<String> images = [];

    for (var img in off['images']) {
      images.add("$domain${img['image']}");
    }

    return Offer(
      title: off['title'],
      user: off['user'],
      type:
          off['offer_type'] == 'looking'
              ? OfferType.looking
              : OfferType.offering,
      description: off['description'],
      images: images,
      phone: off['phone_number'],
      category: OfferCategory.fromString(off['category_type']),
      price: off['price'] ?? 0,
      currency: off['currency'] == 'usd' ? Currency.usd : Currency.syrian,
      date: off['timestamp'] ?? "",
      likes: off['like_counter'] ?? 0,
      saves: off['save_counter'] ?? 0,
      longitude: off['longitude'] ?? 0.0,
      latitude: off['latitude'] ?? 0.0,
      pk: off['id'] ?? -1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'type': type,
      'title': title,
      'description': description,
      'images': images,
      'category': category,
      'price': price,
      'currency': currency.index,
      'phone': phone,
      'longitude': longitude,
      'latitude': latitude,
      'date': date,
      'likes': likes,
      'saves': saves,
      'pk': pk,
    };
  }

  static Offer fromRequest(Map<String, dynamic> off) {
    List<String> images = [];

    for (var img in off['offer']['images']) {
      images.add("$domain${img['image']}");
    }

    return Offer(
      title: off['offer']['title'],
      user: off['user'],
      type:
          off['offer']['offer_type'] == 'looking'
              ? OfferType.looking
              : OfferType.offering,
      description: off['offer']['description'],
      images: images,
      phone: off['offer']['phone_number'],
      category: OfferCategory.fromString(off['offer']['category_type']),
      price: off['offer']['price'] ?? 0,
      currency:
          off['offer']['currency'] == 'usd' ? Currency.usd : Currency.syrian,
      date: off['offer']['timestamp'] ?? "",
      likes: off['offer']['like_counter'] ?? 0,
      saves: off['offer']['save_counter'] ?? 0,
      longitude: off['offer']['longitude'] ?? 0.0,
      latitude: off['offer']['latitude'] ?? 0.0,
      pk: off['offer']['id'] ?? -1,
    );
  }
}

enum Currency { syrian, usd }

extension CurrencyExtension on Currency {
  String get name {
    switch (this) {
      case Currency.syrian:
        return 'ليرة سورية';
      case Currency.usd:
        return 'دولار';
    }
  }
}

enum OfferType { looking, offering }

String getTypeArabic(String val) {
  if (val == 'looking') return 'أبحث عن';
  return 'أعرض';
}
