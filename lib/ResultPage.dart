import 'dart:convert';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultPage({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Analisis'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Hasil Analisis",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildResultInfo("pH tanah", result['pH']),
            _buildResultInfo("Warna yang cocok", result['matched_color']),
            _buildColorInfo(result['color_info']),
            SizedBox(height: 20),
            Text(
              "Hasil Image Processing",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Image.memory(
              base64Decode(result['segmented_image']),
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            _buildLocationInfo("Latitude", result['latitude']),
            _buildLocationInfo("Longitude", result['longitude']),
          ],
        ),
      ),
    );
  }

  Widget _buildResultInfo(String title, dynamic value) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              value.toString(),
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorInfo(Map<String, dynamic> colorInfo) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Informasi Warna",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildColorDetail("Red", colorInfo['Red']),
                _buildColorDetail("Green", colorInfo['Green']),
                _buildColorDetail("Blue", colorInfo['Blue']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDetail(String title, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.color_lens, size: 30),
        SizedBox(height: 5),
        Text(
          "$title: $value",
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(String title, dynamic value) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              value.toString(),
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
