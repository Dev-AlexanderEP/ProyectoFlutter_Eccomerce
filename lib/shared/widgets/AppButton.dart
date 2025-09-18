import 'package:flutter/material.dart';

/// Botón primario reutilizable con:
/// - Texto obligatorio [label]
/// - Acción asíncrona [onPressed] que retorna bool
/// - Loading interno con CircularProgressIndicator
/// - Props opcionales de estilo: colores, padding, radio, etc.
///
/// Uso típico:
/// AppButton(
///   label: 'Iniciar sesión',
///   onPressed: () async {
///     if (!_formKey.currentState!.validate()) return false;
///     final ok = await doLogin(); // <-- tu lógica
///     return ok; // true = éxito, false = fallo
///   },
/// )
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,

    // Estilo
    this.backgroundColor = const Color(0xFFEF4444),
    this.disabledColor,
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
    this.borderRadius = 999, // pill
    this.elevation = 0,
    this.fullWidth = true,

    // Comportamiento
    this.enabled = true,
  });

  // Requeridos
  final String label;
  final Future<bool> Function() onPressed;

  // Estilo
  final Color backgroundColor;
  final Color? disabledColor; // si no se pasa, toma background con 40% opacidad
  final Color textColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double elevation;
  final bool fullWidth;

  // Estado externo
  final bool enabled;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _loading = false;

  Future<void> _handleTap() async {
    if (_loading || !widget.enabled) return;
    setState(() => _loading = true);

    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgDisabled = widget.disabledColor ?? widget.backgroundColor.withOpacity(0.4);
    final isEnabled = widget.enabled && !_loading;

    final button = ElevatedButton(
      onPressed: isEnabled ? _handleTap : null,
      style: ElevatedButton.styleFrom(
        elevation: widget.elevation,
        backgroundColor: isEnabled ? widget.backgroundColor : bgDisabled,
        disabledBackgroundColor: bgDisabled,
        foregroundColor: widget.textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        padding: widget.padding,
      ),
      child: _loading
          ? const SizedBox(
        height: 20, width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      )
          : Text(
        widget.label,
        style: TextStyle(
          color: widget.textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (!widget.fullWidth) return button;

    return SizedBox(width: double.infinity, child: button);
  }
}
