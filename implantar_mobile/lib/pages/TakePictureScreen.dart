import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:implantar_mobile/pages/DisplayPictureScreen.dart';
import 'package:implantar_mobile/api/models.dart';
import 'dart:io';

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  final Visita visita;
  final ChecklistItem item;

  const TakePictureScreen({
    Key key,
    @required this.camera,
    @required this.visita,
    @required this.item,
  }) : super(key: key);

  @override
  _TakePictureScreenState createState() =>
      _TakePictureScreenState(visita, item);
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Visita visita;
  ChecklistItem item;
  Future<void> _initializeControllerFuture;

  _TakePictureScreenState(this.visita, this.item);

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.

            String _fileName =
                '${item.id.toString()}_${item.photoVersion.toString()}.png';
            String _path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getApplicationDocumentsDirectory()).path,
              'v_${visita.id.toString()}/',
            );
            /* Cria pasta */
            if (!await Directory(_path).exists()) {
              new Directory(_path).create(recursive: true);
            }
            /* Caso arquivo exista, acrescente nova versao */
            if (await File(_path + _fileName).exists()) {
              int v = item.photoVersion + 1;
              _fileName = '${item.id.toString()}_${v.toString()}.png';
            }
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getApplicationDocumentsDirectory()).path,
              _path + _fileName,
            );

            // Attempt to take a picture and log where it's been saved.
            await _controller.takePicture(path);

            // If the picture was taken, display it on a new screen.
            bool picTaken = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: path,
                  item: item,
                ),
              ),
            );
            if (picTaken) {
              Navigator.pop(context, path);
            } else {
              /* Caso a foto tirada não seja aceita, excluir. */
              File(path).delete();
            }
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}
