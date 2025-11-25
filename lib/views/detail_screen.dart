import 'package:flutter/material.dart';
import 'package:eventos/models/event.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // NECESARIO para obtener el UID del usuario

class EventDetailScreen extends StatelessWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  // Función para confirmar el borrado (Implementación de la lógica de borrado real va después)
  void _confirmDelete(BuildContext context) {
    // Esto muestra el diálogo de confirmación (Requerimiento)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar Borrado"),
        content: const Text("¿Estás seguro de querer borrar esta misión?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              // Lógica de borrado real (pendiente para el Bloque 5)
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Evento borrado (lógica pendiente)")),
              );
            },
            child: const Text("Borrar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lógica para obtener la imagen de fondo y el UID
    String cardImage = 'assets/images/poke4.jpg'; // Default
    if (event.category == 'Charla') cardImage = 'assets/images/poke3.jpg';
    if (event.category == 'Workshop') cardImage = 'assets/images/poke5.jpg';
    if (event.category == 'Coloquio') cardImage = 'assets/images/poke6.jpg';

    // 2. Determinar si el usuario logueado es el autor del evento
    final isAuthor = FirebaseAuth.instance.currentUser?.uid == event.userId;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(event.title),
        actions: [
          // Botón BORRAR (Solo visible si el usuario es el autor)
          if (isAuthor)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.yellow),
              onPressed: () {
                _confirmDelete(context);
              },
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
                  padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0,
                      MediaQuery.of(context).padding.bottom + 20.0),
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
                              ]),
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
                            color: Colors.grey, thickness: 1, height: 40),

                        // DETALLES
                        _buildDetailRow(Icons.calendar_month, "Fecha y Hora",
                            DateFormat('dd/MM/yyyy HH:mm').format(event.date)),
                        _buildDetailRow(
                            Icons.location_on, "Lugar", event.location),
                        _buildDetailRow(Icons.person, "Autor ID", event.userId),

                        const SizedBox(
                          height: 400,
                        )
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

  // Widget helper para las filas de detalle (estilo retro)
  Widget _buildDetailRow(IconData icon, String label, String value) {
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
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
