import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stockwall/Screens/WallpaperScreen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  PageController _pageController = new PageController(viewportFraction: 0.85);
  int currentCategory = 0;

  Stream categories;
  final Firestore database = Firestore.instance;

  @override
  void initState() {
    super.initState();
    _getCategories();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[420],
      body: StreamBuilder(
        stream: categories,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List categoriesList;
            categoriesList = snapshot.data.toList();
            return PageView.builder(
              controller: _pageController,
              itemCount: categoriesList.length,
              // ignore: missing_return
              itemBuilder: (context, int index) {
                if (categoriesList.length >= index) {
                  bool active = index == currentCategory;
                  return _categoryPage(categoriesList[index], active);
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
    String id = data['id'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WallPapers(
                      id: id,
                    )));
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                image: DecorationImage(
                    image: NetworkImage(
                      data['image'],
                    ),
                    fit: BoxFit.cover)),
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
        ),
      ),
    );
  }
}
