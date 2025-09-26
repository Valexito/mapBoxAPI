import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Trae la instancia de FirebaseAuth desde core (no redefinir aquí).
import 'package:mapbox_api/features/core/providers/firebase_providers.dart'
    show firebaseAuthProvider;

/// 🔄 Emite en login/logout y también cuando cambian perfil/token.
final authUserStreamProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.userChanges(); // incluye cambios de perfil e idToken
});

/// Acciones de autenticación centralizadas.
final authActionsProvider = Provider<_AuthActions>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return _AuthActions(auth);
});

class _AuthActions {
  _AuthActions(this._auth);
  final FirebaseAuth _auth;

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

  /// Cierra sesión en Firebase y también en Google si aplica.
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // Ignora si no había sesión de Google.
    }
    await _auth.signOut();
  }
}
