// lib/features/auth/providers/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Usa la instancia centralizada de FirebaseAuth desde core
import 'package:mapbox_api/features/core/providers/firebase_providers.dart'
    show firebaseAuthProvider;

/// ==============================
///  USER STREAM (reactivo)
/// ==============================
final authUserStreamProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.userChanges();
});

/// ==============================
///  GOOGLE SIGN-IN
/// ==============================
final googleSignInInstanceProvider = Provider<GoogleSignIn>((_) {
  return GoogleSignIn();
});

final signInWithGoogleProvider = Provider<Future<UserCredential> Function()>((
  ref,
) {
  final google = ref.watch(googleSignInInstanceProvider);
  final auth = ref.watch(firebaseAuthProvider);

  return () async {
    final account = await google.signIn();
    if (account == null) throw Exception('Inicio de sesión cancelado');

    final tokens = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: tokens.accessToken,
      idToken: tokens.idToken,
    );
    return auth.signInWithCredential(credential);
  };
});

/// ==============================
///  ACCIONES DE AUTH
/// ==============================
final authActionsProvider = Provider<_AuthActions>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return _AuthActions(auth, ref);
});

class _AuthActions {
  _AuthActions(this._auth, this._ref);

  final FirebaseAuth _auth;
  final Ref _ref;

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    try {
      await _ref.read(googleSignInInstanceProvider).signOut();
    } catch (_) {
      // Ignorar si no había sesión de Google
    }
    await _auth.signOut();
  }
}
