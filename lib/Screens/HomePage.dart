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
  int currentCategory = 0;
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
            return PageView.builder(
              controller: _pageController,
              itemCount: categoriesList.length + 1,
              // ignore: missing_return
              itemBuilder: (context, int index) {
                if (index == 0) {
                  return _buildFirstPage();
                } else if (categoriesList.length >= index) {
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
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
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
                      data['id'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 34,
                          color: Colors.white),
                    ),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(20.0),
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
