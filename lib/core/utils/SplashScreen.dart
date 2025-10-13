// lib/features/splash/pages/splash_screen.dart
import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../theme/type.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      AppRoutes.navigateToReplacement(context, AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _SplashView();
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido centrado
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título "Mix&Match" con KiwiFruit
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Mix',
                          style: AppTypography.fancy.copyWith(
                            fontSize: 56,
                            height: 1.0,
                            color: Colors.red,
                          ),
                        ),
                        TextSpan(
                          text: '&Match',
                          style: AppTypography.fancy.copyWith(
                            fontSize: 56,
                            height: 1.0,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Subtítulos en Poppins
                  Text(
                    'Inspírate, crea y luce tu mejor versión.',
                    style: AppTypography.body.copyWith(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¡Comienza a mezclar y combinar!',
                    style: AppTypography.body.copyWith(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Versión abajo centrado
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Text(
                'Version 1.0',
                style: AppTypography.body.copyWith(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
