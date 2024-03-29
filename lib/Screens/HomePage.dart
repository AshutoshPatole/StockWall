import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stockwall/Screens/VideoPlayer.dart';
import 'package:stockwall/Screens/WallpaperScreen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  PageController _pageController = new PageController(viewportFraction: 0.85);
  int currentCategory = 0, animateToPageIndex, maximumAnimateToPageIndex;
  bool maximumPageReached = false;
  Stream categories, video;
  final Firestore database = Firestore.instance;
  String url = "";
  String whichIsSelected = "Image";

  @override
  void initState() {
    super.initState();
    whichIsSelected == "Image" ? _getCategories() : _getVideo();
    print(whichIsSelected);
    _pageController.addListener(() {
      int nextCategory = _pageController.page.round();
      if (currentCategory != nextCategory) {
        setState(() {
          currentCategory = nextCategory;
        });
      }
    });
  }

  Stream _getCategories() {
    Query query = database.collection("Categories");
    categories =
        query.snapshots().map((list) => list.documents.map((doc) => doc.data));
    return categories;
  }

  Stream _getVideo() {
    Query query = database.collection("Videos");
    video =
        query.snapshots().map((list) => list.documents.map((doc) => doc.data));
    return video;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[420],
      body: StreamBuilder(
        stream: whichIsSelected == "Image" ? categories : video,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List categoriesList;
            categoriesList = snapshot.data.toList();
            maximumAnimateToPageIndex = categoriesList.length;
            return PageView.builder(
              controller: _pageController,
              itemCount: categoriesList.length + 1,
              // ignore: missing_return
              itemBuilder: (context, int index) {
                if (index == 0) {
                  return _buildFirstPage();
                } else if (categoriesList.length >= index) {
                  animateToPageIndex = index;
                  bool active = index == currentCategory;
                  return _categoryPage(categoriesList[index - 1], active);
                }
              },
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  _categoryPage(Map data, bool active) {
    final double top1 = active ? 100 : 200;
    String imageID = data['id'];
    String videoNumber = data['number'];
    String videoDate = data['date'];
    String videoTitle = data['title'];
    return GestureDetector(
      onTap: () {
        url = data['image'];
        String id = data['id'];
        String credits = data['credits'];
        String source = data['source'];
        whichIsSelected == "Image"
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WallPapers(
                    id: id,
                  ),
                ),
              ) //Navigator.push()
            : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Video(
                    url: url,
                    credits: credits,
                    source: source,
                  ),
                ),
              );
      },
      child: AnimatedContainer(
        curve: Curves.easeOutQuint,
        duration: Duration(milliseconds: 500),
        margin: EdgeInsets.only(top: top1, bottom: 50, right: 10),
        decoration: BoxDecoration(
          color: Colors.grey[420],
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
                color: Colors.grey[500],
                offset: Offset(6.0, 6.0),
                blurRadius: 10.0,
                spreadRadius: 1.0),
            BoxShadow(
                color: Colors.white,
                offset: Offset(-6.0, -6.0),
                blurRadius: 10.0,
                spreadRadius: 1.0),
          ],
        ),
        child: whichIsSelected == "Image"
            ? Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        image: DecorationImage(
                            image: NetworkImage(
                              data['image'],
                            ),
                            fit: BoxFit.cover),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          imageID,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 34,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        size: 40,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        maximumPageReached = false;
                        _pageController.animateToPage(0,
                            duration: Duration(milliseconds: 1800),
                            curve: Curves.easeIn);
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(
                        maximumPageReached ? Icons.clear : Icons.arrow_forward,
                        size: 40,
                        color: maximumPageReached ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        if (animateToPageIndex + 4 <=
                            maximumAnimateToPageIndex) {
                          maximumPageReached = false;
                          _pageController.animateToPage(animateToPageIndex + 4,
                              duration: Duration(milliseconds: 1800),
                              curve: Curves.easeIn);
                        } else {
                          maximumPageReached = true;
                        }
                      },
                    ),
                  )
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              videoNumber ?? " Loading..",
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              videoDate ?? " Loading..",
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              child: Text(
                                videoTitle ?? " Loading..",
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFirstPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Category",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        RaisedButton(
          onPressed: () {
            setState(() {
              whichIsSelected = "Image";
            });
          },
          child: Text("Images"),
          color: Colors.purple,
          textColor: Colors.white,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        RaisedButton(
          onPressed: () {
            _getVideo();
            setState(() {
              whichIsSelected = "Video";
            });
          },
          child: Text("Videos"),
          color: Colors.purple,
          textColor: Colors.white,
        )
      ],
    );
  }
}
