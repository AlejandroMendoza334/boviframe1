import 'dart:convert';
import 'dart:math';
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
    final sesionesSnapshot =
        await FirebaseFirestore.instance.collection('sesiones').get();
    final todosDatos = <Map<String, dynamic>>[];

    // Añadimos sessionId a cada evaluación
    for (final ses in sesionesSnapshot.docs) {
      final evals = await ses.reference
          .collection('evaluaciones_animales')
          .get();
      for (final e in evals.docs) {
        todosDatos.add({
          ...e.data(),
          'sessionId': ses.id, // ← Aquí inyectamos el ID de sesión
        });
      }
    }

    const letras = ['E', 'P', 'M', 'U', 'R', 'A', 'S'];
    final nuevosProm = {for (var l in letras) l: 0.0};
    for (var l in letras) {
      final suma = todosDatos.fold<double>(
        0.0,
        (sum, animal) {
          final v = animal['epmuras']?[l];
          return sum +
              (v is num
                  ? v.toDouble()
                  : double.tryParse(v?.toString() ?? '') ?? 0.0);
        },
      );
      nuevosProm[l] = todosDatos.isEmpty ? 0.0 : suma / todosDatos.length;
    }

    final listaIndice = todosDatos.map((animal) {
      final e = double.tryParse('${animal['epmuras']?['E']}') ?? 0;
      final p = double.tryParse('${animal['epmuras']?['P']}') ?? 0;
      final m = double.tryParse('${animal['epmuras']?['M']}') ?? 0;
      return {
        ...animal,
        'indice': e + p + m,
        'numero': animal['numero'] ?? '-',
        // sessionId ya viene incluido
      };
    }).toList()
      ..sort((a, b) =>
          (b['indice'] as double).compareTo(a['indice'] as double));

    if (!mounted) return;
    setState(() {
      evaluaciones = listaIndice;
      totalAnimales = todosDatos.length;
      totalSesiones = sesionesSnapshot.docs.length;
      promedios = nuevosProm;
      topAnimales = listaIndice.take(3).toList();
      bottomAnimales = listaIndice.reversed.take(3).toList();
    });
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
                              color: const Color(0xFF2EC4B6),
                            ),
                            _buildCard(
                              title: 'Total de Sesiones',
                              value: '$totalSesiones',
                              color: const Color(0xFF4A90E2),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Promedios EPMURAS',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            _buildBarChart(),
                            const SizedBox(height: 20),
                            const Text(
                              'Top 3 Mejores Animales',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            ...topAnimales.map((a) => _buildAnimalCard(a)),
                            const SizedBox(height: 20),
                            const Text(
                              'Top 3 Peores Animales',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            ...bottomAnimales.map((a) => _buildAnimalCard(a)),
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

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
        color: Colors.blue[800],
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dashboard General',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Resumen de evaluaciones realizadas',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildCard({
    required String title,
    required String value,
    required Color color,
  }) =>
      Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color,
            radius: 20,
            child: const Icon(Icons.pets, color: Colors.white),
          ),
          title: Text(title),
          trailing: Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      );

  Widget _buildAnimalCard(Map<String, dynamic> a) {
    Uint8List? foto;
    final base = a['image_base64'] as String?;
    if (base != null && base.isNotEmpty) foto = base64Decode(base);
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[200],
          backgroundImage: foto != null ? MemoryImage(foto) : null,
        ),
        title: Text(a['numero']?.toString() ?? '-',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            'Índice: ${(a['indice'] as double).toStringAsFixed(1)}'),
        onTap: () => Navigator.pushNamed(
          context,
          '/animal_detail',
          arguments: a, // ahora incluye sessionId dentro
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    const letras = ['E', 'P', 'M', 'U', 'R', 'A', 'S'];
    final valores = letras.map((l) => promedios[l] ?? 0.0).toList();
    final maxY = ((valores.isEmpty ? 0.0 : valores.reduce(max)) + 2).toDouble();
    final interval = (maxY / 4).toDouble();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade600,
              strokeWidth: 1.5,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= letras.length) return const SizedBox();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(letras[idx],
                        style: const TextStyle(
                            color: Color(0xFF3AC8F0),
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final text = value == maxY
                      ? value.toStringAsFixed(1)
                      : value.toStringAsFixed(0);
                  return Text(text,
                      style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold));
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.transparent,
              tooltipPadding: EdgeInsets.zero,
              tooltipMargin: 0,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toStringAsFixed(1),
                  const TextStyle(
                      color: Color(0xFF3AC8F0),
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          barGroups: List.generate(valores.length, (i) {
            return BarChartGroupData(
              x: i,
              showingTooltipIndicators: [0],
              barRods: [
                BarChartRodData(
                  toY: valores[i],
                  width: 10,
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFF3AC8F0), Color(0xFF0CA7E1)],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
