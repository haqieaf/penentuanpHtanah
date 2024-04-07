import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/retry.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:rekomendasinutrisi/HistoryPage.dart';
import 'package:rekomendasinutrisi/resultpage.dart';
import 'cameraPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ' ',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.brown,
        fontFamily: 'Roboto',
      ),
      home: MyHomePage(camera: camera),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final CameraDescription camera;

  const MyHomePage({Key? key, required this.camera}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _imageFile;
  List<Map<String, dynamic>> _history = [];
  String? message = "";
  late final CameraDescription camera;

  Future<void> _pickImage() async {
    try {
      final imagePicker = ImagePicker();
      final image = await imagePicker.getImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      print('Error saat memilih gambar dari galeri: $e');
    }
  }

  Future<void> _processImage() async {
    if (_imageFile == null) {
      return;
    }

    var locationPermissionStatus = await Permission.location.status;
    if (locationPermissionStatus != PermissionStatus.granted) {
      await Permission.location.request();
      // Periksa kembali setelah pengguna memberikan izin
      locationPermissionStatus = await Permission.location.status;
      if (locationPermissionStatus != PermissionStatus.granted) {
        print('User denied location permission.');
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final request = http.MultipartRequest(
        "POST",
        Uri.parse('http://192.168.1.8:5000/process_image'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', _imageFile!.path),
      );
      request.fields['latitude'] = position.latitude.toString();
      request.fields['longitude'] = position.longitude.toString();
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseText = await response.stream.bytesToString();
        Map<String, dynamic> result = json.decode(responseText);
        _showResultPage(result);
        (result);
        DateTime currentTime = DateTime.now();
        result['timestamp'] = currentTime.toString();
        _history.add(result);
      } else {
        print('Image not uploaded');
      }
    } catch (e) {
      print('Error getting Location: $e');
    }
  }

  void _showResultPage(Map<String, dynamic> result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('pH Analyzer'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image Container
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: (_imageFile != null)
                    ? Image.file(_imageFile!)
                    : Center(
                        child: Text(
                          'No Image Selected',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
              ),
            ),
            // Camera Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                fixedSize: Size(150, 50),
              ),
              onPressed: () async {
                _imageFile = await Navigator.push<File>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraScreen(camera: widget.camera),
                  ),
                );
                setState(() {});
              },
              child: Text('Take Photo'),
            ),
            SizedBox(height: 10),
            // Open Gallery Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                fixedSize: Size(150, 50),
              ),
              onPressed: _pickImage,
              child: Text('Open Gallery'),
            ),
            SizedBox(height: 10),
            // Generate Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                fixedSize: Size(150, 50),
              ),
              onPressed: _processImage,
              child: Text('Generate'),
            ),
            SizedBox(height: 10),
            // History Button
            OutlinedButton(
              onPressed: () {
                // Navigate to history page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(history: _history),
                  ),
                );
              },
              child: Text('History'),
            ),
          ],
        ),
      ),
    );
  }
}
