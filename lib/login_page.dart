import 'package:clienterest/yolo/upload_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: LoginForm(authService: _authService),
    );
  }
}

class LoginForm extends StatefulWidget {
  final AuthService authService;

  LoginForm({required this.authService});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isPasswordCompliant(String password, [int minLength = 8]) {
    if (password == '' || password.length < minLength) {
      return false;
    }

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    if (hasUppercase) {
      bool hasDigits = password.contains(RegExp(r'[0-9]'));
      if (hasDigits) {
        bool hasLowercase = password.contains(RegExp(r'[a-z]'));
        if (hasLowercase) {
          bool hasSpecialCharacters =
              password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
          return hasSpecialCharacters;
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () async {
              final String? email = _emailController.text;
              final String? password = _passwordController.text;
              if (_emailController.text != '' &&
                  _passwordController.text != '') {
                final bool _emailValid = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(email!);
                final bool _passValid = isPasswordCompliant(password!, 8);
                if (_emailValid && _passValid) {
                  //Esto es para probar
                  String? token = 'Danieliku';
                  //await widget.authService.login(email!, password!);
                  if (token != null) {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString('token', token);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UploadImageScreen()),
                    );
                  } else {
                    // Manejar error de inicio de sesión aquí
                    print('Error al iniciar sesión');
                  }
                } else {
                  Fluttertoast.showToast(
                      msg:
                          "El correo o contraseña no cumple los estandares minimos",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  _emailController.clear();
                  _passwordController.clear();
                }
              } else {
                Fluttertoast.showToast(
                    msg: "Uno o ambos campos vacios",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
