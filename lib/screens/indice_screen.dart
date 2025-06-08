// lib/screens/indice_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class IndiceScreen extends StatefulWidget {
  @override
  _IndiceScreenState createState() => _IndiceScreenState();
}

class _IndiceScreenState extends State<IndiceScreen> {
  List<Map<String, dynamic>> sesionesConDetalle = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSesionesConDetalle();
  }

  Future<void> _loadSesionesConDetalle() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final sesionesSnapshot = await firestore.collection('sesiones').get();

      final List<Map<String, dynamic>> temp = [];

      for (final sesionDoc in sesionesSnapshot.docs) {
        final sessionId = sesionDoc.id;
        final sessionData = sesionDoc.data();

        DocumentSnapshot<Map<String, dynamic>> prodSnapshot;
        Map<String, dynamic>? productorData;
        try {
          prodSnapshot = await firestore
              .collection('sesiones')
              .doc(sessionId)
              .collection('datos_productor')
              .doc('info')
              .get();
          if (prodSnapshot.exists) {
            productorData = prodSnapshot.data();
          }
        } catch (_) {
          productorData = null;
        }

        final evalsSnapshot = await firestore
            .collection('sesiones')
            .doc(sessionId)
            .collection('evaluaciones_animales')
            .orderBy('timestamp', descending: true)
            .get();

        final List<Map<String, dynamic>> listaEvaluaciones = [];
        for (final evalDoc in evalsSnapshot.docs) {
          final dataEval = evalDoc.data();
          dataEval['evalId'] = evalDoc.id;
          listaEvaluaciones.add(dataEval);
        }

        temp.add({
          'sessionId': sessionId,
          'sessionData': sessionData,
          'productorData': productorData,
          'evaluaciones': listaEvaluaciones,
        });
      }

      setState(() {
        sesionesConDetalle = temp;
        _loading = false;
      });
    } catch (e) {
      print('❌ Error al cargar sesiones: $e');
      setState(() {
        sesionesConDetalle = [];
        _loading = false;
      });
    }
  }

  String _formatTimestamp(Timestamp? ts) {
    if (ts == null) return '-';
    final dt = ts.toDate();
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Índice de Sesiones y Evaluaciones'),
        backgroundColor: Colors.blue[800],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : sesionesConDetalle.isEmpty
              ? const Center(child: Text('No hay sesiones registradas.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: sesionesConDetalle.length,
                  itemBuilder: (context, index) {
                    final sesion = sesionesConDetalle[index];
                    final sessionId = sesion['sessionId'] as String;
                    final sessionData = sesion['sessionData'] as Map<String, dynamic>;
                    final productorData = sesion['productorData'] as Map<String, dynamic>?;
                    final evaluaciones = sesion['evaluaciones'] as List<Map<String, dynamic>>;

                    final fechaSesion = sessionData['timestamp'] is Timestamp
                        ? _formatTimestamp(sessionData['timestamp'])
                        : '-';

                    String fincaNombre = '-';
                    if (productorData != null && productorData['unidad_produccion'] != null && (productorData['unidad_produccion'] as String).trim().isNotEmpty) {
                      fincaNombre = productorData['unidad_produccion'];
                    }

                    String fincaUbicacion = '-';
                    if (productorData != null && productorData['ubicacion'] != null && (productorData['ubicacion'] as String).trim().isNotEmpty) {
                      fincaUbicacion = productorData['ubicacion'];
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                      child: ExpansionTile(
                        leading: const Icon(Icons.home_repair_service, color: Colors.blue),
                        title: Text(
                          fincaNombre,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Ubicación: $fincaUbicacion\nFecha: $fechaSesion'),
                        childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          const SizedBox(height: 8),
                          if (productorData != null) ...[
                            const Text('─── Datos del Productor ───', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 4),
                            _buildDatoFila('Unidad producción', productorData['unidad_produccion'] ?? '-'),
                            _buildDatoFila('Ubicación', productorData['ubicacion'] ?? '-'),
                            _buildDatoFila('Estado', productorData['estado'] ?? '-'),
                            _buildDatoFila('Municipio', productorData['municipio'] ?? '-'),
                            const SizedBox(height: 12),
                          ] else ...[
                            const Text('─ No se encontraron datos del productor ─', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 12),
                          ],
                          Text('─── Evaluaciones (${evaluaciones.length}) ───', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          if (evaluaciones.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text('No hay evaluaciones para esta sesión.', style: TextStyle(color: Colors.grey)),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: evaluaciones.length,
                              separatorBuilder: (context, i) => const Divider(height: 20),
                              itemBuilder: (context, i) {
                                final ev = evaluaciones[i];
                                final numero = ev['numero'] ?? '-';
                                final registro = ev['registro'] ?? '-';
                                final pesoNac = ev['peso_nac'] ?? '-';
                                final fechaEval = ev['timestamp'] is Timestamp
                                    ? _formatTimestamp(ev['timestamp'])
                                    : '-';

                                Widget iconFoto = const SizedBox(width: 48);
                                if (ev['image_base64'] != null) {
                                  try {
                                    final bytes = base64Decode(ev['image_base64']);
                                    iconFoto = ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.memory(bytes, width: 48, height: 48, fit: BoxFit.cover),
                                    );
                                  } catch (_) {
                                    iconFoto = const SizedBox(width: 48);
                                  }
                                }

                                String epmSumario = '';
                                if (ev['epmuras'] is Map<String, dynamic>) {
                                  final epm = ev['epmuras'] as Map<String, dynamic>;
                                  epmSumario = epm.entries.map((e) => '${e.key}:${e.value}').join('  ');
                                }

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: iconFoto,
                                  title: Text('N° $numero  ·  RGN $registro', style: const TextStyle(fontWeight: FontWeight.w500)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text('Peso Nac.: $pesoNac    Fecha: $fechaEval'),
                                      const SizedBox(height: 2),
                                      Text('EPMURAS: $epmSumario', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/animal_detail',
                                      arguments: ev,
                                    );
                                  },
                                );
                              },
                            ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildDatoFila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$etiqueta: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
