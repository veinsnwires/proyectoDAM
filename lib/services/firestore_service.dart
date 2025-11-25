import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Necesario para debugPrint

class FirestoreService {
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

  // --- 1. Método para Borrar Eventos (Bloque 5) ---
  Future<void> deleteEvent(String eventId) async {
    try {
      // Requerimiento: Borrar el documento de la colección 'events'
      await eventsCollection.doc(eventId).delete();
      debugPrint("Evento con ID $eventId eliminado de Firestore.");
    } catch (e) {
      debugPrint("Error al intentar borrar el evento: $e");
      rethrow;
    }
  }

  // --- 2. Método para Obtener Categorías (Corrección Bloque 4) ---
  // Requerimiento: Cargar la lista de categorías desde Firebase.
  Future<List<String>> getCategoryNames() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      // Mapeamos los documentos para obtener solo el campo 'name'
      return querySnapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      // Respaldo de la lista codificada en caso de error, aunque lo ideal es que funcione la base de datos
      return ['Charla', 'Coloquio', 'Workshop'];
    }
  }
}
