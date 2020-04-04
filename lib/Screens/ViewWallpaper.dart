import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wallpaper_manager/wallpaper_manager.dart';
import 'package:http/http.dart' as http;

class ViewWallpaper extends StatefulWidget {
  final String link;

  ViewWallpaper({this.link});

  @override
  _ViewWallpaperState createState() => _ViewWallpaperState(this.link);
}

class _ViewWallpaperState extends State<ViewWallpaper>
    with TickerProviderStateMixin {
  _ViewWallpaperState(this.link);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String link;
  String result = "Waiting";
  AnimationController _animationController;

  double _containerPaddingLeft = 20.0;
  double _animationValue;
  double _translateX = 0;
  double _translateY = 0;
  double _rotate = 0;
  double _scale = 1;
  bool disposed = false;
  bool show;
  bool sent = false;
  Color _color = Colors.lightBlue;
  Color _colorSending = Colors.black;

  bool downloading = false;
  var filepath;

  _setWallpaper() async {
    String url = link;
    int location = WallpaperManager
        .HOME_SCREEN; // or location = WallpaperManager.LOCK_SCREEN;

    var file = await DefaultCacheManager().getSingleFile(url);

    await WallpaperManager.setWallpaperFromFile(file.path, location);
  }

  @override
  void initState() {
    super.initState();
    askForPermissions();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1300));
    show = true;
    _animationController.addListener(() {
      setState(() {
        show = false;
        _animationValue = _animationController.value;
        if (_animationValue >= 0.2 && _animationValue < 0.4) {
          _containerPaddingLeft = 100.0;
          _color = Colors.green[800];
        } else if (_animationValue >= 0.4 && _animationValue <= 0.5) {
          _translateX = 80.0;
          _rotate = -20.0;
          _scale = 0.2;
        } else if (_animationValue >= 0.5 && _animationValue <= 0.6) {
          _translateX = 90.0;
          _colorSending = Colors.white;
          _rotate = -20.0;
          _scale = 0.1;
        } else if (_animationValue >= 0.6 && _animationValue <= 0.8) {
          _translateY = -20.0;
        } else if (_animationValue >= 0.81) {
          _containerPaddingLeft = 20.0;
          sent = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> downloadfile() async {
    try {
      downloading = true;
      var response = await http.get(link);
      filepath = await ImagePickerSaver.saveFile(fileData: response.bodyBytes);
    } catch (e) {
      print(e);
    }

    setState(() {
      downloading = false;
    });
  }

  Future askForPermissions() async {
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Hero(
            tag: link,
            child: Image.network(
              link,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: () {
                          _animationController.forward();
                          downloadfile();
                        },
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            color: _color,
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          padding: EdgeInsets.only(
                              left: _containerPaddingLeft,
                              right: 20.0,
                              top: 10.0,
                              bottom: 10.0),
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              (!sent)
                                  ? AnimatedContainer(
                                      duration: Duration(milliseconds: 400),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Icon(
                                          FontAwesomeIcons.fileExport,
                                          size: 20,
                                          color: _colorSending,
                                        ),
                                      ),
                                      curve: Curves.fastOutSlowIn,
                                      transform: Matrix4.translationValues(
                                          _translateX, _translateY, 0)
                                        ..rotateZ(_rotate)
                                        ..scale(_scale),
                                    )
                                  : Container(),
                              AnimatedSize(
                                vsync: this,
                                duration: Duration(milliseconds: 600),
                                child:
                                    show ? SizedBox(width: 10.0) : Container(),
                              ),
                              AnimatedSize(
                                vsync: this,
                                duration: Duration(milliseconds: 200),
                                child: show ? Text("Download") : Container(),
                              ),
                              AnimatedSize(
                                vsync: this,
                                duration: Duration(milliseconds: 200),
                                child: sent
                                    ? Icon(
                                        Icons.done,
                                        color: Colors.white,
                                      )
                                    : Container(),
                              ),
                              AnimatedSize(
                                vsync: this,
                                alignment: Alignment.topLeft,
                                duration: Duration(milliseconds: 600),
                                child:
                                    sent ? SizedBox(width: 10.0) : Container(),
                              ),
                              AnimatedSize(
                                vsync: this,
                                duration: Duration(milliseconds: 200),
                                child: sent
                                    ? Text(
                                        "Done",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Container(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _setWallpaper();
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            content: Text("Wallpaper Set Successfully !"),
                            duration: Duration(milliseconds: 1500),
                            backgroundColor: Colors.lightBlue,
                            elevation: 1,
                          ),
                        );
                      },
                      child: Container(
                        height: 45,
                        width: 125,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFA7BFE8),
                              blurRadius: 21,
                              spreadRadius: -15,
                              offset: Offset(
                                0.0,
                                20.0,
                              ),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Icon(FontAwesomeIcons.image),
                            Text(
                              'Wallpaper',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
