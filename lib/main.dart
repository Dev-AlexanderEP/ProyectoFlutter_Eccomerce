import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/core/services/login/AuthServiceImpl.dart';
import 'package:proyecto_flutter/data/RemoteRepositorie/login/LoginAuthRemoteRepositorie.dart';
import 'core/services/login/IAuthService.dart';
import 'core/services/login/forgotPassword/ForgotPassImpl.dart';
import 'core/services/login/forgotPassword/IForgotPass.dart';
import 'core/services/register/IRegisterService.dart';
import 'core/services/register/RegisterServiceImpl.dart';
import 'core/routes/app_routes.dart';
import 'data/RemoteRepositorie/login/forgotPassword/ForgotPassRemoteRepositorie.dart';
import 'data/RemoteRepositorie/register/RegisterRemoteRepository.dart';
import 'features/auth/controllers/AuthController.dart';
import 'package:http/http.dart' as http;



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
        Provider<ForgotPassRemoteRepositorie>(
          create: (ctx) => ForgotPassRemoteRepositorie(
            client: ctx.read<http.Client>(),
          ),
        ),
        Provider<RegisterRemoteRepository>(
          create: (ctx) => RegisterRemoteRepository(
            client: ctx.read<http.Client>(),
          ),
        ),

        // 3) Servicios que usan los repos
        Provider<IAuthService>(
          create: (ctx) => AuthServiceImpl(
            remoteDataSource: ctx.read<AuthRemoteRepositorie>(),
          ),
        ),
        Provider<IForgotPass>(
          create: (ctx) => ForgotPassImpl(
            remoteDataSource: ctx.read<ForgotPassRemoteRepositorie>(),
          ),
        ),
        Provider<IRegisterService>(
          create: (ctx) => RegisterServiceImpl(
            remoteDataSource: ctx.read<RegisterRemoteRepository>(),
          ),
        ),

        // 4) Controllers que usan los servicios
        ChangeNotifierProvider<AuthController>(
          create: (ctx) => AuthController(
            authService: ctx.read<IAuthService>(),
            forgotPass: ctx.read<IForgotPass>(),
            registerService: ctx.read<IRegisterService>(),
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
      title: 'Mix&Match E-commerce',
      theme: ThemeData(
        fontFamily: 'Poppins', // 👈 aquí la fuente global
      ),
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
