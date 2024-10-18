import 'package:flutter/material.dart';
import 'package:ken_dala/constants/app_colors.dart';

class CustomRow2 extends StatelessWidget {
  final String name;
  final double? size1;
  final double? size2;
  final String value;
  final Color? color1;
  final FontWeight? weight;
  const CustomRow2({
    super.key,
    required this.name,
    required this.value,
    this.size1 = 16,
    this.size2 = 16,
    this.color1 = AppColors.dark_grey_color,
    this.weight = FontWeight.w500,
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
            color: color1,
            fontWeight: weight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: size2,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
