import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedProfession = 'Veterinario';
  final List<String> _professions = [
    'Veterinario',
    'Zootecnista',
    'Agrónomo',
    'Otro',
  ];

  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _collegeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(currentUser.uid)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data()!;
        final nombre = data['nombre'] ?? '';
        final colegio = data['colegio'] ?? '';
        final ubicacion = data['ubicacion'] ?? '';
        final profesion = data['profesion'] ?? 'Veterinario';
        final email = _user?.email ?? '';

        setState(() {
          _nameController.text = nombre;
          _collegeController.text = colegio;
          _locationController.text = ubicacion;
          _selectedProfession = profesion;
        });

        context.read<SettingsProvider>().setUserData(
              name: nombre,
              email: email,
              company: ubicacion,
            );
      }
    } catch (e) {
      debugPrint('❌ Error al cargar datos: $e');
    }
  }

  Future<void> _saveSettings() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final newName = _nameController.text.trim();
      final newCole = _collegeController.text.trim();
      final newUbic = _locationController.text.trim();
      final newProf = _selectedProfession;
      final newEmail = _user?.email ?? '';

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(currentUser.uid)
          .set({
        'nombre': newName,
        'colegio': newCole,
        'ubicacion': newUbic,
        'profesion': newProf,
      }, SetOptions(merge: true));

      context.read<SettingsProvider>().setUserData(
            name: newName,
            email: newEmail,
            company: newUbic,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuración guardada exitosamente')),
        );
      }
    } catch (e, st) {
      debugPrint('❌ Error al guardar configuración: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar configuración:\n$e')),
        );
      }
    }
  }

  Future<void> _showAboutDialog() async {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/icons/logo1.png', width: 60, height: 60),
                const SizedBox(height: 16),
                const Text(
                  'Técnica EPMURAS',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 28),
                _buildBenefitTile(Icons.timer_outlined, 'Optimización del tiempo', 'Reduce la duración de las consultas manteniendo la calidad.'),
                _buildBenefitTile(Icons.track_changes_outlined, 'Diagnósticos precisos', 'Aumenta la certeza en la identificación de patologías.'),
                _buildBenefitTile(Icons.groups_outlined, 'Mejora la comunicación', 'Facilita la explicación de casos complejos al cliente.'),
                _buildBenefitTile(Icons.checklist_rtl_outlined, 'Protocolos estandarizados', 'Ofrece una guía clara para un abordaje consistente.'),
                const SizedBox(height: 20),
                const Divider(),
                const Text(
                  'Creado por Med. Vet. Gualdrón Williams',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Text(
                  'Versión: 1.0.0',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cerrar', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        title: const Text(
          'Configuración',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nombre y Apellido'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedProfession,
                        items: _professions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedProfession = v);
                        },
                        decoration: const InputDecoration(labelText: 'Profesión'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _collegeController,
                        decoration: const InputDecoration(labelText: 'Número de Colegio'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(labelText: 'Ubicación, Estado, País'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _user?.email ?? '',
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveSettings,
                        child: const Text('Guardar Cambios'),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Acerca de BOVIFrame'),
                        tileColor: Colors.grey[200],
                        onTap: _showAboutDialog,
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Cerrar sesión'),
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          if (mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (_) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
