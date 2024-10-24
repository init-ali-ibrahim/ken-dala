import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:ken_dala/constants/app_colors.dart';
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

  Future<void> controlProductId(int productId, String name, int price, String imgUrl) async {
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

  Future<void> addProductNew(int productId, String name, int price, String imgUrl) async {
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
          style: const TextStyle(fontSize: 20,),
        ),
      ),
      body: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Container(
                  height: 500,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(colors: [
                        Colors.white,
                        Colors.orange.shade50,
                        Colors.orange.shade200,
                      ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  child: Center(
                      child: ClipRRect( borderRadius: const BorderRadius.only(bottomRight: Radius.circular(30), bottomLeft: Radius.circular(30)),
                        child: Image.network(
                          food.imageUrl,
                          width: MediaQuery.of(context).size.width,
                          height: 500,
                          fit: BoxFit.cover,
                        ),
                  ))),
              Positioned(
                top: 0,
                left: 0,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Container(
                    margin: const EdgeInsets.only(top: 500),
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
                    Navigator.pop(context);
                  } catch (e, stackTrace) {
                    print("Error in onTap: $e");
                    print("Stack trace: $stackTrace");
                  }
                },
                splashColor: AppColors.primary_color,
                borderRadius: BorderRadius.circular(99),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      // shape: BoxShape.circle,
                      color: AppColors.primary_color,
                    ),
                    child: Center(
                      child: Text(
                        '+ ₸ ${food.price}',
                        style: const TextStyle(
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
