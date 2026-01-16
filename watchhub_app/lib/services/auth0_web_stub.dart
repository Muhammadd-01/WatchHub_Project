import 'package:auth0_flutter/auth0_flutter.dart';

class Auth0WebImpl {
  Auth0WebImpl(String domain, String clientId);
  Future<void> init() async {}
  Future<Credentials?> loginWithPopup({String? connection}) async => null;
  Future<void> logout() async {}
}
