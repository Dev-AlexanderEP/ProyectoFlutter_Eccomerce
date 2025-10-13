import 'package:flutter/material.dart';
import '../../core/utils/SplashScreen.dart';
import '../../features/auth/pages/LoginPage.dart';
import '../../features/auth/pages/RegisterPage.dart';
import '../../features/auth/pages/VerificationPage.dart';
import '../../features/onboarding/pages/OnboardingPages.dart';

class AppRoutes {
  // Nombres de rutas
  static const String login = '/login';
  static const String register = '/register';
  static const String verification = '/verification';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String splash = '/splash';


  // Mapa de rutas
  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(title: 'Inicio de sesión'),
    register: (context) => const RegisterPage(),
    verification: (context) => const VerificationPage(),
    onboarding: (context) => const OnboardingPages(),
    splash: (context) => const SplashScreen(),
  };

  // Ruta inicial
  static const String initialRoute = splash;


  // Método para navegación
  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  // Método para navegación reemplazando la ruta actual
  static void navigateToReplacement(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  // Método para navegación eliminando todas las rutas anteriores
  static void navigateToAndClearStack(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context, 
      routeName, 
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  // Método para retroceder
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
