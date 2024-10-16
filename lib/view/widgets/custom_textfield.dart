import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Icon icon;
  final bool obs;
  final double rad;
  final TextInputType? ktype;
  CustomTextfield({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obs = false,
    this.ktype,
    this.rad = 30,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.maxFinite,
      child: TextFormField(
        controller: controller,
        obscureText: obs,
        keyboardType: ktype,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rad),
          ),
          prefixIcon: icon,
        ),
      ),
    );
  }
}
