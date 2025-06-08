import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_database/firebase_database.dart' as rtdb;
import 'package:flutter/foundation.dart';

class DatabaseService {
  // Firestore (tu implementación actual)
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;
  
  // Realtime Database (nueva implementación)
  final rtdb.DatabaseReference _rtdb = rtdb.FirebaseDatabase.instance.ref();

  // ========== Métodos para Firestore ==========
  Future<String?> saveAnimal(Map<String, dynamic> animalData) async {
    try {
      await _firestore.collection('animals').add(animalData);
      return null;
    } on firestore.FirebaseException catch (e) {
      debugPrint('Error al guardar en Firestore: ${e.code} - ${e.message}');
      return e.message;
    }
  }

  Stream<firestore.QuerySnapshot> getAnimals({String? upId, int limit = 10}) {
    firestore.Query query = _firestore.collection('animals').limit(limit);
    if (upId != null) query = query.where('up_id', isEqualTo: upId);
    return query.snapshots();
  }

  Future<void> deleteAnimal(String animalId) async {
    await _firestore.collection('animals').doc(animalId).delete();
  }

  // ========== Métodos para Realtime Database ==========
  Future<String?> saveEvaluationRTDB(Map<String, dynamic> evaluationData) async {
    try {
      await _rtdb.child('evaluaciones').push().set(evaluationData);
      return null;
    } catch (e) {
      debugPrint('Error al guardar en RTDB: $e');
      return e.toString();
    }
  }

  Stream<rtdb.DatabaseEvent> getEvaluationsRTDB() {
    return _rtdb.child('evaluaciones').onValue;
  }

  Future<void> deleteEvaluationRTDB(String evaluationId) async {
    await _rtdb.child('evaluaciones/$evaluationId').remove();
  }

  // ========== Métodos combinados ==========
  Future<String?> saveAnimalWithEvaluation({
    required Map<String, dynamic> animalData,
    required Map<String, dynamic> evaluationData,
  }) async {
    try {
      // Primero guarda en Firestore
      final docRef = await _firestore.collection('animals').add(animalData);
      
      // Luego guarda en RTDB con referencia al ID de Firestore
      await _rtdb.child('evaluaciones/${docRef.id}').set({
        ...evaluationData,
        'animal_id': docRef.id,
        'created_at': rtdb.ServerValue.timestamp,
      });
      
      return null;
    } catch (e) {
      debugPrint('Error en operación combinada: $e');
      return e.toString();
    }
  }
}