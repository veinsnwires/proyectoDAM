import 'package:eventos/views/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:eventos/views/login_screen.dart'; // Importa login
import 'package:eventos/services/auth_service.dart'; // Importa servicio
import 'package:firebase_auth/firebase_auth.dart'; // Importa firebase user

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokéventos',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Courier',

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD32F2F), // Rojo Pokédex
          primary: const Color(0xFFD32F2F),
          secondary: const Color(0xFFFFDE00), // Amarillo UI
          surface: const Color(0xFFF8F9FA), // Background
          onSurface: const Color(0xFF212121), // Color del texto sobre el fondo
        ),

        // 1. APP BAR
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          shape: Border(bottom: BorderSide(color: Colors.black, width: 2)),
        ),

        // 2. CORRECCIÓN 2: CARD THEME
        // Si te sigue dando error aquí, avísame, pero con la sintaxis estándar debería funcionar.
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            side: BorderSide(color: Colors.black, width: 2),
          ),
        ),

        // 3. INPUTS
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          // 1. Si está esperando respuesta, pantalla de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Si hay datos (usuario existe), vamos al HOME
          if (snapshot.hasData) {
            return const Home(title: 'Pokéventos');
          }

          // 3. Si no hay datos, vamos al LOGIN
          return const LoginScreen();
        },
      ),
    );
  }
}
