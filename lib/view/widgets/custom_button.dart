import 'package:flutter/material.dart';
import 'package:ken_dala/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final void Function() onTap;
  final String text;
  final Color border_color;
  final Color? background_color;
  final Color? text_color;

  const CustomButton({
    super.key,
    required this.onTap,
    required this.text,
    this.border_color = AppColors.primary_color,
    this.background_color = AppColors.primary_color,
    this.text_color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onTap();
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.maxFinite, 50),
        backgroundColor: background_color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: border_color, width: 1.5),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: text_color,
        ),
      ),
    );
  }
}
