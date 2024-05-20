import 'dart:convert';
import 'dart:math';
import 'package:built_value/json_object.dart';
import 'package:http/http.dart' as http;
import 'package:one_of/one_of.dart';
import 'package:one_of/src/oneOf/one_of_base.dart';
import 'package:ory_client/ory_client.dart';




class AuthService {
  
  final api = OryClient().getFrontendApi();
  //Prueba
  //final apiId = OryClient().getIdentityApi();

  Future<String?> register(String username, String password) async {
 final flow =  await api.createNativeRegistrationFlow();
 print(flow.toString());

 print('Aquí la id${flow.data!.id}');

  
 // Create the payload for the updateRegistrationFlow endpoint
 var body = UpdateRegistrationFlowWithPasswordMethod(
   (b) => b
     ..method = 'password'
     ..password = password
     ..traits = JsonObject({
       'email': username,
     })
 );
   final response = await OryClient().getFrontendApi().updateRegistrationFlow(
   flow: flow.data!.id,
   updateRegistrationFlowBody: UpdateRegistrationFlowBody(
     (b) => b
       ..oneOf = OneOf.fromValue1(value: body)
   ),
 );
  print(response.data!.sessionToken);
  return response.data!.sessionToken;
 }


  Future<String?> login(String username, String password) async {
      var flow = await api.createNativeLoginFlow(returnSessionTokenExchangeCode: true);
  
      var body = UpdateLoginFlowWithPasswordMethod((b) => b
      ..method = 'password'
      ..password = password
      ..identifier = username
  );
      final response = await OryClient().getFrontendApi().updateLoginFlow(flow : flow.data!.id,
       updateLoginFlowBody: UpdateLoginFlowBody((b) => b ..oneOf = OneOf.fromValue1(value: body)));
      print(response.data);
      print('El session Token es: ${response.data!.sessionToken}');
      if (response.statusCode == 200 || response.statusCode == 201) {
      print('Login exitoso');
    } else {
      print('Error al logear: ${response.statusCode}');
    }

      return response.data!.sessionToken;

    
  }
  

  Future<bool> checkingToken(String token) async {
  final api = OryClient().getFrontendApi();
  try {
    final response = await api.toSession(xSessionToken: token);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(response.data!.identity!.recoveryAddresses!.first.value);
      return true;
    } else {
      print('Token no valido');
      return false;
    }
  } catch (e) {
    print('Ocurrió un error: $e');
    return false;
  }
}

  Future<String> whoami(String token) async {
  final api = OryClient().getFrontendApi();
    final response = await api.toSession(xSessionToken: token);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return(response.data!.identity!.recoveryAddresses!.first.value);
    } else {
      print('Token no valido');
      return 'Error';
    }
}


  Future<void> logout(String token) async {
    var body = PerformNativeLogoutBody((b) => b
                                              ..sessionToken = token);
    final response = api.performNativeLogout(performNativeLogoutBody: body);

  }
}
