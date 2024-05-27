import 'dart:convert';
import 'package:clienterest/login_page.dart';
import 'package:clienterest/service.dart';
import 'package:clienterest/yolo/upload_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cliente REST - ROVIMATICA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ApiRequestPage(),
      routes:{'/login': (context) => LoginPage()}
    );
  }
}

class ApiRequestPage extends StatefulWidget {
  @override
  _ApiRequestPageState createState() => _ApiRequestPageState();
}

class _ApiRequestPageState extends State<ApiRequestPage> {
  bool isLoading = false;
  var token; 
  // Método para verificar el token en SharedPreferences
  Future<bool> checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Pa pruebas ->
    prefs.clear();
    token = prefs.getString('token');
    return token != null;
  }

  Future<void> clearPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void waitXSeconds(int x) {
    Future.delayed(Duration(seconds: x), () {
      print('Delay of $x seconds completed.');
    });
  }

  // Método para validar el token con la API
  Future<bool> validateToken(String token) async {
    var checker = await AuthService().checkingToken(token);

    if(checker){
      return true;
    }else{
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    //Limpio el token para las pruebas
    //clearPrefs();
    // Verificar si el token existe al iniciar la página

    checkToken().then((tokenExists) {
      if (tokenExists) {
        setState(() {
          isLoading = true;
        });
        waitXSeconds(5);
        SharedPreferences.getInstance().then((prefs) {
          String? token = prefs.getString('token');
          validateToken(token!).then((isValid) {
            setState(() {
              isLoading = false;
            });
            if (isValid) {
              // Si el token es válido, navegar a la pantalla de imágenes
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const UploadImageScreen()),
              );
            } else {
              // Si el token no es válido, navegar a la pantalla de inicio de sesión
              setState(() {
                isLoading = false;
              });
              prefs.clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            }
          }).catchError((error) {
            // En caso de error al validar el token, redirigir al inicio de sesión
            setState(() {
              isLoading = false;
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          });
        });
      } else {
        // Si el token no existe, redirigir al inicio de sesión
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Request Demo'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Text('Verifying token...'),
      ),
    );
  }
}
