import 'package:flutter/material.dart';
import 'package:eventos/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    // Call our service
    await AuthService().signInWithGoogle();

    // We don't need to navigate manually.
    // The Stream in main.dart will detect the change and switch screens automatically.

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // LAYER 1: Background Image (Squirtle)
          Positioned.fill(
            child: Image.asset(
              'assets/images/ingreso.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // LAYER 2: Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title Box (Pixel style)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(4, 4))
                      ]),
                  child: const Text(
                    "POKÉVENTOS",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Google Login Button
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : SizedBox(
                        width: 250,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _handleGoogleLogin,
                          icon: const Icon(Icons.login, color: Colors.black),
                          label: const Text(
                            "Entrar con Google",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondary, // Yellow
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                  color: Colors.black, width: 2),
                            ),
                            elevation: 6,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
