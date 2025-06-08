// lib/screens/consulta_animal_screen.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConsultaAnimalScreen extends StatefulWidget {
  const ConsultaAnimalScreen({Key? key}) : super(key: key);

  @override
  State<ConsultaAnimalScreen> createState() => _ConsultaAnimalScreenState();
}

class _ConsultaAnimalScreenState extends State<ConsultaAnimalScreen> {
  final TextEditingController _rgnController     = TextEditingController();
  final TextEditingController _sexoController    = TextEditingController();
  final TextEditingController _estadoController  = TextEditingController();
  final TextEditingController _sesionController  = TextEditingController();

  bool _loading       = true;
  String? _errorMsg;
  List<Map<String, dynamic>> _todosLosDocs   = [];
  List<Map<String, dynamic>> _resultados     = [];

  @override
  void initState() {
    super.initState();
    _cargarTodasLasEvaluaciones();
  }

  @override
  void dispose() {
    _rgnController.dispose();
    _sexoController.dispose();
    _estadoController.dispose();
    _sesionController.dispose();
    super.dispose();
  }

  Future<void> _cargarTodasLasEvaluaciones() async {
    setState(() {
      _loading  = true;
      _errorMsg = null;
      _todosLosDocs.clear();
      _resultados.clear();
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('evaluaciones_animales')
          .get();

      final futuros = querySnapshot.docs.map((doc) async {
        final data = <String, dynamic>{}..addAll(doc.data() as Map<String, dynamic>);
        data['evalId'] = doc.id;

        String sessionId = '';
        if (doc.reference.parent.parent != null) {
          sessionId = doc.reference.parent.parent!.id;
        }
        data['session_id'] = sessionId;

        String numeroSesionPadre = '—';
        if (doc.reference.parent.parent != null) {
          final parentSnap = await doc.reference.parent.parent!.get();
          if (parentSnap.exists) {
            numeroSesionPadre = (parentSnap.data()?['numero_sesion'] ?? '—').toString();
          }
        }
        data['numero_sesion'] = numeroSesionPadre;

        return data;
      }).toList();

      final listaConSesiones = await Future.wait(futuros);

      setState(() {
        _todosLosDocs = listaConSesiones;
        _resultados   = List.from(_todosLosDocs);
        _loading      = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Error cargando evaluaciones: $e';
        _loading  = false;
      });
    }
  }

  Future<void> _buscarAnimales() async {
    final rgnFilter    = _rgnController.text.trim();
    final sexoFilter   = _sexoController.text.trim();
    final estadoFilter = _estadoController.text.trim();
    final sesionFilter = _sesionController.text.trim();

    if (rgnFilter.isEmpty &&
        sexoFilter.isEmpty &&
        estadoFilter.isEmpty &&
        sesionFilter.isEmpty) {
      setState(() {
        _resultados = List.from(_todosLosDocs);
      });
      return;
    }

    setState(() {
      _loading  = true;
      _errorMsg = null;
      _resultados.clear();
    });

    try {
      final filtrados = <Map<String, dynamic>>[];

      for (final doc in _todosLosDocs) {
        final registro  = (doc['registro']     ?? '').toString().trim();
        final sexo      = (doc['sexo']         ?? '').toString().trim();
        final estado    = (doc['estado']       ?? '').toString().trim();
        final sessionId = (doc['session_id']   ?? '').toString().trim();

        bool cumpleRgn    = rgnFilter.isEmpty    || registro == rgnFilter;
        bool cumpleSexo   = sexoFilter.isEmpty   || sexo.toLowerCase()   == sexoFilter.toLowerCase();
        bool cumpleEstado = estadoFilter.isEmpty || estado.toLowerCase() == estadoFilter.toLowerCase();
        bool cumpleSes    = sesionFilter.isEmpty || sessionId == sesionFilter;

        if (cumpleRgn && cumpleSexo && cumpleEstado && cumpleSes) {
          filtrados.add(doc);
        }
      }

      setState(() {
        _resultados = filtrados;
        _loading     = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Error inesperado al filtrar: $e';
        _loading  = false;
      });
    }
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filtros adicionales',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _sexoController,
                  decoration: const InputDecoration(
                    labelText: 'Sexo (ej. Macho, Hembra)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _estadoController,
                  decoration: const InputDecoration(
                    labelText: 'Estado (ej. Toretes, Novillas, etc)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _sesionController,
                  decoration: const InputDecoration(
                    labelText: 'Sesión (ID de la sesión padre)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _buscarAnimales();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('APLICAR FILTROS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('CERRAR FILTROS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Consulta Animal',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Filtro por RGN',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                  controller: _rgnController,
                  decoration: const InputDecoration(
                    labelText: 'RGN (Registro Animal)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _mostrarFiltros,
                        icon: const Icon(Icons.filter_list, color: Colors.white),
                        label: const Text(
                          'FILTROS',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[500],
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _buscarAnimales,
                        icon: const Icon(Icons.search, color: Colors.white),
                        label: const Text(
                          'BUSCAR',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[500],
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_errorMsg != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMsg!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (_resultados.isEmpty
                    ? const Center(child: Text('No se encontraron animales'))
                    : ListView.builder(
                        itemCount: _resultados.length,
                        itemBuilder: (context, index) {
                          final data = _resultados[index];
                          Uint8List? imageBytes;
                          final imageBase64 = data['image_base64'] as String?;
                          if (imageBase64 != null && imageBase64.isNotEmpty) {
                            try {
                              imageBytes = base64Decode(imageBase64);
                            } catch (_) {
                              imageBytes = null;
                            }
                          }
                          double puntuacion = 0;
                          {
                            final epm = data['epmuras'] as Map<String, dynamic>? ?? {};
                            double suma = 0;
                            int conteo = 0;
                            epm.forEach((k, v) {
                              final val = double.tryParse(v?.toString() ?? '') ?? 0.0;
                              suma += val;
                              conteo++;
                            });
                            if (conteo > 0) puntuacion = suma / conteo;
                          }
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: imageBytes != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        imageBytes,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.image_not_supported),
                              title: Text('N° ${data['numero'] ?? '-'}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('RGN: ${data['registro'] ?? '-'}'),
                                  Text('Sexo: ${data['sexo'] ?? '-'}'),
                                  Text('Estado: ${data['estado'] ?? '-'}'),
                                  Text('Sesión: ${data['numero_sesion'] ?? '-'}'),
                                  Text('Puntuación: ${puntuacion.toStringAsFixed(2)}'),
                                ],
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/animal_detail',
                                  arguments: data,
                                );
                              },
                            ),
                          );
                        },
                      )),
          ),
        ],
      ),
    );
  }
}
