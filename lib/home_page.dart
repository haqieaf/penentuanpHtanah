// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';

// import 'cameraPage.dart';

// class HomePage extends StatefulWidget {
//   final List<CameraDescription> cameras;

//   const HomePage({Key? key, required this.cameras}) : super(key: key);

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Home')),
//       body: Center(
//         child: ElevatedButton(
//           child: Text('Open Camera'),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => CameraScreen(camera: widget.cameras.first),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }