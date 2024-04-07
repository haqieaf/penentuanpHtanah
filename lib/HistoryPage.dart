import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const HistoryPage({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Hasil ke-${index + 1}'),
            subtitle: Text('Waktu: ${history[index]['timestamp']}'),
            onTap: () {
              // Tampilkan detail hasil pemrosesan
              _showDetailBottomSheet(context, history[index]);
            },
          );
        },
      ),
    );
  }

  void _showDetailBottomSheet(
      BuildContext context, Map<String, dynamic> result) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 400, // Adjust the height of the BottomSheet as needed
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Hasil Analisis",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "pH tanah adalah ${result['pH']}",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                "Warna yang cocok: ${result['matched_color']}",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                "Informasi Warna:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Red: ${result['color_info']['Red']}",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    "Green: ${result['color_info']['Green']}",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    "Blue: ${result['color_info']['Blue']}",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Hasil Image Processing",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Expanded(
                child: Image.memory(
                  base64Decode(result['segmented_image']),
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Lokasi Pengambilan Gambar:",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                "Latitude: ${result['latitude']}",
                style: TextStyle(fontSize: 15),
              ),
              Text(
                "Longitude: ${result['longitude']}",
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        );
      },
    );
  }
}
