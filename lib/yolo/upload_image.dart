import 'dart:convert';
import 'dart:io';
// ignore: unused_import
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:clienterest/service.dart';
import 'package:clienterest/yolo/Detection.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bounding_box_painter.dart';

class UploadImageScreen extends StatefulWidget {
  final String? token;

  const UploadImageScreen({Key? key, this.token}) : super(key: key);

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

  class _UploadImageScreenState extends State<UploadImageScreen> {
  File? image;
  String? email;
  bool showSpinner = false;
  List<Detection> detections = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeTokenAndEmail();
  }

  Future<void> _initializeTokenAndEmail() async {
    // Obtener el token de SharedPreferences o del widget
    String? token = widget.token;
    if (token == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
    }

    // Obtener el email usando el token
    if (token != null) {
      try {
        String userEmail = await AuthService().whoami(token);
        setState(() {
          email = userEmail;
        });
      } catch (e) {
        print('Error al obtener el email: $e');
        // Manejar error, quizás redirigir al login
      }
    } else {
      print('Token no disponible');
      // Manejar el caso en que el token no esté disponible
    }
  }

  Future<void> getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    } else {
      print('No ha seleccionado ninguna imagen');
    }
  }

  Future<void> uploadImage() async {
    if (image == null) return;
    setState(() {
      showSpinner = true;
    });

    Uint8List bytes = await image!.readAsBytes();
    var uri = Uri.parse('http://192.168.1.154:5001/procesarImg');
    var response = await http.post(uri, body: bytes);
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        showSpinner = false;
      });
      print('Imagen subida correctamente');

      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      Map<String, dynamic> detectionsJson = jsonResponse['Detections'];
      Detection detection = Detection.fromJson(detectionsJson);
      setState(() {
        detections.add(detection);
      });
    } else {
      print('Fallo en la subida');
      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Subir imagen'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: email != null
                    ? Text(
                        email!,
                        style: TextStyle(fontSize: 16),
                      )
                    : CircularProgressIndicator(),
              ),
            ),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                logout();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    getImage();
                    detections.clear();
                  },
                  child: Container(
                    height: 300,
                    width: 300,
                    child: image == null
                        ? const Center(
                            child: Text('Seleccione una imagen'),
                          )
                        : Image.file(
                            File(image!.path).absolute,
                            height: 300,
                            width: 300,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SizedBox(height: 150),
                GestureDetector(
                  onTap: () {
                    uploadImage();
                  },
                  child: Container(
                    height: 50,
                    width: 200,
                    color: Colors.green,
                    child: Center(child: Text('Subir imagen')),
                  ),
                ),
                if (detections.isNotEmpty)
                  Container(
                    height: 800,
                    width: 800,
                    child: Stack(
                      children: [
                        Image.file(
                          File(image!.path).absolute,
                          height: 800,
                          width: 800,
                          fit: BoxFit.cover,
                        ),
                        CustomPaint(
                          size: Size.square(800),
                          painter: BoundingBoxPainter(detections),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void logout() {
    // TODO logout
  }
}
