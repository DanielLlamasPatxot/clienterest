import 'dart:convert';
import 'dart:math';
import 'package:built_value/json_object.dart';
import 'package:http/http.dart' as http;
import 'package:one_of/one_of.dart';
import 'package:one_of/src/oneOf/one_of_base.dart';
import 'package:ory_client/ory_client.dart';




class AuthService {
  
  final api = OryClient().getFrontendApi();
  //final prb = OryClient().get
  final apiOauth = OryClient(basePathOverride: 'http://127.0.0.1:4445/').getOAuth2Api(); 

Future<String?> register(String username, String password) async {
 final flow =  await api.createNativeRegistrationFlow(returnSessionTokenExchangeCode: true);
 //print(flow.toString());
 //print('Aquí la id${flow.data!.id}');
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
      
      var _idClient = response.data!.session.identity!.id;
      
       /*
      print(response.data);
      print(response.data!.session.identity!.traits.toString());
      var traits = response.data?.session?.identity?.traits;
      var email = extractEmail(traits);
      print(email);
      print('El session Token es: ${response.data!.sessionToken}');
      */
      if (response.statusCode == 200 || response.statusCode == 201) {
      print('Login exitoso');
    } else {
      print('Error al logear: ${response.statusCode}');
    }
      //Ignora esto jaja
      checkPerms(_idClient);
      return response.data!.sessionToken;
  }
  

  Future<bool> checkingToken(String token) async {
  final api = OryClient().getFrontendApi();
  try {
    final response = await api.toSession(xSessionToken: token);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(response.data!.identity!.traits!.asList.first);
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

  Future<String?> whoami(String token) async {
  final api = OryClient().getFrontendApi();
    final response = await api.toSession(xSessionToken: token);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(response.data!.identity);
      var email = extractEmail(response.data!.identity!.traits);
      print(email);
      return(email);
    
    } else {
      print('Token no valido');
      return 'Error';
    }
}


  Future<bool> logout(String token) async {
    var body = PerformNativeLogoutBody((b) => b
                                              ..sessionToken = token);
    final response = await api.performNativeLogout(performNativeLogoutBody: body);
    print(response.statusCode);
    print(response);

    if(response.statusCode == 204){
      return true;
    }else{
      return false;
    }

  }
  
  Future<void> checkPerms(String id) async{
    /*
    var newClient = OAuth2Client((b) => b
    ..clientName = 'Daniel'
    ..clientId = 'a82431ba-7d37-4811-be87-7f29362d32ba'
    ..clientSecret = 'secreteixion'
    );
    
  
    final response = await apiOauth.createOAuth2Client(oAuth2Client: newClient);
    print(response.data);

    */
    final resp = await apiOauth.getOAuth2Client(id:id);

    print(resp);

    
    //print('Soy de check : ${response}');
    final respo = await apiOauth.acceptOAuth2ConsentRequest(consentChallenge: 'http://127.0.0.1:4433/schemas/ZGVmYXVsdA');
    print(respo);
    
  }


  String? extractEmail(dynamic traits) {
  if (traits != null) {
    // Convertir traits a una cadena
    var traitsString = traits.toString();

    // Usar split para separar por los caracteres '{', '}' y ':'
    var parts = traitsString.split(RegExp(r'[{}:, ]')).where((part) => part.isNotEmpty).toList();

    // Buscar la parte que sigue a 'email'
    var emailIndex = parts.indexOf('email');
    if (emailIndex != -1 && emailIndex + 1 < parts.length) {
      return parts[emailIndex + 1];
    }
  }
  return null;
}
}
