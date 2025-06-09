import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint

/// Resultado de intentar registrar, con usuario o mensaje de error.
class RegisterResult {
  final User? user;
  final String? errorMessage;

  RegisterResult({this.user, this.errorMessage});
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Intentar registrar con email y contraseña.
  /// Devuelve un [RegisterResult].
  Future<RegisterResult> registerWithEmail({
    required String email,
    required String password,
    required String nombre,
    required String profesion,
    required String ubicacion,
  }) async {
    try {
      // 1) Crear usuario en Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        return RegisterResult(
          errorMessage: 'No se pudo registrar el usuario.',
        );
      }

      final uid = user.uid;

      // 2) Guardar perfil en /usuarios/{uid}
      await _firestore.collection('usuarios').doc(uid).set({
        'email':     email.trim(),
        'nombre':    nombre.trim(),
        'profesion': profesion.trim(),
        'ubicacion': ubicacion.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3) Crear sesión en /sesiones/{sessionId} con el campo userId
      final sessionRef = _firestore.collection('sesiones').doc();
      await sessionRef.set({
        'userId':        uid,
        'fecha_creacion': FieldValue.serverTimestamp(),
        'estado':        'activa',
      });

      // 4) (opcional) Guardar flag de login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      return RegisterResult(user: user);
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException en registro: ${e.code} - ${e.message}');
      String mensajeUsuario;
      switch (e.code) {
        case 'email-already-in-use':
          mensajeUsuario = 'El correo ya está en uso.';
          break;
        case 'invalid-email':
          mensajeUsuario = 'El formato del correo no es válido.';
          break;
        case 'operation-not-allowed':
          mensajeUsuario = 'Operación de registro no permitida.';
          break;
        case 'weak-password':
          mensajeUsuario = 'La contraseña es muy débil.';
          break;
        default:
          mensajeUsuario = e.message ?? 'Error desconocido al registrar.';
      }
      return RegisterResult(errorMessage: mensajeUsuario);
    } catch (e) {
      debugPrint('Error genérico en registro: $e');
      return RegisterResult(errorMessage: 'Error al registrar: ${e.toString()}');
    }
  }

  // Resto: loginWithEmail, logout, authStateChanges, etc.
}
