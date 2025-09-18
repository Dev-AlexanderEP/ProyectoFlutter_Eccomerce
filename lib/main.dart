import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/core/services/login/AuthServiceImpl.dart';
import 'package:proyecto_flutter/data/RemoteRepositorie/login/LoginAuthRemoteRepositorie.dart';

import 'features/auth/controllers/AuthController.dart';
import 'features/auth/pages/LoginPage.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
        create: (_) => AuthController(
              authService: AuthServiceImpl(
                  remoteDataSource: AuthRemoteRepositorie(
                      client: http.Client(),
                  ),
              ),
        ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Poppins', // 👈 aquí la fuente global
      ),
      home: LoginPage(title: 'Inicio de sesion',),
    );
  }
}
