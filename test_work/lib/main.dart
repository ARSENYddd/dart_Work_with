import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Демо загрузки с камеры',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraUploadScreen(),
    );
  }
}

class CameraUploadScreen extends StatefulWidget {
  @override
  _CameraUploadScreenState createState() => _CameraUploadScreenState();
}

class _CameraUploadScreenState extends State<CameraUploadScreen> {
  File? _image;
  final picker = ImagePicker();
  TextEditingController commentController = TextEditingController();

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadData() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    String comment = commentController.text;

    var request = http.MultipartRequest(
        'POST', Uri.parse('https://flutter-sandbox.free.beeceptor.com/upload_photo/'));
    request.fields['comment'] = comment;
    request.fields['latitude'] = position.latitude.toString();
    request.fields['longitude'] = position.longitude.toString();
    request.files.add(await http.MultipartFile.fromPath('photo', _image!.path));

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print('Загружено!');
    } else {
      print('Не удалось загрузить: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Демо загрузки с камеры'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Text('Изображение не выбрано.')
                : Image.file(_image!),
            ElevatedButton(
              onPressed: _getImage,
              child: Text('Сделать фото'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Введите ваш комментарий...',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _image == null ? null : _uploadData,
              child: Text('Отправить данные'),
            ),
          ],
        ),
      ),
    );
  }
}
