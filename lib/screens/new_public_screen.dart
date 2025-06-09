// lib/screens/new_public_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewsPublicScreen extends StatefulWidget {
  const NewsPublicScreen({Key? key}) : super(key: key);

  @override
  State<NewsPublicScreen> createState() => _NewsPublicScreenState();
}

class _NewsPublicScreenState extends State<NewsPublicScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cambia aquí por el UID exacto de tu administrador:
  bool get _isAdmin {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.uid == 'p9HOIe0bhuXKCXtLonmO2DXIQyf2';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias'),
        backgroundColor: Colors.blue.shade400,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ESTE BLOQUE SOLO SE VE SI _isAdmin == true
          if (_isAdmin) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Crear Noticia'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade200,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/news_create');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.manage_accounts),
                      label: const Text('Administrar Noticias'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade200,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/news_admin');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          // El listado (visible para todos, admin o no)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('news')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Aún no hay noticias.'));
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final title = data['title'] as String? ?? '';
                    final ts = data['timestamp'] as Timestamp?;
                    final date = ts?.toDate();
                    final formattedDate = (date != null)
                        ? '${date.day.toString().padLeft(2, '0')}/'
                          '${date.month.toString().padLeft(2, '0')}/'
                          '${date.year}'
                        : '';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: Image.asset(
                          'assets/icons/logo1.png',
                          width: 28,
                          height: 28,
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(formattedDate),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/news_detail',
                            arguments: docs[index].id,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
