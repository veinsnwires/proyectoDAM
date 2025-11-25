import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:eventos/services/auth_service.dart';
import 'package:eventos/widgets/event_card.dart';
import 'package:eventos/models/event.dart';
import 'package:eventos/views/detail_screen.dart';

class Home extends StatefulWidget {
  final String title;
  const Home({super.key, required this.title});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _showOnlyMyEvents = false;
  final AuthService _auth = AuthService();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // APP BAR
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(
                _showOnlyMyEvents ? Icons.filter_alt : Icons.filter_alt_off),
            onPressed: () =>
                setState(() => _showOnlyMyEvents = !_showOnlyMyEvents),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await _auth.signOut(),
          ),
        ],
      ),

      // CUERPO
      body: Container(
        // Fondo con imagen repetida (Textura)
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/texture.jpg"),
            repeat: ImageRepeat.repeat,
          ),
        ),

        // LISTA CONECTADA A FIREBASE
        child: StreamBuilder<QuerySnapshot>(
          stream: _showOnlyMyEvents
              ? FirebaseFirestore.instance
                  .collection('events') // Nombre de colección en inglés
                  .where('userId', isEqualTo: currentUserId)
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection('events')
                  .orderBy('date', descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Error de conexión"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("No hay misiones registradas"),
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final event = Event.fromFirestore(doc);

                // Asignamos imagen manual según categoría (luego lo mejoraremos)
                String cardImage = 'assets/images/poke4.jpg';
                if (event.category == 'Charla') {
                  cardImage = 'assets/images/poke3.jpg';
                }
                if (event.category == 'Workshop') {
                  cardImage = 'assets/images/poke5.jpg';
                }

                return EventCard(
                  titulo: event.title,
                  fecha: DateFormat('dd/MM/yyyy HH:mm').format(event.date),
                  lugar: event.location,
                  categoria: event.category,
                  imagePath: cardImage,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailScreen(
                            event: event), // Pasamos el evento completo
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),

      // BOTÓN FLOTANTE (Sin navegación aún)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("Ir a crear evento (Próximamente)");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
