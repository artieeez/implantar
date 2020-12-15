import 'dart:io';

import 'package:flutter/material.dart';
import 'package:implantar_mobile/api/models.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final ChecklistItem item;

  const DisplayPictureScreen(
      {Key key, @required this.imagePath, @required this.item})
      : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState(item);
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  ChecklistItem item;
  _DisplayPictureScreenState(this.item);
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
          Image.file(File(widget.imagePath)),
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
