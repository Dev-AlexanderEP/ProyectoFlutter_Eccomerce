import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/core/services/login/AuthServiceImpl.dart';
import 'package:proyecto_flutter/data/RemoteRepositorie/login/LoginAuthRemoteRepositorie.dart';

import 'core/services/login/forgotPassword/ForgotPassImpl.dart';
import 'core/services/login/forgotPassword/IForgotPass.dart';
import 'data/RemoteRepositorie/login/forgotPassword/ForgotPassRemoteRepositorie.dart';
import 'features/auth/controllers/AuthController.dart';
import 'features/auth/pages/LoginPage.dart';
import 'package:http/http.dart' as http;


// void main() {
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//         create: (_) => AuthController(
//               authService: AuthServiceImpl(
//                   remoteDataSource: AuthRemoteRepositorie(
//                       client: http.Client(),
//                   ),
//
//               ),
//         ),
//         ),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

void main() {
  runApp(
    MultiProvider(
      providers: [
        // 1) Un único Client para toda la app
        Provider<http.Client>(
          create: (_) => http.Client(),
          dispose: (_, client) => client.close(), // importante
        ),

        // 2) Repos que reciben el Client inyectado
        Provider<AuthRemoteRepositorie>(
          create: (ctx) => AuthRemoteRepositorie(
            client: ctx.read<http.Client>(),
          ),
        ),
        // Ejemplo para forgot:
        Provider<ForgotPassRemoteRepositorie>(
          create: (ctx) => ForgotPassRemoteRepositorie(
            client: ctx.read<http.Client>(),
          ),
        ),

        // 3) Servicios que usan los repos
        Provider<AuthServiceImpl>(
          create: (ctx) => AuthServiceImpl(
            remoteDataSource: ctx.read<AuthRemoteRepositorie>(),
          ),
        ),
        Provider<IForgotPass>(
          create: (ctx) => ForgotPassImpl(
            remoteDataSource: ctx.read<ForgotPassRemoteRepositorie>(),
          ),
        ),

        // 4) Controllers que usan los servicios
        ChangeNotifierProvider<AuthController>(
          create: (ctx) => AuthController(
            authService: ctx.read<AuthServiceImpl>(),
            forgotPass: ctx.read<IForgotPass>(), // 👈 ahora sí pasamos el requerido

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
