// lib/screens/edit_session_selector_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditSessionSelectorScreen extends StatelessWidget {
  const EditSessionSelectorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: const Text(
          'Seleccionar Sesión',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sesiones')
            .orderBy('fecha_creacion', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay sesiones disponibles.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              // Extraemos el número de sesión (campo 'numero_sesion')
              final numeroSesion = data['numero_sesion'] as String? ?? '—';

              // Extraemos el estado de la sesión (por ejemplo: "activa", "cerrada", etc.)
              final estado = data['estado'] as String? ?? 'Sin estado';

              // Convertimos la marca de tiempo a un texto legible.
              final fecha = (data['fecha_creacion'] as Timestamp?)?.toDate();
              final fechaTexto = fecha != null
                  ? '${fecha.day.toString().padLeft(2, '0')}/'
                      '${fecha.month.toString().padLeft(2, '0')}/'
                      '${fecha.year}  '
                      '${fecha.hour.toString().padLeft(2, '0')}:'
                      '${fecha.minute.toString().padLeft(2, '0')}'
                  : 'Fecha no disponible';

              return Card(
                color: Colors.blue[50],
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  leading: const Icon(Icons.folder_open,
                      size: 32, color: Colors.blue),
                  title: Text(
                    'Sesión: $numeroSesion',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('sesiones')
                        .doc(doc.id)
                        .collection('datos_productor')
                        .limit(1)
                        .get(),
                    builder: (context, prodSnapshot) {
                      if (prodSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('Cargando datos del productor…'),
                        );
                      }
                      if (!prodSnapshot.hasData ||
                          prodSnapshot.data!.docs.isEmpty) {
                        // Si no hay datos de productor, mostramos solo estado/fecha:
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Estado: $estado'),
                              Text('Creado: $fechaTexto'),
                              const SizedBox(height: 4),
                              const Text(
                                'Datos del productor no disponibles',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      // Si existe al menos un documento en datos_productor:
                      final prodData = prodSnapshot.data!.docs.first.data()
                          as Map<String, dynamic>;

                      final unidadProduccion = prodData['unidad_produccion']
                              as String? ??
                          'Unidad no especificada';
                      final ubicacion =
                          prodData['ubicacion'] as String? ?? 'Ubicación no especificada';
                      final estadoProd =
                          prodData['estado'] as String? ?? 'Estado no especificado';
                      final municipio =
                          prodData['municipio'] as String? ?? 'Municipio no especificado';

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Datos del productor:
                            Text('Unidad: $unidadProduccion'),
                            Text('Ubicación: $ubicacion'),
                            Text('Estado (Prod.): $estadoProd'),
                            Text('Municipio: $municipio'),
                            const SizedBox(height: 4),
                            // Estado y fecha de la sesión:
                            Text('Estado (Sesión): $estado'),
                            Text('Creado: $fechaTexto'),
                          ],
                        ),
                      );
                    },
                  ),
                  trailing:
                      const Icon(Icons.chevron_right, color: Colors.blue),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/edit_session',
                      arguments: doc.id,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
