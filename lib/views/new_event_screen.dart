import 'package:eventos/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventos/models/event.dart'; // Tu modelo
import 'package:intl/intl.dart'; // Para fechas

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Variables de estado
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Charla'; // Valor por defecto
  bool _isLoading = false;

  // Las opciones fijas del requerimiento
  final FirestoreService _firestoreService = FirestoreService();
  List<String> _categories = [];
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    final loadedCategories = await _firestoreService.getCategoryNames();
    setState(() {
      _categories = loadedCategories;
      // Aseguramos que la categoría seleccionada por defecto sea la primera cargada
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }
    });
  }

  // Función para seleccionar Fecha y Hora
  Future<void> _pickDateTime() async {
    // 1. Elegir Fecha
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        // Personalizamos el calendario para que sea ROJO (Tema App)
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD32F2F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;

    // 2. Elegir Hora
    if (!mounted) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (time == null) return;

    // 3. Combinar Fecha + Hora
    setState(() {
      _selectedDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  // Función Guardar
  void _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 1. Crear el objeto Evento (Usando nuestro Modelo)
      final newEvent = Event(
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        date: _selectedDate,
        category: _selectedCategory,
        userId: user.uid, // Importante para saber quién lo creó
      );

      // 2. Guardar en Firebase (Colección 'events')
      await FirebaseFirestore.instance
          .collection('events')
          .add(newEvent.toMap());

      if (!mounted) return;

      // 3. Volver atrás y mostrar éxito
      Navigator.pop(context); // Cierra la pantalla
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Evento registrado en la Pokédex!"),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Evento")),
      body: Stack(
        children: [
          // FONDO: Mapa Pokemon
          Positioned.fill(
            child: Image.asset(
              "assets/images/new.jpg", // Asegúrate de tener esta imagen
              fit: BoxFit.cover,
            ),
          ),

          // FORMULARIO: Caja blanca flotante
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                // El Card ya tiene el estilo Retro definido en main.dart
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Título del Formulario
                        const Text(
                          "REGISTRAR MISIÓN",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2),
                        ),
                        const Divider(thickness: 2, color: Colors.black),
                        const SizedBox(height: 20),

                        // 1. TÍTULO
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                              labelText: "Título del Evento"),
                          validator: (value) =>
                              value!.isEmpty ? "Campo requerido" : null,
                        ),
                        const SizedBox(height: 16),

                        // 2. LUGAR
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                              labelText: "Lugar / Gimnasio"),
                          validator: (value) =>
                              value!.isEmpty ? "Campo requerido" : null,
                        ),
                        const SizedBox(height: 16),

                        // 3. CATEGORÍA (Dropdown)
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                              labelText: "Tipo de Evento"),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedCategory = value!),
                          validator: (value) =>
                              value == null ? "Seleccione una categoría" : null,
                        ),
                        const SizedBox(height: 16),

                        // 4. FECHA (Selector)
                        InkWell(
                          onTap: _pickDateTime,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Fecha y Hora",
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              DateFormat('dd/MM/yyyy HH:mm')
                                  .format(_selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 5. BOTÓN GUARDAR
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveEvent,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFFFDE00), // Amarillo
                              foregroundColor: Colors.black, // Texto negro
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                    color: Colors.black, width: 2),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text("GUARDAR DATOS",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
