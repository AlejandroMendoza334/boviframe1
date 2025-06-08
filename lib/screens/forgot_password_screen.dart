import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  void _resetPassword(BuildContext context) async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor ingresa tu correo electrónico')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '📧 Se envió un correo para restablecer la contraseña.',
          ),
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
  String message = 'Usuario o contraseña incorrecta o no registrado.';
  if (e.code == 'user-not-found') {
    message = 'Este usuario no está registrado.';
  } else if (e.code == 'wrong-password') {
    message = 'Contraseña incorrecta.';
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
} catch (_) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error inesperado al iniciar sesión.')),
  );
}

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ingresa tu correo electrónico para restablecer tu contraseña:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _resetPassword(context),
              child: Text('Enviar enlace de recuperación'),
            ),
          ],
        ),
      ),
    );
  }
}
