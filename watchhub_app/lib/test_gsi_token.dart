import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;

Future<void> main() async {
  final g = google_sign_in.GoogleSignIn();
  final user = await g.signIn();
  if (user != null) {
    final auth = await user.authentication;
    print(auth.accessToken);
  }
}
