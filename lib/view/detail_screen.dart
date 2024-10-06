import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:ken_dala/model/product.dart';
import 'package:ken_dala/primer.dart' as dateScreen;

class DetailScreen extends StatefulWidget {
  final Isar isar;

  const DetailScreen({super.key, required this.isar});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late ProductService productService;

  @override
  void initState() {
    super.initState();
    productService = ProductService(widget.isar);
  }

  Future<void> controlProductId(int productId, String name, String price, String imgUrl) async {
    try {
      final comingProduct = await productService.isar.products.filter().productIdEqualTo(productId).findFirst();

      if (comingProduct != null) {
        await productService.updateQuantity(comingProduct, comingProduct.quantity + 1);
      } else {
        await addProductNew(productId, name, price, imgUrl);
      }
    } catch (e, stackTrace) {
      print("Error in controlProductId: $e");
      print("Stack trace: $stackTrace");
    }
  }

  Future<void> addProductNew(int productId, String name, String price, String imgUrl) async {
    try {
      final newProduct = Product(
        productId: productId,
        name: name,
        slug: 'slug',
        price: price,
        images: imgUrl,
        quantity: 1,
      );

      await productService.addProduct(newProduct);
    } catch (e, stackTrace) {
      print("Error in addProductNew: $e");
      print("Stack trace: $stackTrace");
    }
  }

  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final dateScreen.Food food = ModalRoute.of(context)!.settings.arguments as dateScreen.Food;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        leading: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 25,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        title: Text(
          food.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Container(
                  height: 400,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(colors: [
                        Colors.white,
                        Colors.orange.shade50,
                        Colors.orange.shade200,
                      ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  child: Center(
                      // child: Image.network(
                      //   food.imageUrl,
                      //   width: 200,
                      //   height: 200,
                      //   fit: BoxFit.cover,
                      // ),
                      child: ClipRRect( borderRadius: const BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20)),
                        child: Image.network(
                          food.imageUrl,
                          width: MediaQuery.of(context).size.width,
                          height: 400,
                          fit: BoxFit.cover,
                        ),
                  ))),
              Positioned(
                top: 0,
                left: 0,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Container(
                    margin: const EdgeInsets.only(top: 400),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F0F6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // const Padding(
                                        //   padding: EdgeInsets.only(bottom: 5),
                                        //   child: Text(
                                        //     'food.description',
                                        //     style: TextStyle(fontSize: 18),
                                        //   ),
                                        // ),
                                        Text(
                                          food.description,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              )
            ],
          )),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: 80,
        decoration: const BoxDecoration(border: Border(top: BorderSide(width: 1, color: Colors.grey))),
        child: Container(
          margin: const EdgeInsets.all(10),
          child: AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 130),
              child: InkWell(
                onTapDown: (_) async {
                  setState(() {
                    _scale = 0.95;
                  });
                },
                onTapUp: (_) async {
                  setState(() {
                    _scale = 1.0;
                  });
                },
                onTap: () async {
                  try {
                    await controlProductId(food.id, food.name, food.price, food.imageUrl);
                  } catch (e, stackTrace) {
                    print("Error in onTap: $e");
                    print("Stack trace: $stackTrace");
                  }
                },
                splashColor: const Color(0xFF0A1A78),
                borderRadius: BorderRadius.circular(99),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      // shape: BoxShape.circle,
                      color: const Color(0xC01B31B4),
                    ),
                    child: const Center(
                      child: Text(
                        'Composition',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )),
              )),
        ),
      ),
    );
  }
}
