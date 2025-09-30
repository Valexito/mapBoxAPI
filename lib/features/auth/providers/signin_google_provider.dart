import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importa SOLO la instancia desde core (evita duplicados).
import 'package:mapbox_api/features/core/providers/firebase_providers.dart'
    show firebaseAuthProvider;

final googleSignInInstanceProvider = Provider<GoogleSignIn>((_) {
  return GoogleSignIn(); // Config por defecto; si usas scopes, agrégalos aquí.
});

final signInWithGoogleProvider =
    Provider<Future<UserCredential> Function()>((ref) {
  final google = ref.watch(googleSignInInstanceProvider);
  final auth = ref.watch(firebaseAuthProvider);

  return () async {
    final account = await google.signIn();
    if (account == null) {
      throw Exception('Inicio de sesión cancelado');
    }

    final tokens = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: tokens.accessToken,
      idToken: tokens.idToken,
    );
    return auth.signInWithCredential(credential);
  };
});