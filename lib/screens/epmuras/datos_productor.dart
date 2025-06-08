// lib/screens/datos_productor_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_app_scaffold.dart';
import '../providers/session_provider.dart';

class DatosProductorScreen extends StatefulWidget {
  final String sessionId;

  const DatosProductorScreen({Key? key, required this.sessionId})
      : super(key: key);

  @override
  State<DatosProductorScreen> createState() => _DatosProductorScreenState();
}

class _DatosProductorScreenState extends State<DatosProductorScreen> {
  final _unidadController    = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _municipioController = TextEditingController();
  String? _estadoSeleccionado;

  Future<void> _guardarProductorYContinuar() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // 1) Armar el mapa con todos los campos del productor:
    final produtorMap = {
      'unidad_produccion': _unidadController.text.trim(),
      'ubicacion': _ubicacionController.text.trim(),
      'estado': _estadoSeleccionado ?? '',
      'municipio': _municipioController.text.trim(),
      'fecha_registro': FieldValue.serverTimestamp(), // opcional
      'userId': currentUser.uid,
      'sessionId': widget.sessionId,
    };

    // 2) Guardar localmente en el provider:
    Provider.of<SessionProvider>(context, listen: false)
        .setDatosProductor(produtorMap);

    // 3) Escribir en Firestore en /sesiones/{sessionId}/datos_productor/info
    try {
      // 3a) Asegurarse de que la sesión exista con userId + timestamp
      await FirebaseFirestore.instance
          .collection('sesiones')
          .doc(widget.sessionId)
          .set({
            'userId': currentUser.uid,
            'timestamp': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      // 3b) Ahora guardo el documento “info” con todos los datos del productor
      await FirebaseFirestore.instance
          .collection('sesiones')
          .doc(widget.sessionId)
          .collection('datos_productor')
          .doc('info')
          .set(produtorMap);

      // 4) Navegar a la pantalla de Evaluación Animal
      Navigator.pushNamed(
        context,
        '/animal_evaluation',
        arguments: {'sessionId': widget.sessionId},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al guardar productor: $e')),
      );
    }
  }

  @override
  void dispose() {
    _unidadController.dispose();
    _ubicacionController.dispose();
    _municipioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppScaffold(
      currentIndex: 2,
      title: 'Datos Productor',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos Productor',
              style: TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 12),

            _buildLabeledInput('Unidad de Producción', _unidadController),
            const SizedBox(height: 12),

            _buildLabeledInput('Ubicación', _ubicacionController),
            const SizedBox(height: 12),

            _buildLabeledDropdown('Estado', _estadosVenezuela),
            const SizedBox(height: 12),

            _buildLabeledInput('Municipio', _municipioController),
            const SizedBox(height: 40),

            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: _guardarProductorYContinuar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledInput(
      String label, TextEditingController controller) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontFamily: 'Courier', fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledDropdown(String label, List<String> items) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontFamily: 'Courier', fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _estadoSeleccionado,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) => setState(() => _estadoSeleccionado = value),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  final List<String> _estadosVenezuela = [
    'Amazonas',
    'Anzoátegui',
    'Apure',
    'Aragua',
    'Barinas',
    'Bolívar',
    'Carabobo',
    'Cojedes',
    'Delta Amacuro',
    'Distrito Capital',
    'Falcón',
    'Guárico',
    'Lara',
    'Mérida',
    'Miranda',
    'Monagas',
    'Nueva Esparta',
    'Portuguesa',
    'Sucre',
    'Táchira',
    'Trujillo',
    'La Guaira',
    'Yaracuy',
    'Zulia',
  ];
}
