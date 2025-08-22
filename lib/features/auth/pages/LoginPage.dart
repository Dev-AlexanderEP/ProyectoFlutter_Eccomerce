import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: userController,
              decoration: InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: passController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                bool logged = await authController.login(
                  userController.text,
                  passController.text,
                );
                if (logged) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('¡Bienvenido!')));
                  // navega a la siguiente pantalla
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error de login')));
                }
              },
              child: Text("Iniciar sesión"),
            ),
          ],
        ),
      ),
    );
  }
}