import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<File?> takePicture() async {
  try {
    await _initializeControllerFuture;
    final XFile capturedImage = await _controller.takePicture();

    final Directory? appDirectory = await getExternalStorageDirectory();
    final String storagePath = '${appDirectory?.path}/Pictures';
    await Directory(storagePath).create(recursive: true);

    final String fileName = '${DateTime.now().toString()}.jpg'; // Sertakan timestamp dalam nama file
    final String filePath = path.join(storagePath, fileName);

    final File file = File(filePath);
    await file.writeAsBytes(await capturedImage.readAsBytes());

    return file;
  } catch (e) {
    print(e);
    return null;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('Camera Page')),
      body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (_, snapshot) =>
              (snapshot.connectionState == ConnectionState.done)
                  ? Stack(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width *
                                  _controller.value.aspectRatio,
                              child: CameraPreview(_controller),
                            ),
                            Container(
                              width: 70,
                              height: 70,
                              margin: EdgeInsets.only(top: 20),
                              child: RaisedButton(
                                  onPressed: () async {
                                    if (!_controller.value.isTakingPicture) {
                                      File? image = await takePicture();
                                      Navigator.pop(context, image);
                                    }
                                  },
                                  shape: CircleBorder(),
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      ),
                    )),
    );
  }
}
