import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:boviframe/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  final _nombreCtrl    = TextEditingController();
  final _ubicacionCtrl = TextEditingController();

  final List<String> _professions = ['Veterinario','Zootecnista','Agrónomo','Otro'];
  String _selectedProfession = 'Veterinario';

  bool _isLoading = false;
  String? _errorMessage;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nombreCtrl.dispose();
    _ubicacionCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegisterPressed() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  // Ahora recibimos RegisterResult
  final result = await _authService.registerWithEmail(
    email:     _emailCtrl.text.trim(),
    password:  _passwordCtrl.text,
    nombre:    _nombreCtrl.text.trim(),
    profesion: _selectedProfession,
    ubicacion: _ubicacionCtrl.text.trim(),
  );

  setState(() {
    _isLoading = false;
  });

  if (result.user != null) {
    // Registro OK: navegar al home
    Navigator.of(context).pushReplacementNamed('/home');
  } else {
    // Mostrar error
    setState(() {
      _errorMessage = result.errorMessage ?? 'Error desconocido';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro'), backgroundColor: Colors.blueAccent),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal:24, vertical:32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email', prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator: (v){
                        if (v==null||v.isEmpty) return 'Ingresa un email';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Email inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height:16),

                    // Password
                    TextFormField(
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: (v){
                        if (v==null||v.isEmpty) return 'Ingresa una contraseña';
                        if (v.length<6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height:16),

                    // Confirm
                    TextFormField(
                      controller: _confirmCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar Contraseña', prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (v){
                        if (v==null||v.isEmpty) return 'Confirma tu contraseña';
                        if (v!=_passwordCtrl.text) return 'Las contraseñas no coinciden';
                        return null;
                      },
                    ),
                    const SizedBox(height:24),

                    // Nombre
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre y Apellido', prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v){
                        if (v==null||v.trim().isEmpty) return 'Ingresa tu nombre';
                        return null;
                      },
                    ),
                    const SizedBox(height:16),

                    // Profesión
                    DropdownButtonFormField<String>(
                      value: _selectedProfession,
                      items: _professions.map((p)=>DropdownMenuItem(value:p,child:Text(p))).toList(),
                      onChanged: (v){ if(v!=null) setState(()=>_selectedProfession=v); },
                      decoration: const InputDecoration(
                        labelText: 'Profesión', prefixIcon: Icon(Icons.work_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height:16),

                    // Ubicación
                    TextFormField(
                      controller: _ubicacionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Ubicación (ciudad, país)', prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v){
                        if (v==null||v.trim().isEmpty) return 'Ingresa tu ubicación';
                        return null;
                      },
                    ),
                    const SizedBox(height:24),

                    if (_errorMessage!=null) ...[
                      Text(_errorMessage!, style: const TextStyle(color:Colors.red)),
                      const SizedBox(height:16),
                    ],

                    // Botón
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading?null:_onRegisterPressed,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical:16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isLoading
                          ? const SizedBox(
                              height:24, width:24,
                              child: CircularProgressIndicator(color:Colors.white, strokeWidth:2),
                            )
                          : const Text('Registrarme', style: TextStyle(fontSize:16)),
                      ),
                    ),
                    const SizedBox(height:12),
                    TextButton(
                      onPressed: ()=>Navigator.of(context).pop(),
                      child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
