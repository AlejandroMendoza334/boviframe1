import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import '../../services/pdf_service.dart';
import 'providers/settings_provider.dart';

class AnimalDetailScreen extends StatefulWidget {
  final Map<String, dynamic> animalData;
  const AnimalDetailScreen({Key? key, required this.animalData})
    : super(key: key);

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  late Map<String, double> epmuras;
  late Map<String, double> pesos;
  Map<String, double> epmurasPromedio = {};
  Map<String, double> pesosPromedio = {};
  Map<String, dynamic>? _producerData;

  @override
  void initState() {
    super.initState();
    _prepareData();
    _loadPromedios();
    _loadProducer();
  }

  void _prepareData() {
    final rawE = (widget.animalData['epmuras'] as Map<String, dynamic>?) ?? {};
    epmuras = {
      for (var k in ['E', 'P', 'M', 'U', 'R', 'A', 'S'])
        k: double.tryParse(rawE[k]?.toString() ?? '0') ?? 0.0,
    };
    pesos = {
      'Nac.':
          double.tryParse(widget.animalData['peso_nac']?.toString() ?? '0') ??
          0.0,
      'Dest.':
          double.tryParse(widget.animalData['peso_dest']?.toString() ?? '0') ??
          0.0,
      'Ajus.':
          double.tryParse(widget.animalData['peso_ajus']?.toString() ?? '0') ??
          0.0,
    };
  }

  Future<void> _loadPromedios() async {
    final sid = widget.animalData['sessionId'] as String?;
    if (sid == null) return;
    final docs =
        await FirebaseFirestore.instance
            .collection('sesiones')
            .doc(sid)
            .collection('evaluaciones_animales')
            .get();
    final epmSum = {for (var k in epmuras.keys) k: 0.0};
    final pesSum = {for (var k in pesos.keys) k: 0.0};
    final cnt = docs.docs.length;
    for (var d in docs.docs) {
      final m = d.data();
      final rawE = (m['epmuras'] as Map<String, dynamic>?) ?? {};
      epmSum.forEach((k, _) {
        epmSum[k] =
            epmSum[k]! + (double.tryParse(rawE[k]?.toString() ?? '0') ?? 0.0);
      });
      pesSum.forEach((k, _) {
        pesSum[k] =
            pesSum[k]! +
            (double.tryParse(m['peso_${k.toLowerCase()}']?.toString() ?? '0') ??
                0.0);
      });
    }
    if (cnt > 0) {
      setState(() {
        epmurasPromedio = {for (var k in epmSum.keys) k: epmSum[k]! / cnt};
        pesosPromedio = {for (var k in pesSum.keys) k: pesSum[k]! / cnt};
      });
    }
  }

  Future<void> _loadProducer() async {
    final sid = widget.animalData['sessionId'] as String?;
    if (sid == null) return;
    final snap =
        await FirebaseFirestore.instance
            .collection('sesiones')
            .doc(sid)
            .collection('datos_productor')
            .limit(1)
            .get();
    if (snap.docs.isNotEmpty) {
      _producerData = snap.docs.first.data();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    Uint8List? img;
    final b64 = widget.animalData['image_base64'] as String?;
    if (b64?.isNotEmpty ?? false) img = base64Decode(b64!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Animal'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (img != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  img,
                  width: 240,
                  height: 240,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Datos Generales',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                debugPrint('▶️ animalData para PDF: ${widget.animalData}');
                PdfService.generateAnimalPdf(
                  context, // <-- pasamos el context
                  widget.animalData, // <-- y los datos del animal
                );
              },
              icon: const Icon(Icons.picture_as_pdf, size: 20),
              label: const Text('Descargar PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(flex: 6, child: Text(value?.toString() ?? '—')),
      ],
    ),
  );

  Widget _buildRadarChart(
    String title,
    Map<String, double> actual,
    Map<String, double> promedio,
  ) {
    final labels = actual.keys.toList();
    final actualEntries =
        labels.map((k) => RadarEntry(value: actual[k]!)).toList();
    final promEntries =
        labels.map((k) => RadarEntry(value: promedio[k] ?? 0.0)).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
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
                      dataEntries: promEntries,
                    ),
                  ],
                  radarBackgroundColor: Colors.transparent,
                  radarBorderData: const BorderSide(color: Colors.grey),
                  titleTextStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                  getTitle:
                      (i, angle) =>
                          RadarChartTitle(text: labels[i], angle: angle),
                  tickCount: 5,
                  ticksTextStyle: const TextStyle(
                    fontSize: 8,
                    color: Colors.grey,
                  ),
                  gridBorderData: const BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                  tickBorderData: const BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                LegendDot(color: Colors.blue, label: 'Animal Eval.'),
                SizedBox(width: 16),
                LegendDot(color: Colors.orange, label: 'Promedio Sesión'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const LegendDot({Key? key, required this.color, required this.label})
    : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
