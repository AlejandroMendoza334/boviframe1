import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> evaluaciones = [];
  int totalAnimales = 0;
  int totalSesiones = 0;
  Map<String, double> promedios = {};
  List<Map<String, dynamic>> topAnimales = [];
  List<Map<String, dynamic>> bottomAnimales = [];

  @override
  void initState() {
    super.initState();
    cargarEvaluaciones();
  }

  Future<void> cargarEvaluaciones() async {
    try {
      final sesionesSnapshot = await FirebaseFirestore.instance
          .collection('sesiones')
          .get();

      final List<Map<String, dynamic>> todosLosDatos = [];
      for (final sesDoc in sesionesSnapshot.docs) {
        final evals = await FirebaseFirestore.instance
            .collection('sesiones')
            .doc(sesDoc.id)
            .collection('evaluaciones_animales')
            .get();
        todosLosDatos.addAll(evals.docs.map((e) => e.data()));
      }

      final datos = todosLosDatos;
      final letras = ['E', 'P', 'M', 'U', 'R', 'A', 'S'];
      final nuevosPromedios = {for (var l in letras) l: 0.0};
      for (var l in letras) {
        nuevosPromedios[l] = datos
                .map((e) {
                  final v = e['epmuras']?[l];
                  return v is num
                      ? v.toDouble()
                      : double.tryParse(v?.toString() ?? '0') ?? 0;
                })
                .fold(0.0, (a, b) => a + b) /
            (datos.isEmpty ? 1 : datos.length);
      }

      final evalsConIndice = datos.map((animal) {
        final e = double.tryParse('${animal['epmuras']?['E']}') ?? 0;
        final p = double.tryParse('${animal['epmuras']?['P']}') ?? 0;
        final m = double.tryParse('${animal['epmuras']?['M']}') ?? 0;
        return {
          ...animal,
          'indice': e + p + m,
          'numero': animal['numero'] ?? '-',
        };
      }).toList()
        ..sort((a, b) =>
            (b['indice'] as double).compareTo(a['indice'] as double));

      if (!mounted) return;
      setState(() {
        evaluaciones = evalsConIndice;
        totalAnimales = datos.length;
        totalSesiones = sesionesSnapshot.docs.length;
        promedios = nuevosPromedios;
        topAnimales = evalsConIndice.take(3).toList();
        bottomAnimales = evalsConIndice.reversed.take(3).toList();
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('❌ Error al cargar evaluaciones: $e');
      setState(() => evaluaciones = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: evaluaciones.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCard(
                              title: 'Animales Evaluados',
                              value: '$totalAnimales',
                              color: Colors.deepPurple,
                            ),
                            _buildCard(
                              title: 'Total de Sesiones',
                              value: '$totalSesiones',
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Promedios EPMURAS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildDonutGrid(),
                            const SizedBox(height: 20),
                            const Text(
                              'Top 3 Mejores Animales',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            ...topAnimales.map(_buildAnimalCard),
                            const SizedBox(height: 20),
                            const Text(
                              'Top 3 Peores Animales',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            ...bottomAnimales.map(_buildAnimalCard),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
      width: double.infinity,
      color: Colors.blue[800],
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Dashboard General',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'Resumen de evaluaciones realizadas',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          radius: 20,
          child: Image.asset(
            'assets/icons/logo1.png',
            width: 24,
            height: 24,
            color: Colors.white,
          ),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildAnimalCard(Map<String, dynamic> a) {
    // Foto si existe
    Uint8List? fotoBytes;
    final base64img = a['image_base64'];
    if (base64img is String && base64img.isNotEmpty) {
      try {
        fotoBytes = base64Decode(base64img);
      } catch (_) {}
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[200],
          backgroundImage: fotoBytes != null ? MemoryImage(fotoBytes) : null,
          child: fotoBytes == null
              ? const Icon(Icons.pets, color: Colors.deepPurple)
              : null,
        ),
        title: Text(
          a['numero']?.toString() ?? '-',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Índice: ${(a['indice'] as double).toStringAsFixed(1)}',
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/animal_detail',
            arguments: a,
          );
        },
      ),
    );
  }

  Widget _buildDonutGrid() {
    const int cols = 3;
    const gutter = 24.0;
    const donutSize = 70.0;
    final rows = (promedios.length / cols).ceil();

    return SizedBox(
      height: rows * donutSize + (rows - 1) * gutter,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: cols,
        mainAxisSpacing: gutter,
        crossAxisSpacing: gutter,
        padding: EdgeInsets.zero,
        children: promedios.entries.map((e) {
          return _buildDonut(
            letra: e.key,
            avg: e.value,
            size: donutSize,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDonut({
    required String letra,
    required double avg,
    required double size,
  }) {
    const maxVal = 7.0;
    final rem = (maxVal - avg).clamp(0.0, maxVal);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              centerSpaceRadius: size * 0.28,
              sectionsSpace: 0,
              sections: [
                PieChartSectionData(
                  value: avg,
                  color: Colors.deepPurple.withOpacity(0.8),
                  showTitle: false,
                  radius: size * 0.34,
                ),
                PieChartSectionData(
                  value: rem,
                  color: Colors.grey.shade300,
                  showTitle: false,
                  radius: size * 0.34,
                ),
              ],
            ),
            swapAnimationDuration: const Duration(milliseconds: 400),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                letra,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.18,
                ),
              ),
              Text(
                avg.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: size * 0.14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
