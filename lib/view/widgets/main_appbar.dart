import 'package:flutter/material.dart';
import 'package:ken_dala/constants/app_colors.dart';

class MainAppbar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFF4F4F6),
      surfaceTintColor: const Color(0xFFF4F4F6),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // IconButton(
              //     style: IconButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(0)),
              //     onPressed: () {
              //       Navigator.pushNamed(context, '/map');
              //     },
              //     icon: const Icon(
              //       Icons.man,
              //       size: 24,
              //       color: AppColors.primary_color,
              //     )),

              InkWell(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 70,
                ),
              ),
              const SizedBox(width: 5),
              InkWell(
                splashFactory: NoSplash.splashFactory,
                onTap: () {
                  Navigator.pushNamed(context, '/map');
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Алматы, 11-й микрорайон, 36',
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
                      children: [TextSpan(text: 'Бесплатная доставка, '), TextSpan(text: 'через 33 минуты', style: TextStyle(color: Colors.green))],
                    )),
                  ],
                ),
              )
            ],
          ),
          IconButton(
              style: IconButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              icon: const Icon(
                Icons.emoji_emotions,
                color: AppColors.primary_color,
              )),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, kToolbarHeight + 8);
}
