import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class NewsDetailScreen extends StatefulWidget {
  final String documentId;
  const NewsDetailScreen({Key? key, required this.documentId}) : super(key: key);

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  bool _loading = true;
  String? _title, _content, _category, _externalUrl;
  Timestamp? _timestamp;
  String? _authorName;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _loadNewsDocument();
  }

  Future<void> _loadNewsDocument() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('news')
          .doc(widget.documentId)
          .get();

      if (!doc.exists) {
        setState(() => _loading = false);
        return;
      }

      final data = doc.data()!;
      setState(() {
        _title = data['title'] as String?;
        _content = data['content'] as String?;
        _category = data['category'] as String?;
        _timestamp = data['timestamp'] as Timestamp?;
        _externalUrl = data['externalUrl'] as String?;
        _authorName = data['authorName'] as String?;
        _date = _timestamp?.toDate();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _openExternalUrl() async {
    if (_externalUrl == null) return;
    final uri = Uri.parse(_externalUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault); // ✅ importante para web
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir la URL: $_externalUrl')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_title == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Noticia no encontrada')),
        body: const Center(child: Text('La noticia solicitada no existe.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_title!),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_category != null)
                  Chip(
                    label: Text(_category!),
                    backgroundColor: Colors.blue[100],
                  ),
                const SizedBox(width: 8),
                if (_date != null)
                  Text(
                    DateFormat('dd MMM yyyy').format(_date!),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
            if (_authorName != null) ...[
              const SizedBox(height: 8),
              Text(
                'Por $_authorName',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
            const SizedBox(height: 16),
            if (_content != null && _content!.isNotEmpty)
              Text(
                _content!,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            if (_externalUrl != null && _externalUrl!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Contenido externo:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _openExternalUrl,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('VER CONTENIDO COMPLETO'),
              ),
            ],
            if (_content == null && _externalUrl == null)
              const Text(
                'Esta noticia no tiene contenido disponible.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
