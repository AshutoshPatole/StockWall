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
  bool isReset = false;

  _VideoState(this.url, this.credits, this.source);

  VideoPlayerController _playerController;
  VoidCallback listener;
  Stream video;
  final Firestore database = Firestore.instance;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    listener = () {
      if (this.mounted) {}
    };
  }

  @override
  void dispose() {
    _playerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void createVideo() {
    if (_playerController == null) {
      _playerController = VideoPlayerController.network(url)
        ..addListener(listener)
        ..setVolume(1.0)
        ..initialize()
        ..play();
    }
  }

  void playPause() {
    isPlaying ? _animationController.forward() : _animationController.reverse();
    createVideo();
    _playerController.setVolume(1.0);
    isPlaying ? _playerController.play() : _playerController.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[420],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: (_playerController != null)
                ? VideoPlayer(_playerController)
                : Container(),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  playPause();
                },
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.06,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Text(
                  "Credits :",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                ),
                CircleAvatar(
                  child: Image.network(source),
                  radius: 10,
                  backgroundColor: Colors.transparent,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  credits,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
