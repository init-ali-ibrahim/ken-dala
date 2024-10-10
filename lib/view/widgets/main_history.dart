import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';

class MainHistory extends StatefulWidget {
  const MainHistory({super.key});

  @override
  State<MainHistory> createState() => _MainHistoryState();
}

class _MainHistoryState extends State<MainHistory> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 125,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MoreStories()));
              },
              child: SizedBox(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/coffee',
                        height: 120,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // const Positioned(
                    //   bottom: 5,
                    //   child: Padding(padding: EdgeInsets.all(5), child: Text('dara')),
                    // )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MoreStories()));
              },
              child: SizedBox(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/coffee3',
                        height: 120,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // const Positioned(
                    //   bottom: 5,
                    //   child: Padding(padding: EdgeInsets.all(5), child: Text('dara')),
                    // )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MoreStories()));
              },
              child: SizedBox(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/coffee2',
                        height: 120,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // const Positioned(
                    //   bottom: 5,
                    //   child: Padding(padding: EdgeInsets.all(5), child: Text('dara')),
                    // )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MoreStories()));
              },
              child: SizedBox(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/coffee1',
                        height: 120,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // const Positioned(
                    //   bottom: 5,
                    //   child: Padding(padding: EdgeInsets.all(5), child: Text('dara')),
                    // )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MoreStories()));
              },
              child: SizedBox(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/coffee',
                        height: 120,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // const Positioned(
                    //   bottom: 5,
                    //   child: Padding(padding: EdgeInsets.all(5), child: Text('dara')),
                    // )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 15),
          ],
        ));
  }
}

class MoreStories extends StatefulWidget {
  @override
  _MoreStoriesState createState() => _MoreStoriesState();
}

class _MoreStoriesState extends State<MoreStories> {
  final storyController = StoryController();

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        StoryView(
          storyItems: [
            StoryItem.text(
              title: "Privet ;)",
              backgroundColor: Colors.blue,
            ),
            StoryItem.pageImage(
              url: "https://image.ibb.co/cU4WGx/Omotuo-Groundnut-Soup-braperucci-com-1.jpg",
              caption: const Text(
                "Still sampling",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              controller: storyController,
            ),
            StoryItem.pageImage(
                url: "https://media.giphy.com/media/5GoVLqeAOo6PK/giphy.gif",
                caption: const Text(
                  "Working with gifs",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                controller: storyController),
            StoryItem.pageImage(
              url: "https://media.giphy.com/media/XcA8krYsrEAYXKf4UQ/giphy.gif",
              caption: const Text(
                "Hello, from the other side",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              controller: storyController,
            ),
          ],
          onStoryShow: (storyItem, index) {
            print("Showing a story");
          },
          onComplete: () {
            Navigator.pop(context);
          },
          progressPosition: ProgressPosition.top,
          repeat: false,
          controller: storyController,
        ),
        Positioned(
          top: kToolbarHeight * 1.25,
          right: 20,
          child: IconButton(
              style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.3), padding: const EdgeInsets.all(0)),
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.close,
                size: 20,
                color: Colors.black,
              )),
        )
      ],
    ));
  }
}
