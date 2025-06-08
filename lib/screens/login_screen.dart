// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';             // <-- IMPORTAMOS Firestore
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'package:boviframe/screens/providers/auth_provider.dart' as my_auth; // tu AuthProvider

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 1) FUNCIONES AUXILIARES PARA POBLAR SettingsProvider
  Future<void> _loadUserDataIntoProvider(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final name    = (data['name']    as String?) ?? '';
        final email   = (data['email']   as String?) ?? '';
        final company = (data['company'] as String?) ?? '';
        // Guardamos en el SettingsProvider:
        final settingsProv = Provider.of<SettingsProvider>(context, listen: false);
        settingsProv.setUserData(name: name, email: email, company: company);
      }
    } catch (e) {
      // Si hay un error, al menos ponemos el email actual del auth y dejamos company vacío
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final settingsProv = Provider.of<SettingsProvider>(context, listen: false);
      settingsProv.setUserData(
        name: firebaseUser?.displayName ?? '',
        email: firebaseUser?.email ?? '',
        company: '',
      );
    }
  }

  /// 2) LOGIN CON EMAIL / CONTRASEÑA
  Future<void> _signIn() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese email y contraseña')),
      );
      return;
    }

    try {
      final authProvider = Provider.of<my_auth.AuthProvider>(
        context,
        listen: false,
      );

      final errorMessage = await authProvider.login(email, password);
      if (errorMessage != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        return;
      }

      // Si el login fue exitoso, obtenemos el UID:
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final uid = firebaseUser.uid;
        // Cargamos el resto de datos desde Firestore
        await _loadUserDataIntoProvider(uid);
      }

      // Finalmente, navegamos a la pantalla principal (/home)
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main_menu');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
    }
  }

  /// 3) LOGIN CON GOOGLE
  Future<void> _signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        clientId: 'TU_CLIENT_ID_DE_GOOGLE.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // el usuario canceló

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser  = userCredential.user;
      if (firebaseUser != null) {
        final uid = firebaseUser.uid;
        // Es posible que todavía no exista el documento en /usuarios/{uid}, 
        // así que podrías crearlo o leerlo. A continuación solo intentamos leerlo:
        await _loadUserDataIntoProvider(uid);
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main_menu');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión con Google: $e')),
      );
    }
  }

  /// 4) LOGIN CON FACEBOOK
  Future<void> _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success && result.accessToken != null) {
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );
        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final firebaseUser = userCredential.user;
        if (firebaseUser != null) {
          final uid = firebaseUser.uid;
          await _loadUserDataIntoProvider(uid);
        }
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/main_menu');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión con Facebook cancelado.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión con Facebook: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icons/fondo6.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 55),
                SizedBox(
                  width: 250,
                  child: Image.asset('assets/icons/logoapp3.png'),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Registrarse'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Iniciar Sesión'),
                ),
                const SizedBox(height: 30),
                const Text('O inicia sesión con:'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _signInWithGoogle,
                      child: Image.asset(
                        'assets/img/google.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: _signInWithFacebook,
                      child: Image.asset(
                        'assets/img/facebook.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
