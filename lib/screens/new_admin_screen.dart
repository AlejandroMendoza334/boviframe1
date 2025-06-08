// lib/screens/news_admin_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'new_edit_screen.dart';

class NewsAdminScreen extends StatefulWidget {
  const NewsAdminScreen({Key? key}) : super(key: key);

  @override
  State<NewsAdminScreen> createState() => _NewsAdminScreenState();
}

class _NewsAdminScreenState extends State<NewsAdminScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _authorizedUID = 'bnUwRqbqNPQLOyPZD6wZialhyE82';

  Future<void> _deleteNews(String docId) async {
    try {
      await _firestore.collection('news').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Noticia eliminada')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar noticia'),
        content: const Text('¿Seguro que deseas eliminar esta noticia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteNews(docId);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAuthorized = user != null && user.uid == _authorizedUID;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Noticias'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: isAuthorized
          ? StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('news')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No hay noticias para administrar.'));
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
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                      child: ListTile(
                        title: Text(title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(formattedDate),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botón Editar:
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () {
                                // Navega a NewsEditScreen y pasa el docId
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => NewsEditScreen(
                                      documentId: docs[index].id,
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Botón Eliminar:
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(docs[index].id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : Center(
              child: Text(
                'No tienes permiso para administrar noticias.',
                style: TextStyle(fontSize: 18, color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}
