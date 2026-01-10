import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

class Auth0WebImpl {
  final String domain;
  final String clientId;
  late Auth0Web _auth0Web;

  Auth0WebImpl(this.domain, this.clientId) {
    _auth0Web = Auth0Web(domain, clientId);
  }

  Future<void> init() async {
    await _auth0Web.onLoad();
  }

  Future<Credentials?> loginWithPopup({String? connection}) async {
    return await _auth0Web.loginWithPopup(
      parameters: connection != null ? {'connection': connection} : {},
    );
  }

  Future<void> logout() async {
    await _auth0Web.logout();
  }
}
