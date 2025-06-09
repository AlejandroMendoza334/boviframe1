import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  /// Genera y comparte/descarga el PDF de la evaluación de un animal.
  /// Recupera aquí directamente usuario desde Firestore.
  static Future<void> generateAnimalPdf(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    // 1) Leer userId de la sesión y luego usuario
    String userName = '—', userEmail = '—', userCompany = '—';
    final sid = data['sessionId'] as String?;
    if (sid != null) {
      final sessSnap =
          await FirebaseFirestore.instance
              .collection('sesiones')
              .doc(sid)
              .get();
      final uid = sessSnap.data()?['userId'] as String?;
      if (uid != null) {
        final userSnap =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(uid)
                .get();
        final u = userSnap.data();
        userName = u?['nombre'] ?? userName;
        userEmail = u?['email'] ?? userEmail;
        userCompany = u?['profesion'] ?? userCompany;
      }
    }

    // 2) Carga logo
    final logoBytes =
        (await rootBundle.load(
          'assets/icons/logoapp2.png',
        )).buffer.asUint8List();

    // 3) Decodifica foto base64
    Uint8List? fotoBytes;
    final b64 = data['image_base64'] as String?;
    if (b64?.isNotEmpty ?? false) {
      fotoBytes = base64Decode(b64!);
    }

    // 4) Carga datos del productor
    Map<String, dynamic>? producer;
    if (sid != null) {
      final prodSnap =
          await FirebaseFirestore.instance
              .collection('sesiones')
              .doc(sid)
              .collection('datos_productor')
              .limit(1)
              .get();
      if (prodSnap.docs.isNotEmpty) producer = prodSnap.docs.first.data();
    }

    // 5) Recalcula promedio de epmuras en sesión
    final promedio = <String, double>{};
    if (sid != null) {
      final docs =
          await FirebaseFirestore.instance
              .collection('sesiones')
              .doc(sid)
              .collection('evaluaciones_animales')
              .get();
      final sums = <String, double>{
        for (var k in (data['epmuras'] as Map).keys) k: 0.0,
      };
      for (var d in docs.docs) {
        final mp = d.data()['epmuras'] as Map<String, dynamic>? ?? {};
        mp.forEach((k, v) {
          sums[k] = sums[k]! + (double.tryParse(v.toString()) ?? 0.0);
        });
      }
      if (docs.docs.isNotEmpty) {
        sums.forEach((k, v) {
          promedio[k] = v / docs.docs.length;
        });
      }
    }

    // 6) Construye el PDF
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(32),
        pageFormat: PdfPageFormat.a4,
        build:
            (context) => [
              // Logo y cabecera
              pw.Center(child: pw.Image(pw.MemoryImage(logoBytes), width: 120)),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.blue, thickness: 2),
              pw.SizedBox(height: 12),

              // Usuario
              pw.Text(
                'Usuario:',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('• Nombre:    $userName'),
              pw.Text('• Correo:    $userEmail'),
              pw.Text('• Empresa:   $userCompany'),
              pw.SizedBox(height: 16),

              // Productor
              if (producer != null) ...[
                pw.Text(
                  'Productor:',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                for (var e in producer.entries)
                  pw.Text('• ${_capitalize(e.key)}: ${e.value}'),
                pw.SizedBox(height: 16),
              ],

              // Foto + datos generales
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (fotoBytes != null)
                    pw.Image(
                      pw.MemoryImage(fotoBytes),
                      width: 200,
                      height: 200,
                      fit: pw.BoxFit.cover,
                    )
                  else
                    pw.Container(
                      width: 200,
                      height: 200,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey),
                      ),
                    ),
                  pw.SizedBox(width: 16),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      for (var field in [
                        'numero',
                        'registro',
                        'sexo',
                        'estado',
                        'fecha_nac',
                        'fecha_dest',
                        'peso_nac',
                        'peso_dest',
                        'peso_ajus',
                        'edad_dias',
                      ])
                        pw.Text('${_capitalize(field)}: ${data[field] ?? '—'}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Tabla EPMURAS
              pw.Header(level: 1, text: 'Resultados EPMURAS'),
              pw.Table.fromTextArray(
                headers: ['Letra', 'Valor', 'Promedio Sesión'],
                data:
                    (data['epmuras'] as Map<String, dynamic>).entries.map((e) {
                      final prom =
                          promedio[e.key]?.toStringAsFixed(2) ?? '0.00';
                      return [e.key, e.value.toString(), prom];
                    }).toList(),
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey200),
              ),

              pw.SizedBox(height: 24),
              pw.Divider(color: PdfColors.blue, thickness: 2),
              pw.Center(child: pw.Image(pw.MemoryImage(logoBytes), width: 100)),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Generado: ${DateTime.now().toString().split('.').first}',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
                ),
              ),
            ],
      ),
    );

    // 7) Comparte o descarga
    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'evaluacion_animal_${data['numero']}.pdf',
    );
  }

  static String _capitalize(String s) => s
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}
