// lib/features/auth/widgets/show_change_password_sheet.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/features/auth/controllers/AuthController.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/type.dart';
import '../../../shared/widgets/AppButton.dart';
import '../../../shared/widgets/AppTextField.dart';

/// Abre la sheet para cambiar contraseña.
/// - [email] y [code] son requeridos (los necesitarás para el reset en backend).
/// - [expiresAt] es opcional; si se pasa, la sheet mostrará el contador y cerrará con `false` al expirar.
Future<bool> showChangePasswordSheet(
    BuildContext context, {
      required String email,
      required String code,
      DateTime? expiresAt,
      // required AuthController authController,
    }) async {
  final res = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    barrierColor: Colors.black54,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    useSafeArea: true,
    builder: (_) => _ChangePasswordContent(
      email: email,
      code: code,
      expiresAt: expiresAt,
      // authController: authController,
    ),
  );

  return res ?? false; // si se cierra con back/swipe → false
}

class _ChangePasswordContent extends StatefulWidget {
  const _ChangePasswordContent({
    required this.email,
    required this.code,
    this.expiresAt,
    // required this.authController,
  });

  final String email;
  final String code;
  final DateTime? expiresAt;
  // final AuthController authController;

  @override
  State<_ChangePasswordContent> createState() => _ChangePasswordContentState();
}

class _ChangePasswordContentState extends State<_ChangePasswordContent> {
  final _passController = TextEditingController();
  final confirmController = TextEditingController();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  Timer? _tick; // refresca UI del contador

  int? get _secondsLeft {
    final ea = widget.expiresAt;
    if (ea == null) return null;
    final diff = ea.difference(DateTime.now()).inSeconds;
    return math.max(0, diff);
  }

  bool isLoading = false;
  String? errorMessage;

  // funcion para poder logearse con formulario normal
  Future<bool> _handleChangePass(BuildContext context) async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final auth = Provider.of<AuthController>(context, listen: false);
      final ok = await auth.resetPassword(newPassword: confirmController.text.trim(), email: widget.email, code: widget.code);
      if (!mounted) return false;

      if (!ok) {
        errorMessage = 'Credenciales inválidas';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage!)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Bienvenido!')));
      }
      return ok;
    } catch (_) {
      if (!mounted) return false;
      errorMessage = 'Ocurrió un error inesperado';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage!)));
      return false;
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Si hay expiresAt, arrancamos un ticker para actualizar la vista y autocerrar al expirar
    if (widget.expiresAt != null) {
      _tick = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        final left = _secondsLeft ?? 0;
        if (left <= 0) {
          t.cancel();
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          Navigator.of(context).pop(false); // expiró → false
        } else {
          setState(() {}); // redibuja contador
        }
      });
    }
  }

  @override
  void dispose() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _tick?.cancel();
    _passController.dispose();
    confirmController.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  String _formatTime(int total) {
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _maskEmail(String email) {
    // Enmascarado simple: ju***@do***.com
    final at = email.indexOf('@');
    if (at <= 1) return email;
    final name = email.substring(0, at);
    final domain = email.substring(at + 1);
    final dot = domain.lastIndexOf('.');
    final domLeft = dot > 1 ? domain.substring(0, dot) : domain;
    final domRight = dot > 0 ? domain.substring(dot) : '';
    final maskedName = name.length <= 2 ? name : '${name.substring(0, 2)}***';
    final maskedDom = domLeft.length <= 2 ? domLeft : '${domLeft.substring(0, 2)}***';
    return '$maskedName@$maskedDom$domRight';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final left = _secondsLeft; // puede ser null

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: bottomInset + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // handle
          Center(
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          // Header + chip de expiración (si aplica)
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Crea tu nueva contraseña',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              if (left != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    'Expira en ${_formatTime(left)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            // mostramos el email enmascarado para contexto
            'Código enviado a ${_maskEmail(widget.email)}',
            style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
          ),
          // Si quieres ver el code en desarrollo (ocúltalo en prod):
          // Text('DEBUG OTP: ${widget.code}', style: const TextStyle(color: Colors.black38)),

          const SizedBox(height: 16),

          Text('Contraseña', style: AppTypography.h2),
          const SizedBox(height: 6),
          AppTextField(
            focusNode: _passFocus,
            controller: _passController,
            hint: '*****',
            prefixIcon: const Icon(Icons.lock_outline),
            actionIconAsset: 'lib/assets/icons/lock-keyhole.svg',
            obscure: true,
            showObscureToggle: true,
          ),

          const SizedBox(height: 16),

          Text('Confirmar Contraseña', style: AppTypography.h2),
          const SizedBox(height: 6),
          AppTextField(
            focusNode: _confirmFocus,
            controller: confirmController,
            hint: '*****',
            prefixIcon: const Icon(Icons.lock_outline),
            actionIconAsset: 'lib/assets/icons/lock-keyhole.svg',
            obscure: true,
            showObscureToggle: true,
          ),

          const SizedBox(height: 24),

          AppButton(
            label: 'Cambiar contraseña',
            enabled: true,
            backgroundColor: AppColors.red500,
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            borderRadius: 999,
            onPressed: () async {
              if(_handleChangePass(context) == true){
                Navigator.of(context).pop(true);
              }
              return true;
            },
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
