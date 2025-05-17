import 'package:flutter/material.dart';
import 'package:qio/models/category.dart';

class CategoryBox extends StatelessWidget {
  const CategoryBox({
    super.key,
    required this.category,
    required this.isSelected,
  });
  final String category;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(
            OfferCategory.getIcon(category),
            color: Colors.black,
            size: 50,
          ),
        ),
        const SizedBox(height: 5),
        Text(OfferCategory.translate(category), style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
