import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:ken_dala/model/product.dart';
import 'package:ken_dala/view/widgets/main_appbar.dart';
import 'package:ken_dala/view/widgets/main_history.dart';
import 'package:ken_dala/view/widgets/main_list_widget.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:http/http.dart' as http;

class Example extends StatefulWidget {
  const Example({super.key, required this.isar});

  final Isar isar;

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> with TickerProviderStateMixin {
  late AutoScrollController scrollController;
  late TabController tabController;
  late PageData data;
  final listViewKey = RectGetter.createGlobalKey();
  Map<int, dynamic> itemKeys = {};
  late ProductService _productService;
  late AnimationController _controller;
  late Animation<Offset> _animation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _productService = ProductService(widget.isar);
    scrollController = AutoScrollController();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, -0.3),
        ),
        weight: 1.2 / 3,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Offset>(const Offset(0.0, -0.3)),
        weight: 1.5 / 3,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0.0, -0.3),
          end: Offset.zero,
        ),
        weight: 1.2 / 3,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.forward();
  }

  Future<void> _loadData() async {
    try {
      data = await ExampleData.fetchDataFromAPI();
      tabController = TabController(length: data.categories.length, vsync: this);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    scrollController.dispose();
    tabController.dispose();
    super.dispose();
  }

  List<int> getVisibleItemsIndex() {
    Rect? rect = RectGetter.getRectFromKey(listViewKey);
    List<int> items = [];
    if (rect == null) return items;
    itemKeys.forEach((index, key) {
      Rect? itemRect = RectGetter.getRectFromKey(key);
      if (itemRect == null) return;
      if (itemRect.top > rect.bottom) return;
      if (itemRect.bottom < rect.top) return;
      items.add(index);
    });
    return items;
  }

  bool onScrollNotification(ScrollNotification notification) {
    int lastTabIndex = tabController.length - 1;
    List<int> visibleItems = getVisibleItemsIndex();
    bool reachLastTabIndex = visibleItems.isNotEmpty && visibleItems.length <= 2 && visibleItems.last == lastTabIndex;
    if (reachLastTabIndex) {
      tabController.animateTo(lastTabIndex);
    } else if (visibleItems.isNotEmpty) {
      int sumIndex = visibleItems.reduce((value, element) => value + element);
      int middleIndex = sumIndex ~/ visibleItems.length;
      if (tabController.index != middleIndex) tabController.animateTo(middleIndex);
    }
    return false;
  }

  void animateAndScrollTo(int index) {
    tabController.animateTo(
      index,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
    scrollController.scrollToIndex(
      index,
      preferPosition: AutoScrollPosition.begin,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 8),
        child: MainAppbar(),
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
        child: Container(
          decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)), color: Colors.white),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: RectGetter(
            key: listViewKey,
            child: NotificationListener<ScrollNotification>(
              onNotification: onScrollNotification,
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                controller: scrollController,
                slivers: [
                  const SliverToBoxAdapter(child: MainHistory()),
                  // const SliverToBoxAdapter(child: MainListWidget()),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        splashFactory: NoSplash.splashFactory,
                        physics: const NeverScrollableScrollPhysics(),
                        controller: tabController,
                        isScrollable: true,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                        tabAlignment: TabAlignment.start,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.transparent,
                        dividerColor: Colors.transparent,
                        tabs: data.categories.map((category) => Tab(text: category.title)).toList(),
                        onTap: animateAndScrollTo,
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => buildCategoryItem(index),
                      childCount: data.categories.length,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FutureBuilder<List<Product>>(
        future: _productService.getAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/cart');
              },
              child: SlideTransition(
                position: _animation,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const SizedBox(
                    width: 100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          'Cart',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            // return const SizedBox();

            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/cart');
              },
              child: SlideTransition(
                position: _animation,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const SizedBox(
                    width: 100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Cart',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildCategoryItem(int index) {
    itemKeys[index] = RectGetter.createGlobalKey();
    Category category = data.categories[index];
    return Column(
      children: [
        RectGetter(
          key: itemKeys[index],
          child: AutoScrollTag(
            key: ValueKey(index),
            index: index,
            controller: scrollController,
            child: CategorySection(category: category),
          ),
        ),
        const SizedBox(height: 60)
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height + 10;

  @override
  double get maxExtent => _tabBar.preferredSize.height + 10;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: double.infinity,
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class CategorySection extends StatelessWidget {
  const CategorySection({
    super.key,
    required this.category,
  });

  final Category category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildFoodTileList(context),
        ],
      ),
    );
  }

  Widget _buildFoodTileList(BuildContext context) {
    return Column(
      children: category.foods.map((food) => _buildFoodTile(food: food, context: context)).toList(),
    );
  }

  Widget _buildFoodTile({
    required BuildContext context,
    required Food food,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/detail', arguments: food);
      },
      splashColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  food.isNew == true
                      ? Positioned(
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
                      : const SizedBox(),
                  food.isHit == true
                      ? Positioned(
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
                      : const SizedBox(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(food.imageUrl, width: 120, height: 120, fit: BoxFit.cover),
                  ),

                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    food.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/detail', arguments: food);
                    },
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1), minimumSize: const Size(50, 30), backgroundColor: Colors.grey.shade200),
                    child: Text(
                      '${food.price} ₸',
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ExampleData {
  ExampleData._internal();

  static Future<PageData> fetchDataFromAPI() async {
    final url = Uri.parse('http://192.168.0.103:80/api/v1/catalog/products');
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataResponse = json.decode(response.body);
      return dataFromAPI(dataResponse['data']);
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  static PageData dataFromAPI(List<dynamic> productsData) {
    List<Food> foods = productsData.map((productData) {
      return Food(
        id: productData['id'],
        name: productData['name'],
        description: productData['description'],
        slug: productData['slug'],
        price: productData['price'],
        imageUrl: productData['image'],
        quantity: productData['quantity'],
        isNew: productData['is_new'] == true || productData['is_new'] == 'true',
        isHit: productData['is_hit'] == true || productData['is_hit'] == 'true',
      );
    }).toList();

    Category category = Category(
      title: "All Dishes",
      foods: foods,
    );

    return PageData(categories: [category, category]);
  }
}

class PageData {
  List<Category> categories;

  PageData({
    required this.categories,
  });
}

class Category {
  String title;
  List<Food> foods;

  Category({
    required this.title,
    required this.foods,
  });
}

class Food {
  int id;
  String name;
  String slug;
  String description;
  String price;
  String imageUrl;
  int quantity;
  bool isNew;
  bool isHit;

  Food({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.isNew,
    required this.isHit,
  });
}

class ProductService {
  final Isar isar;

  ProductService(this.isar);

  Future<List<Product>> getAllProducts() async {
    return await isar.products.where().findAll();
  }
}
