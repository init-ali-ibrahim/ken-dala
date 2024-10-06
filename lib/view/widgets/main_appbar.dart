import 'package:flutter/material.dart';

class MainAppbar extends StatefulWidget {
  const MainAppbar({super.key});

  @override
  State<MainAppbar> createState() => _MainAppbarState();
}

class _MainAppbarState extends State<MainAppbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFF0F1F4),
      surfaceTintColor: const Color(0xFFF0F1F4),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  style: IconButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(0)),
                  onPressed: () {
                    // Navigator.pushNamed(context, '/profile');
                  },
                  icon: const Icon(
                    Icons.man,
                    size: 24,
                    color: Colors.red,
                  )),
              const SizedBox(width: 5),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Almaty, 11 th microstructure, 36',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_sharp,
                        size: 20,
                      )
                    ],
                  ),
                  RichText(
                      text: const TextSpan(
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    children: [TextSpan(text: 'Free delivery, '), TextSpan(text: 'in about 33 min', style: TextStyle(color: Colors.green))],
                  )),
                ],
              )
            ],
          ),
          IconButton(
              style: IconButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              icon: const Icon(
                Icons.man,
                color: Colors.red,
              )),
        ],
      ),
    );
  }
}
