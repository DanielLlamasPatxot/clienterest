import 'dart:convert';
import 'dart:io';
// ignore: unused_import
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:clienterest/yolo/Detection.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'bounding_box_painter.dart';

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({Key? key}) : super(key: key);

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

//Clase que se encarga de subir imagenes a la API
class _UploadImageScreenState extends State<UploadImageScreen> {
  File? image;
  final _picker = ImagePicker();
  //booleano que muestra el spinner de carga mientras se sube a la API
  bool showSpinner = false;
  List<Detection> detections = [];

  //Método que recoge la imagen de la galería y la muestra por pantalla.
  Future getImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      image = File(pickedFile.path);
      setState(() {});
    } else {
      print('No ha seleccionado ninguna imagen');
    }
  }

  // Método que toma la imagen que se muestra en pantalla y la sube a la API
  Future<void> uploadImage() async {
    setState(() {
      showSpinner = true;
    });

    Uint8List bytes = await image!.readAsBytes();
    //print(bytes.toString());
    var uri = Uri.parse('http://192.168.1.154:5001/procesarImg');
    var response = await http.post(uri, body: bytes);
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        showSpinner = false;
      });
      print('Imagen subida correctamente');

      // Convertir la respuesta de la API a una cadena JSON
      String responseBody = utf8.decode(response.bodyBytes);

      // Parsear la cadena JSON a un mapa de tipo <String, dynamic>
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

      // Extraigo 'Detections' del JSON
      Map<String, dynamic> detectionsJson = jsonResponse['Detections'];

      // Convertir el 'Detections' a la clase creada por mi
      Detection detection = Detection.fromJson(detectionsJson);

      // Añado a la lista
      detections.add(detection);
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
        ),
        body: SingleChildScrollView(
          child: Center(
            // Alinea la columna al centro
            child: Column(
              mainAxisAlignment: MainAxisAlignment
                  .center, // Alinea los elementos al centro verticalmente
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
                        // Mostrar la imagen
                        Image.file(
                          File(image!.path).absolute,
                          height: 800,
                          width: 800,
                          fit: BoxFit.cover,
                        ),
                        // Dibujar detecciones sobre la imagen
                        CustomPaint(
                          //Ajusto aquí al mismo tamaño que el container para que no descuadren
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
}
