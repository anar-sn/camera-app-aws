import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  // 1
  final CameraDescription? camera;
  // 2
  final ValueChanged? didProvideImagePath;

  CameraPage({Key? key, this.camera, this.didProvideImagePath})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // 3
    _controller = CameraController(widget.camera!, ResolutionPreset.medium);
    _initializeControllerFuture = _controller?.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          // 4
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(this._controller!);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      // 5
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.camera), onPressed: _takePicture),
    );
  }

  // 6
  void _takePicture() async {
    try {
      await _initializeControllerFuture;

      //final tmpDirectory = await getTemporaryDirectory();
      final tmpDirectory = await getApplicationDocumentsDirectory();
      print('tmpDirectory: ' + tmpDirectory.toString());
      final filePath = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('filePath: ' + filePath);
      final path = join(tmpDirectory.path, filePath);
      print('path: ' + path);

      final imageFile = await _controller?.takePicture();

      print('_takePicture path: ');
      print(path);

      widget.didProvideImagePath!(imageFile!.path);

      //final imageFile = await File('path');
      if (File(imageFile!.path).existsSync())
        print('Image file exists');
      else
        print('Image file does not exist');
    } catch (e) {
      print(e);
    }
  }

  // 7
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
