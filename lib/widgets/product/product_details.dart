import 'package:flutter/material.dart';

class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('ماركة', 'أوبل'),
          _buildDetailRow('نموذج', 'أسترا'),
          _buildDetailRow('المسافة المقطوعة', '215,577 كم'),
          _buildDetailRow('حالة المركبة', 'مركبة غير متضررة'),
          _buildDetailRow('التسجيل الاولي', 'أكتوبر 2012'),
          _buildDetailRow('نوع الوقود', 'ديزل'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
