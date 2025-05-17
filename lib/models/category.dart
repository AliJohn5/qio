import 'package:flutter/material.dart';

abstract class OfferCategory {
  static const String clothes = 'clothes';
  static const String electronics = 'electronics';
  static const String furniture = 'furniture';
  static const String cars = 'cars';
  static const String books = 'books';
  static const String toys = 'toys';
  static const String allof = 'all';

  static IconData clothesIcon = Icons.shopping_bag;
  static IconData electronicsIcon = Icons.electrical_services;
  static IconData furnitureIcon = Icons.chair;
  static IconData carsIcon = Icons.car_repair;
  static IconData booksIcon = Icons.book;
  static IconData toysIcon = Icons.toys;
  static IconData allofIcon = Icons.select_all;

  static List<String> get all => [
    clothes,
    electronics,
    furniture,
    cars,
    books,
    toys,
    allof,
  ];

  static List<String> get allex => [
    clothes,
    electronics,
    furniture,
    cars,
    books,
    toys,
  ];

  static IconData getIcon(String category) {
    switch (category) {
      case clothes:
        return clothesIcon;
      case electronics:
        return electronicsIcon;
      case furniture:
        return furnitureIcon;
      case cars:
        return carsIcon;
      case books:
        return booksIcon;
      case toys:
        return toysIcon;
      case allof:
        return allofIcon;
      default:
        return allofIcon;
    }
  }

  static String fromString(String category) {
    switch (category) {
      case clothes:
        return clothes;
      case electronics:
        return electronics;
      case furniture:
        return furniture;
      case cars:
        return cars;
      case books:
        return books;
      case toys:
        return toys;
      case allof:
        return allof;
      default:
        return allof;
    }
  }

  static String translate(String category) {
    switch (category) {
      case clothes:
        return 'ملابس';
      case electronics:
        return "كهرابائيات";
      case furniture:
        return "أثاث";
      case cars:
        return "سيارات";
      case books:
        return "كتب";
      case toys:
        return "ألعاب";
      case allof:
        return "الكل";
      default:
        return "الكل";
    }
  }
}
