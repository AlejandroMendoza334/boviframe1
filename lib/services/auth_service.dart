// lib/services/auth_service.dart

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
  /// Devuelve un [RegisterResult] que contiene:
  ///  - user != null si salió bien
  ///  - errorMessage != null si hubo error
  Future<RegisterResult> registerWithEmail({
    required String email,
    required String password,
    required String nombre,
    required String profesion,
    required String ubicacion,
  }) async {
    try {
      // 1) Crear usuario en Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      User? user = result.user;

      if (user == null) {
        // Esto no debería pasar casi nunca, pero por si falla inesperado:
        return RegisterResult(errorMessage: 'No se pudo registrar el usuario.');
      }

      // 2) Crear documento en Firestore bajo /usuarios/{uid}
      final String uid = user.uid;
      await _firestore.collection('usuarios').doc(uid).set({
        'email': email.trim(),
        'nombre': nombre.trim(),
        'profesion': profesion.trim(),
        'ubicacion': ubicacion.trim(),
        // Puedes agregar: 'createdAt': FieldValue.serverTimestamp(),
      });

      // 3) Guardar estado de login en SharedPreferences (opcional)
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

  // (el resto de tu AuthService queda igual: loginWithEmail, logout, authStateChanges)
}
