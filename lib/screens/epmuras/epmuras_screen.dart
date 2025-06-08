import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EpmurasScreen extends StatelessWidget {
  const EpmurasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: const Text(
          'Evaluaciones EPMURAS',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Debes iniciar sesión para crear una sesión.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                try {
                  final existingSessionsSnapshot = await FirebaseFirestore
                      .instance
                      .collection('sesiones')
                      .where('userId', isEqualTo: currentUser.uid)
                      .get();

                  final nextSessionNumber = existingSessionsSnapshot.docs.length + 1;

                  final docRef = await FirebaseFirestore.instance
                      .collection('sesiones')
                      .add({
                    'fecha_creacion': FieldValue.serverTimestamp(),
                    'estado': 'activa',
                    'userId': currentUser.uid,
                    'numero_sesion': 'Sesión $nextSessionNumber',
                    'numero_sesion_int': nextSessionNumber,
                  });

                  final sessionId = docRef.id;

                  Navigator.pushNamed(
                    context,
                    '/new_session',
                    arguments: {
                      'sessionId': sessionId,
                      'numeroSesion': 'Sesión $nextSessionNumber',
                    },
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al crear sesión: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue[50],
                foregroundColor: Colors.blue[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text('Nueva sesión'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/edit_session_selector');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue[50],
                foregroundColor: Colors.blue[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text('Editar sesión'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics), label: 'EPMURAS'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Índices'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Más'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/main');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/consulta');
              break;
            case 2:
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/index');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }
}
