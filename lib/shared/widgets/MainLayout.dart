// lib/shared/layouts/main_layout.dart
import 'package:flutter/material.dart';
import '../../core/constants/AppSpacing.dart'; // usa tu spacing
import '../../shared/widgets/TopBar.dart';

class MainLayout extends StatelessWidget {
  final String title;
  /// Ruta a la que volverá el TopBar (prop pedida)
  final String backRouteName;
  /// Asset opcional para el botón de acción del AppBar (prop pedida)
  final String? actionIconAsset;

  /// Contenido de la pantalla
  final Widget child;

  /// Personalización opcional
  final bool resizeToAvoidBottomInset;
  final Color backgroundColor;
  final EdgeInsets? contentPadding; // si quieres override de padding

  const MainLayout({
    super.key,
    required this.title,
    required this.backRouteName,
    required this.child,
    this.actionIconAsset,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor = Colors.white,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    final EdgeInsets basePadding = contentPadding ??
        EdgeInsets.only(
          left: AppSpacing.padCustom.left,
          right: AppSpacing.padCustom.right,
          top: AppSpacing.padCustom.top,
          // deja “aire” extra cuando el teclado aparece
          bottom: AppSpacing.padCustom.bottom,
        );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: TopBar(
          title: title,
          backRouteName: backRouteName,
          actionIconAsset: actionIconAsset, // tu TopBar ya lo soporta
        ),
        // MUY importante para que el body se reacomode con el teclado
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: basePadding.add(
                  EdgeInsets.only(bottom: viewInsets.bottom + 16),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: child, // Elimina IntrinsicHeight
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
