import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> upsertReporte({
  required String docId,
  required Map<String, dynamic> fieldsStatics,
  required double valorActual,
  required int diaIndex,
}) async {
  final docRef = FirebaseFirestore.instance
      .collection('reportes')
      .doc(docId);

  final String claveDia = diaIndex.toString();

  final Map<String, dynamic> payload = {
    ...fieldsStatics,
    'valorActual': valorActual,
    'serieMensual': { claveDia: valorActual },
  };

  await docRef.set(payload, SetOptions(merge: true));
}
