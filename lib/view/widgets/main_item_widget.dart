import 'package:flutter/material.dart';

class MainItemWidget extends StatefulWidget {
  const MainItemWidget({super.key});

  @override
  State<MainItemWidget> createState() => _MainItemWidgetState();
}

class _MainItemWidgetState extends State<MainItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/coffee', width: 120, height: 120, fit: BoxFit.cover),
              ),
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'New',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     const SizedBox(
              //       child: Text('Spicy Meat Fast',
              //           style: TextStyle(
              //             fontSize: 14,
              //             color: Colors.black,
              //             fontWeight: FontWeight.bold,
              //           ),
              //           overflow: TextOverflow.ellipsis),
              //     ),
              //     const SizedBox(width: 8),
              //     Container(
              //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              //       decoration: BoxDecoration(
              //         color: Colors.red,
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       child: const Text(
              //         'New',
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 10,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              const Text('Spicy Meat Fast',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                width: MediaQuery.of(context).size.width - 160,
                child: const Text(
                  'Lorem Ipsum is simply dummy text of the printing and typesetting industry. '
                  'Lorem Ipsum is simply dummy text of the printing and typesetting industry. ',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  softWrap: true,
                ),
              ),
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
    );
  }
}


class MainItemWidget1 extends StatefulWidget {
  const MainItemWidget1({super.key});

  @override
  State<MainItemWidget1> createState() => _MainItemWidget1State();
}

class _MainItemWidget1State extends State<MainItemWidget1> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/coffee', width: 120, height: 120, fit: BoxFit.cover),
              ),
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Hit',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Spicy Meat Fast',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                width: MediaQuery.of(context).size.width - 160,
                child: const Text(
                  'Lorem Ipsum is simply dummy text of the printing and typesetting industry. ',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  softWrap: true,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1), minimumSize: const Size(50, 30), backgroundColor: Colors.grey.shade200),
                child: Text(
                  'Sold out',
                  style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.3)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
