import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  final g = GoogleSignIn();
  final user = await g.signIn();
  print(user);
}
