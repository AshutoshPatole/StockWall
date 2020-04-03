import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stockwall/Animation/animation.dart';
import 'package:stockwall/Screens/ViewWallpaper.dart';

class WallPapers extends StatefulWidget {
  final String id;

  WallPapers({this.id});

  @override
  _WallPapersState createState() => _WallPapersState(this.id);
}

class _WallPapersState extends State<WallPapers> {
  PageController _pageController = new PageController(viewportFraction: 0.8);
  Stream wallpapers;
  int currentWallpaper = 0;
  String id;
  final Firestore db = Firestore.instance;

  _WallPapersState(this.id);

  @override
  void initState() {
    super.initState();
    _getWallpapers();

    _pageController.addListener(() {
      int nextWallpaper = _pageController.page.round();
      if (currentWallpaper != nextWallpaper) {
        setState(() {
          currentWallpaper = nextWallpaper;
        });
      }
    });
  }

  Stream _getWallpapers() {
    Query query =
        db.collection("Categories").document(id).collection("wallpapers");
    wallpapers =
        query.snapshots().map((list) => list.documents.map((doc) => doc.data));
    return wallpapers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: DelayAnimation(
              child: StreamBuilder(
                stream: wallpapers,
                initialData: [],
                builder: (context, AsyncSnapshot snap) {
                  List slideList = snap.data.toList();
                  return PageView.builder(
                    physics: ScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    controller: _pageController,
                    itemCount: slideList.length,
                    // ignore: missing_return
                    itemBuilder: (context, int index) {
                      if (slideList.length >= index) {
                        bool active = index == currentWallpaper;
                        return _buildWallpapersPage(slideList[index], active);
                      }
                    },
                  );
                },
              ),
              delay: 500)),
    );
  }

  _buildWallpapersPage(Map data, bool active) {
    final double blur = active ? 10 : 0;
    final double offset = active ? 10 : 0;
    final double top = active ? 100 : 200;
    String link = data['image'];

    return Hero(
      tag: link,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => ViewWallpaper(
                link: link,
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOutQuint,
          margin: EdgeInsets.only(top: top, bottom: 50, right: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(data['image']),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black87,
                blurRadius: blur,
                offset: Offset(offset, offset),
              )
            ],
          ),
        ),
      ),
    );
  }
}
