import 'package:flutter/material.dart';

class MainListWidget extends StatefulWidget {
  const MainListWidget({super.key});

  @override
  State<MainListWidget> createState() => _MainListWidgetState();
}

class _MainListWidgetState extends State<MainListWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Text('New and popular', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
        ),
        SizedBox(
          height: 110,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: [
              const SizedBox(width: 15),
              InkWell(
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset('assets/coffee2', width: 110, height: 110, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Spicy Meat Fast',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0), minimumSize: const Size(50, 30), backgroundColor: Colors.grey.shade200),
                            child: const Text(
                              'from 2 990 T',
                              style: TextStyle(fontSize: 12, color: Colors.black),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                // onTap: () => Navigator.pushNamed(context, '/detail'),
              ),
              const SizedBox(width: 60),
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/coffee3', width: 110, height: 110, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Spicy Meat Fast',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1), minimumSize: const Size(50, 30), backgroundColor: Colors.grey.shade200),
                          child: const Text(
                            'from 2 990 T',
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 60),
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/coffee1', width: 110, height: 110, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Spicy Meat Fast',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1), minimumSize: const Size(50, 30), backgroundColor: Colors.grey.shade200),
                          child: const Text(
                            'from 2 990 T',
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    ));
  }
}
