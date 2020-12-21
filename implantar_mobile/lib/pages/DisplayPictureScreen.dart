import 'dart:io';

import 'package:flutter/material.dart';
import 'package:implantar_mobile/api/models.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final Item item;

  const DisplayPictureScreen(
      {Key key, @required this.imagePath, @required this.item})
      : super(key: key);

  @override
  _DisplayPictureScreenState createState() =>
      _DisplayPictureScreenState(imagePath, item);
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  String imagePath;
  Item item;
  _DisplayPictureScreenState(this.imagePath, this.item);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Display the Picture')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body: Stack(children: [
          Image.file(File(imagePath)),
          Positioned(
            bottom: 0,
            child: ButtonBar(
              children: [
                RaisedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text('Concluir'),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
