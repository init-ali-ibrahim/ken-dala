import 'package:flutter/material.dart';
import 'package:ken_dala/constants/app_colors.dart';

class CustomRowData extends StatelessWidget {
  final String name;
  final double? size1;
  final double? size2;
  final String value;
  const CustomRowData({
    super.key,
    required this.name,
    required this.value,
    this.size1 = 16,
    this.size2 = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: size1,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: size2,
            color: AppColors.dark_grey_color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
