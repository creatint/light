import 'package:flutter/material.dart';

class TextIndicator extends StatefulWidget {
  @override
  _TextIndicatorState createState() => new _TextIndicatorState();
}

class _TextIndicatorState extends State<TextIndicator>
    with TickerProviderStateMixin {
  Animation<int> animation;
  AnimationController controller;

  Widget childBuilder(int value) {
    String text = '加载中';
    for (int i = 0; i < value; i++) {
      text += '.';
    }
    return new Text(text,
        style: new TextStyle(color: Colors.white70, fontSize: 20.0));
  }

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
        vsync: this, duration: const Duration(seconds: 2));
    animation = new StepTween(begin: 0, end: 4).animate(controller)
    .. addStatusListener((status){
      if (status == AnimationStatus.completed) {
        controller.reset();
        controller.forward();
      }
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, _) {
          return childBuilder(animation.value);
        });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
