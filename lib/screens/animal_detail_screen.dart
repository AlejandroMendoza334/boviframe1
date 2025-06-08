import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AnimalDetailScreen extends StatefulWidget {
  final Map<String, dynamic> animalData;

  const AnimalDetailScreen({Key? key, required this.animalData}) : super(key: key);

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  late Map<String, double> epmuras;
  late Map<String, double> pesos;
  Map<String, double> epmurasPromedio = {};
  Map<String, double> pesosPromedio = {};

  @override
  void initState() {
    super.initState();
    _prepareData();
    _loadPromedios();
  }

  void _prepareData() {
    final rawE = widget.animalData['epmuras'] as Map<String, dynamic>? ?? {};
    epmuras = {
      for (var key in ['E', 'P', 'M', 'U', 'R', 'A', 'S'])
        key: double.tryParse(rawE[key]?.toString() ?? '') ?? 0.0
    };

    pesos = {
      'Nac.': double.tryParse(widget.animalData['peso_nac']?.toString() ?? '') ?? 0.0,
      'Dest.': double.tryParse(widget.animalData['peso_dest']?.toString() ?? '') ?? 0.0,
      'Ajus.': double.tryParse(widget.animalData['peso_ajus']?.toString() ?? '') ?? 0.0,
    };
  }

  Future<void> _loadPromedios() async {
    final sessionId = widget.animalData['sessionId'];
    if (sessionId == null) return;

    final docs = await FirebaseFirestore.instance
        .collection('sesiones')
        .doc(sessionId)
        .collection('evaluaciones_animales')
        .get();

    final epmurasSum = <String, double>{};
    final pesosSum = <String, double>{};
    int count = 0;

    for (final doc in docs.docs) {
      final data = doc.data();
      final epm = (data['epmuras'] as Map<String, dynamic>? ?? {});
      final pes = {
        'Nac.': double.tryParse(data['peso_nac']?.toString() ?? '') ?? 0.0,
        'Dest.': double.tryParse(data['peso_dest']?.toString() ?? '') ?? 0.0,
        'Ajus.': double.tryParse(data['peso_ajus']?.toString() ?? '') ?? 0.0,
      };

      for (var k in epmuras.keys) {
        epmurasSum[k] = (epmurasSum[k] ?? 0) + (double.tryParse(epm[k]?.toString() ?? '') ?? 0);
      }
      for (var k in pesos.keys) {
        pesosSum[k] = (pesosSum[k] ?? 0) + (pes[k] ?? 0);
      }
      count++;
    }

    if (count > 0) {
      setState(() {
        epmurasPromedio = {
          for (final key in epmuras.keys)
            key: (epmurasSum[key] ?? 0) / count
        };
        pesosPromedio = {
          for (final key in pesos.keys)
            key: (pesosSum[key] ?? 0) / count
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageBase64 = widget.animalData['image_base64'] as String?;
    Uint8List? image;
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        image = base64Decode(imageBase64);
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Animal'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(image, width: 240, height: 240, fit: BoxFit.cover),
              ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Datos Generales', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    const Divider(height: 24),
                    _infoRow('Número', widget.animalData['numero']),
                    _infoRow('Registro', widget.animalData['registro']),
                    _infoRow('Sexo', widget.animalData['sexo']),
                    _infoRow('Estado', widget.animalData['estado']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildRadarChart('Evaluación EPMURAS', epmuras, epmurasPromedio),
            const SizedBox(height: 20),
            _buildRadarChart('Pesos (kg)', pesos, pesosPromedio),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarChart(String title, Map<String, double> actual, Map<String, double> promedio) {
    final labels = actual.keys.toList();
    final actualEntries = labels.map((k) => RadarEntry(value: actual[k]!)).toList();
    final promedioEntries = labels.map((k) => RadarEntry(value: promedio[k] ?? 0)).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const Divider(height: 24),
            SizedBox(
              height: 200,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      fillColor: Colors.blue.withOpacity(0.3),
                      borderColor: Colors.blue,
                      entryRadius: 3,
                      dataEntries: actualEntries,
                    ),
                    RadarDataSet(
                      fillColor: Colors.orange.withOpacity(0.3),
                      borderColor: Colors.orange,
                      entryRadius: 3,
                      dataEntries: promedioEntries,
                    ),
                  ],
                  radarBackgroundColor: Colors.transparent,
                  radarBorderData: const BorderSide(color: Colors.grey),
                  titleTextStyle: const TextStyle(fontSize: 12, color: Colors.black87),
                  getTitle: (i, angle) => RadarChartTitle(text: labels[i], angle: angle),
                  tickCount: 5,
                  ticksTextStyle: const TextStyle(fontSize: 8, color: Colors.grey),
                  gridBorderData: const BorderSide(color: Colors.grey, width: 1),
                  tickBorderData: const BorderSide(color: Colors.grey, width: 1),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                LegendDot(color: Colors.blue, label: 'Animal'),
                SizedBox(width: 16),
                LegendDot(color: Colors.orange, label: 'Promedio'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, dynamic value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(flex: 4, child: Text('$title:', style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 6, child: Text(value?.toString() ?? '—')),
        ]),
      );
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const LegendDot({Key? key, required this.color, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
