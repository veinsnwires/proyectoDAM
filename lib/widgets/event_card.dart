import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String categoria;
  final String titulo;
  final String fecha;
  final String lugar;
  final String imagePath; // La ruta de la imagen (ej: assets/images/poke3.jpg)
  final VoidCallback onTap; // Qué pasa al tocarla

  const EventCard({
    super.key,
    required this.categoria,
    required this.titulo,
    required this.fecha,
    required this.lugar,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos Card para heredar el estilo "GameBoy" definido en main.dart
    return Card(
      // Clip.antiAlias hace que la imagen de fondo respete los bordes redondeados
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 120, // Altura fija para la tarjeta
          child: Stack(
            children: [
              // 1. IMAGEN DE FONDO
              Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,

                  // Si la imagen falla (ej: nombre incorrecto), mostramos un error visual controlado
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.grey);
                  },
                ),
              ),

              // 2. CAPA OSCURA (Para que se lea el texto)
              Positioned.fill(
                child: Container(
                  color: const Color.fromARGB(153, 0, 0, 0),
                ),
              ),

              // 3. TEXTOS
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      categoria, // Usamos la nueva propiedad
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.secondary, // Amarillo
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month,
                            color: Colors.yellow, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          fecha,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.yellow, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          lugar,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
