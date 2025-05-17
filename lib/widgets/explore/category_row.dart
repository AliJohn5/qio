import 'package:flutter/material.dart';
import 'package:qio/models/category.dart';
import 'package:qio/widgets/explore/category_box.dart';

class CategoryRow extends StatelessWidget {
  const CategoryRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: OfferCategory.all.map(

          (category) {
            
            return CategoryBox(category: category,isSelected: false,);
          },
        ).toList(),
      ),
    );
  }
}
