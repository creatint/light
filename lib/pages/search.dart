import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController controller = new TextEditingController();

  void handleSubmit(String text) {
    print('handleSubmit');
  }

  void handleChange(String text) {
    print('handleChange');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new TextField(
          controller: controller,
          style: new TextStyle(color: Colors.white70, fontSize: 18.0),
          onSubmitted: handleSubmit,
          onChanged: handleChange,
          decoration: new InputDecoration(
            hintText: 'Search books',
            hintStyle: new TextStyle(color: Colors.white30),
            border: InputBorder.none
          ),
        ),
      ),
      body: new Center(
        child: new Text('search'),
      ),
    );
  }
}
