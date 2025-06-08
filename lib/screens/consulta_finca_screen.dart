import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sesiones_screen.dart';

class ConsultaFincaScreen extends StatefulWidget {
  const ConsultaFincaScreen({Key? key}) : super(key: key);

  @override
  State<ConsultaFincaScreen> createState() => _ConsultaFincaScreenState();
}

class _ConsultaFincaScreenState extends State<ConsultaFincaScreen> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _fincas = [];

  @override
  void initState() {
    super.initState();
    _initYcargar();
  }

  Future<void> _initYcargar() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      await _cargarTodasLasFincas();
    } catch (e) {
      setState(() {
        _error = 'Error inicializando/autenticando: $e';
        _loading = false;
      });
    }
  }

  Future<void> _cargarTodasLasFincas() async {
    setState(() {
      _loading = true;
      _error = null;
      _fincas.clear();
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('datos_productor')
          .get();

      // Primero construimos una lista plana de sesiones con su finca:
      final lista = <Map<String, dynamic>>[];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final parentCol = doc.reference.parent.parent;
        if (parentCol == null) continue;
        final sessionId = parentCol.id;
        final parentSnap = await parentCol.get();
        final numeroSesion = (parentSnap.data()?['numero_sesion'] ?? '').toString();
        lista.add({
          'unidad_produccion': data['unidad_produccion'] ?? '',
          'ubicacion'        : data['ubicacion']          ?? '',
          'session_id'       : sessionId,
          'numero_sesion'    : numeroSesion,
        });
      }

      // Ahora agrupamos por 'unidad_produccion'
      final Map<String, Map<String, dynamic>> mapa = {};
      for (var item in lista) {
        final finca = item['unidad_produccion'] as String;
        if (!mapa.containsKey(finca)) {
          mapa[finca] = {
            'unidad_produccion': finca,
            'ubicacion': item['ubicacion'],
            'sesiones': <Map<String, String>>[]
          };
        }
        (mapa[finca]!['sesiones'] as List).add({
          'session_id': item['session_id'] as String,
          'numero_sesion': item['numero_sesion'] as String,
        });
      }

      setState(() {
        _fincas = mapa.values.toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error   = 'Error cargando fincas: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // <-- centro el título
        title: const Text(
          'Consulta Fincas',
          style: TextStyle(
            color: Colors.white, // <-- texto en blanco
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            if (_error != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _fincas.isEmpty
                  ? const Center(child: Text('No hay datos de productor.'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: _fincas.length,
                      itemBuilder: (ctx, i) {
                        final finca = _fincas[i];
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // Navegamos a SesionesScreen pasando finca y sesiones:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SesionesScreen(
                                  finca: finca['unidad_produccion'] as String,
                                  sesiones: List<Map<String, String>>.from(
                                    finca['sesiones'] as List
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.domain, size: 20),
                                      const SizedBox(width: 8),
                                      const Text('Finca:',
                                          style: TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(finca['unidad_produccion'])),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 20),
                                      const SizedBox(width: 8),
                                      const Text('Ubicación:',
                                          style: TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(finca['ubicacion'])),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Sesiones: ${(finca['sesiones'] as List).length}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
