// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:isar/isar.dart';
// import 'package:ken_dala/model/product.dart';
// import 'package:ken_dala/view/widgets/main_appbar.dart';
// import 'package:ken_dala/view/widgets/main_history.dart';
// import 'package:ken_dala/view/widgets/main_list_widget.dart';
// import 'package:rect_getter/rect_getter.dart';
// import 'package:scroll_to_index/scroll_to_index.dart';
// import 'package:http/http.dart' as http;
//
// class Example extends StatefulWidget {
//   const Example({super.key, required this.isar});
//
//   final Isar isar;
//
//   @override
//   State<Example> createState() => _ExampleState();
// }
//
// class _ExampleState extends State<Example> with TickerProviderStateMixin {
//   late AutoScrollController scrollController;
//   late TabController tabController;
//   final PageData data = ExampleData.data;
//   final listViewKey = RectGetter.createGlobalKey();
//   Map<int, dynamic> itemKeys = {};
//   late ProductService _productService;
//   late AnimationController _controller;
//   late Animation<Offset> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//     getUp();
//     _productService = ProductService(widget.isar);
//     tabController = TabController(length: data.categories.length, vsync: this);
//     scrollController = AutoScrollController();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );
//     _animation = TweenSequence<Offset>([
//       TweenSequenceItem(
//         tween: Tween<Offset>(
//           begin: Offset.zero,
//           end: const Offset(0.0, -0.3),
//         ),
//         weight: 1.2 / 3,
//       ),
//       TweenSequenceItem(
//         tween: ConstantTween<Offset>(const Offset(0.0, -0.3)),
//         weight: 1.5 / 3,
//       ),
//       TweenSequenceItem(
//         tween: Tween<Offset>(
//           begin: const Offset(0.0, -0.3),
//           end: Offset.zero,
//         ),
//         weight: 1.2 / 3,
//       ),
//     ]).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeInOut,
//       ),
//     );
//     _controller.forward();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     scrollController.dispose();
//     tabController.dispose();
//     super.dispose();
//   }
//
//   List<int> getVisibleItemsIndex() {
//     Rect? rect = RectGetter.getRectFromKey(listViewKey);
//     List<int> items = [];
//     if (rect == null) return items;
//     itemKeys.forEach((index, key) {
//       Rect? itemRect = RectGetter.getRectFromKey(key);
//       if (itemRect == null) return;
//       if (itemRect.top > rect.bottom) return;
//       if (itemRect.bottom < rect.top) return;
//       items.add(index);
//     });
//     return items;
//   }
//
//   bool onScrollNotification(ScrollNotification notification) {
//     int lastTabIndex = tabController.length - 1;
//     List<int> visibleItems = getVisibleItemsIndex();
//     bool reachLastTabIndex = visibleItems.isNotEmpty && visibleItems.length <= 2 && visibleItems.last == lastTabIndex;
//     if (reachLastTabIndex) {
//       tabController.animateTo(lastTabIndex);
//     } else if (visibleItems.isNotEmpty) {
//       int sumIndex = visibleItems.reduce((value, element) => value + element);
//       int middleIndex = sumIndex ~/ visibleItems.length;
//       if (tabController.index != middleIndex) tabController.animateTo(middleIndex);
//     }
//     return false;
//   }
//
//   void animateAndScrollTo(int index) {
//     tabController.animateTo(
//       duration: const Duration(seconds: 1),
//       index,
//       curve: Easing.standard,
//     );
//     scrollController.scrollToIndex(
//       index,
//       preferPosition: AutoScrollPosition.begin,
//       duration: const Duration(seconds: 1),
//     );
//   }
//
//   late List<dynamic> da = [];
//
//   Future<void> getUp() async {
//     final url = Uri.parse('http://192.168.0.219/api/v1/catalog/products');
//     final response = await http.get(url, headers: {
//       'Accept': 'application/json',
//     });
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataResponse = json.decode(response.body);
//       setState(() {
//         da = dataResponse['data'];
//         print(da);
//       });
//     } else {
//       print('Ошибка запроса');
//     }
//   }
//
//   // UI
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F1F4),
//       appBar: const PreferredSize(
//         preferredSize: Size.fromHeight(kToolbarHeight + 8),
//         child: MainAppbar(),
//       ),
//       body: ClipRRect(
//         borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
//         child: Container(
//             decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)), color: Colors.white),
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             child: RectGetter(
//                 key: listViewKey,
//                 child: NotificationListener<ScrollNotification>(
//                   onNotification: onScrollNotification,
//                   child: CustomScrollView(
//                     physics: const ClampingScrollPhysics(),
//                     controller: scrollController,
//                     slivers: [
//                       const SliverToBoxAdapter(child: MainHistory()),
//                       const SliverToBoxAdapter(child: MainListWidget()),
//                       SliverPersistentHeader(
//                         pinned: true,
//                         delegate: _SliverAppBarDelegate(
//                           TabBar(
//                             splashFactory: NoSplash.splashFactory,
//                             physics: const NeverScrollableScrollPhysics(),
//                             controller: tabController,
//                             isScrollable: true,
//                             labelPadding: const EdgeInsets.symmetric(horizontal: 20),
//                             tabAlignment: TabAlignment.start,
//                             labelColor: Colors.black,
//                             unselectedLabelColor: Colors.grey,
//                             indicatorColor: WidgetStateColor.transparent,
//                             dividerColor: WidgetStateColor.transparent,
//                             tabs: data.categories.map((category) => Tab(text: category.title)).toList(),
//                             onTap: animateAndScrollTo,
//                           ),
//                         ),
//                       ),
//                       SliverList(
//                         delegate: SliverChildBuilderDelegate(
//                               (context, index) => buildCategoryItem(index),
//                           childCount: data.categories.length,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ))),
//       ),
//       floatingActionButton: FutureBuilder<List<Product>>(
//         future: _productService.getAllProducts(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return SizedBox();
//           }
//
//           if (snapshot.hasData && snapshot.data!.isNotEmpty) {
//             return InkWell(
//               onTap: () {
//                 Navigator.pushNamed(context, '/cart');
//               },
//               child: SlideTransition(
//                 position: _animation,
//                 child: Container(
//                   padding: const EdgeInsets.all(15),
//                   decoration: BoxDecoration(
//                     color: Colors.lightBlue,
//                     borderRadius: BorderRadius.circular(100),
//                   ),
//                   child: const SizedBox(
//                     width: 100,
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.add_shopping_cart,
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                         SizedBox(
//                           width: 20,
//                         ),
//                         Text(
//                           'data',
//                           style: TextStyle(color: Colors.white, fontSize: 20),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           } else {
//             return SizedBox();
//           }
//         },
//       ),
//     );
//   }
//
//   Widget buildCategoryItem(int index) {
//     itemKeys[index] = RectGetter.createGlobalKey();
//     Category category = data.categories[index];
//     return Column(
//       children: [
//         RectGetter(
//           key: itemKeys[index],
//           child: AutoScrollTag(
//             key: ValueKey(index),
//             index: index,
//             controller: scrollController,
//             child: CategorySection(category: category),
//           ),
//         ),
//         const SizedBox(height: 60)
//       ],
//     );
//   }
// }
//
// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar _tabBar;
//
//   _SliverAppBarDelegate(this._tabBar);
//
//   @override
//   double get minExtent => _tabBar.preferredSize.height + 10;
//
//   @override
//   double get maxExtent => _tabBar.preferredSize.height + 10;
//
//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       height: double.infinity,
//       color: Colors.white,
//       child: _tabBar,
//     );
//   }
//
//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return false;
//   }
// }
//
// class CategorySection extends StatelessWidget {
//   const CategorySection({
//     super.key,
//     required this.category,
//   });
//
//   final Category category;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 15),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeaderWidget(context),
//           _buildFoodTileList(context),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFoodTileList(BuildContext context) {
//     return Column(
//         children: List.generate(
//           category.foods.length,
//               (index) {
//             final food = category.foods[index];
//             return _buildFoodTile(
//               food: food,
//               context: context,
//             );
//           },
//         ));
//   }
//
//   Widget _buildFoodTile({
//     required BuildContext context,
//     required Food food,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(top: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             height: 120,
//             child: Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(20),
//                   child: Image.network(food.imageUrl, width: 120, height: 120, fit: BoxFit.cover),
//                 ),
//                 food.isNewSale == true
//                     ? Positioned(
//                   right: 5,
//                   top: 5,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Text(
//                       'New',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                       ),
//                     ),
//                   ),
//                 )
//                     : const SizedBox(),
//                 food.isHotSale == true
//                     ? Positioned(
//                   right: 5,
//                   top: 5,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
//                     decoration: BoxDecoration(
//                       color: Colors.orange,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Text(
//                       'Hit',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 10,
//                       ),
//                     ),
//                   ),
//                 )
//                     : const SizedBox(),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Text(food.name,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   overflow: TextOverflow.ellipsis),
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 2),
//                 width: MediaQuery.of(context).size.width - 170,
//                 child: Text(
//                   food.description,
//                   style: const TextStyle(color: Colors.grey, fontSize: 12),
//                   softWrap: true,
//                 ),
//               ),
//               food.count == 0
//                   ? TextButton(
//                 onPressed: () {},
//                 style: TextButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1), minimumSize: const Size(50, 30), backgroundColor: Colors.grey.shade200),
//                 child: Text(
//                   'Sold out',
//                   style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.3)),
//                 ),
//               )
//                   : TextButton(
//                 onPressed: () {},
//                 style: TextButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1), minimumSize: const Size(50, 30), backgroundColor: Colors.grey.shade200),
//                 child: Text(
//                   food.price,
//                   style: const TextStyle(fontSize: 12, color: Colors.black),
//                 ),
//               )
//             ],
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeaderWidget(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // const SizedBox(height: 80.0),
//         if (category.headerWidget != null) category.headerWidget as Widget,
//         const SizedBox(height: 8),
//       ],
//     );
//   }
// }
//
// class _HeaderListWidget extends StatelessWidget {
//   final String urlImage;
//   final String name;
//   final String description;
//   final bool isNewSale;
//   final bool isHotSale;
//   final String price;
//
//   const _HeaderListWidget({required this.urlImage, required this.name, required this.description, required this.isNewSale, required this.isHotSale, required this.price});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//         child: Container(
//           padding: const EdgeInsets.only(top: 10),
//           margin: const EdgeInsets.only(top: 10),
//           width: MediaQuery.of(context).size.width - 40,
//           decoration: const BoxDecoration(
//             borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20), topLeft: Radius.circular(200), topRight: Radius.circular(200)),
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.center,
//               colors: <Color>[
//                 Color(0xb23f0098),
//                 Color(0xfff7f7fe),
//               ],
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Center(
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 60, bottom: 10),
//                   child: Stack(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: Image.asset('assets/pizza.png', width: MediaQuery.of(context).size.width - 140, fit: BoxFit.cover),
//                       ),
//                       isNewSale == true
//                           ? Positioned(
//                         right: 5,
//                         top: 5,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
//                           decoration: BoxDecoration(
//                             color: Colors.red,
//                             borderRadius: BorderRadius.circular(24),
//                           ),
//                           child: const Text(
//                             'New',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                             ),
//                           ),
//                         ),
//                       )
//                           : const SizedBox(),
//                       isHotSale == true
//                           ? Positioned(
//                         right: 5,
//                         top: 5,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
//                           decoration: BoxDecoration(
//                             color: Colors.orange,
//                             borderRadius: BorderRadius.circular(24),
//                           ),
//                           child: const Text(
//                             'Hit',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 20,
//                             ),
//                           ),
//                         ),
//                       )
//                           : const SizedBox(),
//                     ],
//                   ),
//                 ),
//               ),
//               Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Text(
//                         name,
//                         style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
//                       ),
//                       Text(
//                         description,
//                         style: const TextStyle(color: Colors.grey, fontSize: 12),
//                       )
//                     ],
//                   )),
//               Align(
//                   alignment: Alignment.topRight,
//                   child: Container(
//                     margin: const EdgeInsets.only(right: 12, bottom: 12),
//                     child: TextButton(
//                       onPressed: () {},
//                       style: TextButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3), minimumSize: const Size(50, 30), backgroundColor: Colors.white),
//                       child: Text(
//                         price,
//                         style: const TextStyle(fontSize: 16, color: Colors.black),
//                       ),
//                     ),
//                   ))
//             ],
//           ),
//         ));
//   }
// }
//
// class FAppBar extends SliverAppBar {
//   final AutoScrollController scrollController;
//   final TabController tabController;
//   final void Function(int index) onTap;
//   final PageData data;
//   final BuildContext context;
//
//   FAppBar({
//     required this.onTap,
//     required this.tabController,
//     required this.scrollController,
//     required this.data,
//     required this.context,
//   }) : super(elevation: 4.0, pinned: true, forceElevated: true);
//
//   @override
//   PreferredSizeWidget? get bottom {
//     return PreferredSize(
//         preferredSize: const Size.fromHeight(double.infinity),
//         child: Stack(
//           children: [
//             Align(
//               alignment: Alignment.centerRight,
//               child: Container(
//                 height: 100,
//                 width: 100,
//                 decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.black, Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
//               ),
//             ),
//             const Align(alignment: Alignment.centerLeft),
//             TabBar(
//               isScrollable: false,
//               labelPadding: const EdgeInsets.symmetric(horizontal: 10),
//               controller: tabController,
//               tabs: data.categories.map((e) {
//                 return Tab(text: e.title);
//               }).toList(),
//               onTap: onTap,
//             ),
//           ],
//         ));
//   }
// }
//
// //------
// class ExampleData {
//   ExampleData._internal();
//
//   static Future<PageData> fetchDataFromAPI() async {
//     final url = Uri.parse('http://192.168.0.219/api/v1/catalog/products');
//     final response = await http.get(url, headers: {
//       'Accept': 'application/json',
//     });
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataResponse = json.decode(response.body);
//       return dataFromAPI(dataResponse['data']);
//     } else {
//       throw Exception('Failed to load data from API');
//     }
//   }
//
//   static PageData dataFromAPI(List<dynamic> categoriesData) {
//     List<Category> categories = categoriesData.map((categoryData) {
//       return Category(
//         title: categoryData['title'],
//         headerWidget: _HeaderListWidget(
//           description: categoryData['description'] ?? '',
//           isHotSale: categoryData['isHotSale'] ?? false,
//           isNewSale: categoryData['isNewSale'] ?? false,
//           name: categoryData['name'] ?? '',
//           price: categoryData['price'] ?? '',
//           urlImage: categoryData['urlImage'] ?? '',
//         ),
//         foods: (categoryData['foods'] as List).map((foodData) {
//           return Food(
//             name: foodData['name'],
//             description: foodData['description'],
//             price: foodData['price'],
//             imageUrl: foodData['imageUrl'],
//             isHotSale: foodData['isHotSale'],
//             isNewSale: foodData['isNewSale'],
//             count: foodData['count'],
//           );
//         }).toList(),
//       );
//     }).toList();
//
//     return PageData(categories: categories);
//   }
//
//   static List<String> images = [
//     "https://d1sag4ddilekf6.cloudfront.net/compressed/items/6-CYXCTZAEEEECJE-CZAYA3CERF5ETJ/photo/b44c9b4be5044923b3f5b8f8f6e7e55b_1581506444759847068.jpg",
//     "https://d1sag4ddilekf6.cloudfront.net/compressed/items/6-CY21EXXWSEV2E2-CZKKV8MFGPUTMA/photo/321adfd29ded4d9eae3488848ecfbb05_1592997965388846905.jpg",
//     "https://d1sag4ddilekf6.cloudfront.net/compressed/items/6-CY4ETPUKCCCYTX-CZAYA3BKLEN2KE/photo/8d2d5939ec5a42269a0d8ec3c0a97e44_1581506429557055566.jpg",
//     "https://d1sag4ddilekf6.cloudfront.net/item/6-CY21EXXWUFW1CN-CZAYA25ZSEUJV6/photos/c3f51cd36f2344e28abae3a91b94ef9b_1581506376835073709.jpg",
//     "https://d1sag4ddilekf6.cloudfront.net/compressed/items/6-CZADR6NJMB3UL6-CZADR6UYL65GSE/photo/d4e13ca45a4747b78364dcf643095124_1580377235610503360.jpg",
//   ];
//
//   static PageData data = PageData(
//     categories: [
//       category1,
//       category2,
//       category3,
//       category4,
//     ],
//   );
//
//   static Category category1 = Category(
//     title: "Pizza",
//     headerWidget: const _HeaderListWidget(
//       description: 'adsadwadasdawd',
//       isHotSale: false,
//       isNewSale: true,
//       name: 'adawdas awd ad ',
//       price: 'from 1200 T',
//       urlImage: 'asset',
//     ),
//     foods: [],
//   );
//
//   static Category category2 = Category(
//     title: "Tomak",
//     headerWidget: const _HeaderListWidget(
//       description: 'adsadwadasdawd',
//       isHotSale: false,
//       isNewSale: true,
//       name: 'adawdas awd ad ',
//       price: 'from 1200 T',
//       urlImage: 'asset',
//     ),
//     foods: List.generate(
//       6,
//           (index) {
//         return Food(
//           name: "Kakayata Vkus",
//           description: "Descp and human from aslkdfje czsjdcn scafakjdsfwjefsajhdbfwa efkjsad fawe fasjdbfbwen fasdfearfsadf cweqf casd fsr fse dv werv",
//           price: "\$1.90",
//           imageUrl: images[index % images.length],
//           isHotSale: true,
//           isNewSale: false,
//           count: 0,
//         );
//       },
//     ),
//   );
//
//   static Category category3 = Category(
//     title: "Coffee",
//     headerWidget: const _HeaderListWidget(
//       description: 'adsadwadasdawd',
//       isHotSale: true,
//       isNewSale: false,
//       name: 'adawdas awd ad ',
//       price: 'from 1200 T',
//       urlImage: 'asset',
//     ),
//     foods: List.generate(
//       6,
//           (index) {
//         return Food(
//           name: "WAhahaah dsc dos",
//           description: "From wthe disney mn pls waafahahah dscsdc echzjsc vadhc sdnc vsejr vsd cvksej vse",
//           price: "\$1.90",
//           imageUrl: images[index % images.length],
//           isHotSale: false,
//           isNewSale: true,
//           count: 1,
//         );
//       },
//     ),
//   );
//
//   static Category category4 = Category(
//     title: "SSS",
//     headerWidget: const _HeaderListWidget(
//       description: 'adsadwadasdawd',
//       isHotSale: true,
//       isNewSale: false,
//       name: 'adawdas awd ad ',
//       price: 'from 1200 T',
//       urlImage: 'asset',
//     ),
//     foods: List.generate(
//       6,
//           (index) {
//         return Food(
//           name: "SSS",
//           description: "EDAAAAAAAAAAAAAAAAAAAAAAAAAAAA PROMO",
//           price: "\$1.90",
//           imageUrl: images[index % images.length],
//           isHotSale: true,
//           isNewSale: false,
//           count: 1,
//           // isNewSale: index == 3 ? true : false,
//         );
//       },
//     ),
//   );
// }
//
// class PageData {
//   List<Category> categories;
//
//   PageData({
//     required this.categories,
//   });
// }
//
// class Category {
//   String title;
//   Widget? headerWidget;
//   List<Food> foods;
//
//   Category({
//     required this.title,
//     required this.headerWidget,
//     required this.foods,
//   });
// }
//
// class Food {
//   String name;
//   String description;
//   String price;
//   String imageUrl;
//   bool isHotSale;
//   bool isNewSale;
//   int count;
//
//   Food({
//     required this.name,
//     required this.description,
//     required this.price,
//     required this.imageUrl,
//     required this.isHotSale,
//     required this.isNewSale,
//     required this.count,
//   });
// }
//
//

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:isar/isar.dart';
import 'package:ken_dala/model/product.dart';
import 'package:ken_dala/view/widgets/main_appbar.dart';
import 'package:ken_dala/view/widgets/main_history.dart';
import 'package:ken_dala/view/widgets/main_list_widget.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:http/http.dart' as http;
import 'package:skeletonizer/skeletonizer.dart';

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
    // if (isLoading) {
    //   return const Scaffold(
    //     body: Center(child: CircularProgressIndicator()),
    //   );
    // }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F4),
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
                  const SliverToBoxAdapter(child: MainListWidget()),
                  isLoading
                      ? SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        // Skeletonizer(
                        //   child: TabBar(
                        //     splashFactory: NoSplash.splashFactory,
                        //     physics: const NeverScrollableScrollPhysics(),
                        //     isScrollable: true,
                        //     controller: TabController(length: 3, vsync: this),
                        //     labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                        //     tabAlignment: TabAlignment.start,
                        //     labelColor: Colors.black,
                        //     unselectedLabelColor: Colors.grey,
                        //     indicatorColor: Colors.transparent,
                        //     dividerColor: Colors.transparent,
                        //     tabs: List.generate(
                        //       4,
                        //       (index) => Tab(child: Bone.square(size: 100, borderRadius: BorderRadius.circular(10))),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(height: 20),

                        const Skeletonizer.zone(
                          child: ListTile(
                            leading: Bone.circle(size: 48),
                            title: Bone.text(words: 2),
                            subtitle: Bone.text(),
                            trailing: Bone.icon(),
                          ),
                        ),

                        SizedBox(height: 10),
                        const Skeletonizer.zone(
                          child: ListTile(
                            leading: Bone.circle(size: 48),
                            title: Bone.text(words: 2),
                            subtitle: Bone.text(),
                            trailing: Bone.icon(),
                          ),
                        ),

                        SizedBox(height: 10),
                        const Skeletonizer.zone(
                          child: ListTile(
                            leading: Bone.circle(size: 48),
                            title: Bone.text(words: 2),
                            subtitle: Bone.text(),
                            trailing: Bone.icon(),
                          ),
                        ),

                        SizedBox(height: 10),
                        const Skeletonizer.zone(
                          child: ListTile(
                            leading: Bone.circle(size: 48),
                            title: Bone.text(words: 2),
                            subtitle: Bone.text(),
                            trailing: Bone.icon(),
                          ),
                        ),
                      ],
                    ),
                  )
                      : SliverToBoxAdapter(
                      child: Column(
                        children: [
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
                      )),
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
                    color: Colors.lightBlue,
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
                    color: Colors.lightBlue,
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
  final _tabBar;

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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(food.imageUrl, width: 120, height: 120, fit: BoxFit.cover),
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
                  Text(
                    '${food.price} T',
                    style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
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
    final url = Uri.parse('http://192.168.0.219/api/v1/catalog/products');
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

  Food({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });
}

class ProductService {
  final Isar isar;

  ProductService(this.isar);

  Future<List<Product>> getAllProducts() async {
    return await isar.products.where().findAll();
  }
}
