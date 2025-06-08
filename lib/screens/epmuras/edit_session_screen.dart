import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditSessionScreen extends StatefulWidget {
  final String sessionId;

  const EditSessionScreen({Key? key, required this.sessionId})
      : super(key: key);

  @override
  State<EditSessionScreen> createState() => _EditSessionScreenState();
}

class _EditSessionScreenState extends State<EditSessionScreen> {
  Map<String, dynamic>? _sessionData;
  Map<String, dynamic>? _producerData;
  List<QueryDocumentSnapshot>? _evaluaciones;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      // 1) Obtener datos de la sesión
      final sessionSnap = await FirebaseFirestore.instance
          .collection('sesiones')
          .doc(widget.sessionId)
          .get();

      // 2) Obtener datos del productor (subcolección 'datos_productor')
      final prodQuery = await FirebaseFirestore.instance
          .collection('sesiones')
          .doc(widget.sessionId)
          .collection('datos_productor')
          .limit(1)
          .get();
      if (prodQuery.docs.isNotEmpty) {
        _producerData = prodQuery.docs.first.data();
      } else {
        _producerData = null;
      }

      // 3) Obtener las evaluaciones que están dentro de esta sesión
      final evalsSnap = await FirebaseFirestore.instance
          .collection('sesiones')
          .doc(widget.sessionId)
          .collection('evaluaciones_animales')
          .orderBy('timestamp', descending: true)
          .get();

      if (!mounted) return;
      setState(() {
        _sessionData = sessionSnap.data();
        _evaluaciones = evalsSnap.docs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar: $e')),
      );
    }
  }

  Future<void> _eliminarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar sesión?'),
        content: const Text('Esto eliminará la sesión y todas sus evaluaciones.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      for (var eval in _evaluaciones ?? []) {
        await eval.reference.delete();
      }
      await FirebaseFirestore.instance
          .collection('sesiones')
          .doc(widget.sessionId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Sesión eliminada')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al eliminar: $e')),
      );
    }
  }

  Future<void> _cambiarEstadoSesion() async {
    final nuevoEstado =
        _sessionData?['estado'] == 'cerrada' ? 'activa' : 'cerrada';
    await FirebaseFirestore.instance
        .collection('sesiones')
        .doc(widget.sessionId)
        .update({'estado': nuevoEstado});

    setState(() {
      _sessionData?['estado'] = nuevoEstado;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(nuevoEstado == 'cerrada'
            ? '✅ Sesión cerrada correctamente.'
            : '✅ Sesión reabierta.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: const Text(
          'Editar Sesión',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sessionData == null
              ? const Center(child: Text('No se encontró la sesión'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ───────── Tarjeta: Datos del Productor ─────────
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _producerData == null
                              ? const Text(
                                  'No hay datos del productor registrados.',
                                  style: TextStyle(fontSize: 16),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Datos del Productor:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Unidad de Producción: ${_producerData?['unidad_produccion'] ?? '-'}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ubicación: ${_producerData?['ubicacion'] ?? '-'}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Estado (Prod.): ${_producerData?['estado'] ?? '-'}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Municipio: ${_producerData?['municipio'] ?? '-'}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ───────── Texto: Cantidad de Evaluaciones ─────────
                      Text(
                        'Evaluaciones (${_evaluaciones?.length ?? 0}):',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ───────── Lista de Evaluaciones ─────────
                      Expanded(
                        child: (_evaluaciones == null || _evaluaciones!.isEmpty)
                            ? const Center(
                                child: Text(
                                  'No hay evaluaciones en esta sesión.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _evaluaciones!.length,
                                itemBuilder: (context, index) {
                                  final docEval = _evaluaciones![index];
                                  final data =
                                      docEval.data() as Map<String, dynamic>;

                                  // Decodificar foto base64 si existe:
                                  Uint8List? imageBytes;
                                  final imageBase64 =
                                      data['image_base64'] as String?;
                                  if (imageBase64 != null &&
                                      imageBase64.isNotEmpty) {
                                    try {
                                      imageBytes =
                                          base64Decode(imageBase64);
                                    } catch (_) {
                                      imageBytes = null;
                                    }
                                  }

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 2,
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      leading: imageBytes != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.memory(
                                                imageBytes,
                                                width: 50.0,
                                                height: 50.0,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Icon(
                                              Icons.pets,
                                              color: Colors.blue[700],
                                              size: 40.0,
                                            ),
                                      title: Text(
                                        data['numero'] ?? 'Sin número',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                              'Registro: ${data['registro'] ?? 'N/A'}'),
                                          const SizedBox(height: 2),
                                          // Mostrar la fecha de creación de la evaluación si existe
                                          if (data['timestamp'] != null)
                                            Text(
                                              'Fecha: ${_formatearTimestamp(data['timestamp'] as Timestamp)}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                        ],
                                      ),
                                      onTap: () {
                                        // Opcional: navegar a detalle de la evaluación
                                        Navigator.pushNamed(
                                          context,
                                          '/animal_detail',
                                          arguments: data,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 16),

                      // ───────── Botones: Cambiar Estado / Eliminar Sesión ─────────
                      ElevatedButton.icon(
                        onPressed: _cambiarEstadoSesion,
                        icon: Icon(
                          _sessionData?['estado'] == 'cerrada'
                              ? Icons.lock_open
                              : Icons.lock,
                        ),
                        label: Text(
                          _sessionData?['estado'] == 'cerrada'
                              ? 'Reabrir sesión'
                              : 'Cerrar sesión',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[500],
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),

                      const SizedBox(height: 12),

                      ElevatedButton.icon(
                        onPressed: _eliminarSesion,
                        icon: const Icon(Icons.delete),
                        label: const Text('Eliminar Sesión'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  /// Formatea un Timestamp a "DD/MM/YYYY HH:mm"
  String _formatearTimestamp(Timestamp ts) {
    final dt = ts.toDate();
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year  $hour:$minute';
  }
}
