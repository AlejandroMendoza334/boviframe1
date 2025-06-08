// lib/screens/news_edit_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart'; // para kIsWeb
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class NewsEditScreen extends StatefulWidget {
  final String documentId;

  const NewsEditScreen({Key? key, required this.documentId}) : super(key: key);

  @override
  State<NewsEditScreen> createState() => _NewsEditScreenState();
}

class _NewsEditScreenState extends State<NewsEditScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _isSaving = false;

  // Controladores y variables del formulario
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _pickedImage;
  String? _existingImageUrl;
  String _selectedCategory = 'General';
  final List<String> _categories = ['General', 'Evento', 'Anuncio', 'Otro'];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    try {
      final doc =
          await _firestore.collection('news').doc(widget.documentId).get();
      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Noticia no encontrada.'),
          backgroundColor: Colors.red,
        ));
        Navigator.of(context).pop();
        return;
      }

      final data = doc.data()!;
      _titleController.text = (data['title'] as String?) ?? '';
      _contentController.text = (data['content'] as String?) ?? '';
      _existingImageUrl = data['imageUrl'] as String?;
      _selectedCategory = (data['category'] as String?) ?? 'General';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al cargar: $e'),
        backgroundColor: Colors.red,
      ));
      Navigator.of(context).pop();
      return;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccionar imagen no está disponible en Web.'),
        ),
      );
      return;
    }
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    final newTitle = _titleController.text.trim();
    final newContent = _contentController.text.trim();
    if (newTitle.isEmpty || newContent.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    String? newImageUrl = _existingImageUrl;

    // Si seleccionó una imagen nueva, subimos y reemplazamos la URL:
    if (_pickedImage != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef =
          FirebaseStorage.instance.ref().child('news_images/$fileName');
      await storageRef.putFile(_pickedImage!);
      newImageUrl = await storageRef.getDownloadURL();
    }

    // Actualizamos el documento en Firestore:
    await _firestore.collection('news').doc(widget.documentId).update({
      'title': newTitle,
      'content': newContent,
      'category': _selectedCategory,
      'imageUrl': newImageUrl,
      'timestamp': FieldValue.serverTimestamp(), // refrescar timestamp
    });

    setState(() {
      _isSaving = false;
    });

    Navigator.of(context).pop(); // Regresa a la pantalla de administración
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Noticia (Admin)'),
        backgroundColor: Colors.blue.shade400,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),
                  const SizedBox(height: 16),

                  // Categoría
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCategory,
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Botón para seleccionar nueva imagen
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Seleccionar imagen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade200,
                    ),
                    onPressed: _isSaving ? null : _pickImage,
                  ),
                  const SizedBox(height: 16),

                  // Vista previa: si hay imagen nueva, muéstrala; si no, la URL existente:
                  if (_pickedImage != null)
                    if (kIsWeb)
                      Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Text(
                          'Vista previa no disponible en Web',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      Image.file(
                        _pickedImage!,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                  else if (_existingImageUrl != null)
                    Image.network(
                      _existingImageUrl!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  if (_pickedImage != null || _existingImageUrl != null)
                    const SizedBox(height: 16),

                  // Contenido
                  TextField(
                    controller: _contentController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Contenido de la noticia',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón Guardar Cambios
                  Center(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade200,
                      ),
                      child: const Text('Guardar Cambios'),
                    ),
                  ),
                ],
              ),
            ),

          // Loader superpuesto mientras guarda
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
    );
  }
}
