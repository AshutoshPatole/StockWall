import 'dart:async';

import 'package:flutter/material.dart';

class DelayAnimation extends StatefulWidget {
  final Widget child;
  final int delay;

  DelayAnimation({@required this.child, @required this.delay});

  @override
  _DelayAnimationState createState() => _DelayAnimationState();
}

class _DelayAnimationState extends State<DelayAnimation>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    final curve =
        CurvedAnimation(curve: Curves.easeOutQuint, parent: _controller);
    _offset = Tween<Offset>(begin: const Offset(0.0, 0.35), end: Offset.zero)
        .animate(curve);

    if (widget.delay == null) {
      _controller.forward();
    } else {
      Timer(Duration(milliseconds: widget.delay), () {
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
      opacity: _controller,
    );
  }
}
