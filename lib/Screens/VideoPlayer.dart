import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Video extends StatefulWidget {
  final String url, credits, source;

  Video({this.url, this.credits, this.source});

  @override
  _VideoState createState() => _VideoState(this.url, this.credits, this.source);
}

class _VideoState extends State<Video> with SingleTickerProviderStateMixin {
  String url, credits, source;
  AnimationController _animationController;
  bool isPlaying = false;

  _VideoState(this.url, this.credits, this.source);

  VideoPlayerController _playerController;
  VoidCallback listener;
  Stream video;
  final Firestore database = Firestore.instance;

  @override
  void initState() {
    super.initState();
    _getVideo();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    listener = () {
      if (this.mounted) {}
    };
  }

  @override
  void deactivate() {
    _playerController.setVolume(0.0);
    _playerController.removeListener(listener);
    super.deactivate();
  }

  @override
  void dispose() {
    _playerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Stream _getVideo() {
    Query query = database.collection("Videos");
    video =
        query.snapshots().map((list) => list.documents.map((doc) => doc.data));
    return video;
  }

  void createVideo() {
    if (_playerController == null) {
      _playerController = VideoPlayerController.network(url)
        ..addListener(listener)
        ..setVolume(1.0)
        ..initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[420],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: (_playerController != null)
                ? VideoPlayer(_playerController)
                : Container(),
          ),
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FloatingActionButton(
                child: AnimatedIcon(
                  progress: _animationController,
                  icon: AnimatedIcons.play_pause,
                ),
                onPressed: () {
                  setState(() {
                    isPlaying = !isPlaying;
                  });
                  isPlaying
                      ? _animationController.forward()
                      : _animationController.reverse();
                  createVideo();
                  isPlaying
                      ? _playerController.play()
                      : _playerController.pause();
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Credits",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  child: Image.network(source),
                  radius: 30,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  "-  " + credits,
                  style: TextStyle(fontSize: 20),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
