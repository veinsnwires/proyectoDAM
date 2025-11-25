// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:eventos/models/event.dart';
import 'package:eventos/services/firestore_service.dart'; // Tu servicio de borrado

// Instancia del servicio de borrado
final FirestoreService firestoreService = FirestoreService();

class EventDetailScreen extends StatelessWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  // --- Lógica de borrado extraída del widget ---
  void _deleteEventConfirmed(BuildContext context) async {
    try {
      // 1. Llamada al servicio de borrado
      await firestoreService.deleteEvent(event.id);

      // 2. Navegar de vuelta al Home (sale del detalle)
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("¡Evento eliminado con éxito!"),
            backgroundColor: Color(0xFFD32F2F)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text("Fallo al borrar: No se pudo conectar."),
            backgroundColor: Colors.red),
      );
    }
  }

  // Diálogo de confirmación (Llama a la función de borrado)
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar Borrado"),
        content: const Text("¿Estás seguro de querer borrar esta misión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Cierra el diálogo
              _deleteEventConfirmed(context); // Ejecuta la función de borrado
            },
            child: const Text("Borrar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  // ---------------------------------------------

  // Widget helper para las filas de detalle (igual que antes)
  Widget _buildDetailRow(IconData icon, String label, String value) {
    // ... (Tu código de _buildDetailRow, que ya funciona, se mantiene igual) ...
    // [Este helper no necesita ser modificado]
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String cardImage = 'assets/images/default.jpg';
    if (event.category == 'Charla') {
      cardImage = 'assets/images/charla.jpg';
    }
    if (event.category == 'Workshop') {
      cardImage = 'assets/images/workshop.jpg';
    }
    if (event.category == 'Coloquio') {
      cardImage = 'assets/images/coloquio.jpg';
    }

    final isAuthor = FirebaseAuth.instance.currentUser?.uid == event.userId;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(event.title),
        actions: [
          if (isAuthor)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.yellow),
              onPressed: () =>
                  _showDeleteConfirmation(context), // Llama al diálogo
            ),
        ],
      ),
      body: Stack(
        children: [
          // FONDO (IMAGEN + OPACIDAD)
          Positioned.fill(
            child: Image.asset(cardImage, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: const Color.fromARGB(153, 0, 0, 0)),
          ),

          // CONTENIDO
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20.0,
                    20.0,
                    20.0,
                    MediaQuery.of(context).padding.bottom + 20.0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // TÍTULO Y CATEGORÍA
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 5, color: Colors.black)
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Categoría: ${event.category}",
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Divider(
                          color: Colors.grey,
                          thickness: 1,
                          height: 40,
                        ),

                        // DETALLES
                        _buildDetailRow(Icons.calendar_month, "Fecha y Hora",
                            DateFormat('dd/MM/yyyy HH:mm').format(event.date)),
                        _buildDetailRow(
                            Icons.location_on, "Lugar", event.location),
                        _buildDetailRow(Icons.person, "Autor ID", event.userId),

                        // ESPACIO PARA FORZAR EL LLENADO
                        const SizedBox(height: 1), // Pequeño espaciador
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
