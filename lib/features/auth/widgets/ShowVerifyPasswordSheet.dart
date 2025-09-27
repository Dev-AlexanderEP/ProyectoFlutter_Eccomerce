import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/colors.dart';
import '../../../shared/widgets/AppButton.dart';
import '../controllers/AuthController.dart';

Future<bool?> showVerifyPasswordSheet(BuildContext context, {required String email, int length = 5, required DateTime expiresAt}) {
  // 👇 devuelve el Future y tipa el bottom sheet para que pueda regresar true/false/null
  return showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    barrierColor: Colors.black54,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    useSafeArea: true,
    builder: (ctx) {
      return _VerifyCodeContent(email: email, length: length, expiresAt: expiresAt);

    },
  );
}

/// Convierte toda entrada a MAYÚSCULAS.
class UpperCaseTextFormatter extends TextInputFormatter {
  const UpperCaseTextFormatter();
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

class _VerifyCodeContent extends StatefulWidget {
  final String email;
  final int length;
  final DateTime expiresAt; // 👈 hora de expiración fija

  const _VerifyCodeContent({required this.email, this.length = 5,required this.expiresAt,});

  @override
  State<_VerifyCodeContent> createState() => _VerifyCodeContentState();
}

class _VerifyCodeContentState extends State<_VerifyCodeContent> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;
  Timer? _tick; // solo para refrescar la UI cada segundo


  int get _secondsLeft {
    final diff = widget.expiresAt.difference(DateTime.now()).inSeconds;
    return math.max(0, diff);
  }


  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode()..addListener(() => setState(() {})));

    _tick = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 0) {
        t.cancel();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        Navigator.pop(context, false); // expiró
      } else {
        setState(() {}); // solo para redibujar el contador
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusIndex(0);
    });
  }

  @override
  void dispose() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    for (final c in _controllers) c.dispose();
    for (final n in _nodes) n.dispose();
    _tick?.cancel();
    super.dispose();
  }

  String _currentCode() => _controllers.map((c) => c.text).join();

  void _focusIndex(int i) {
    if (i < 0 || i >= _nodes.length) return;
    FocusScope.of(context).requestFocus(_nodes[i]);
  }

  String _formatTime(int total) {
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<bool> _verify(BuildContext context) async {
    if (_secondsLeft == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El código ha expirado. Solicita uno nuevo.')),
      );
      return false;
    }

    final code = _currentCode();
    if (code.length != widget.length || code.contains(RegExp(r'\s'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa el código')),
      );
      return false;
    }

    final auth = context.read<AuthController>();
    final ok = await auth.verifyForgotPasswordCode(
      email: widget.email,
      inputCode: code,
    );
    if (ok) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      Navigator.pop(context,true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código verificado ✔')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código inválido o expirado')),
      );
      for (final c in _controllers) c.clear();
      _focusIndex(0);
      setState(() {});
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expired = _secondsLeft == 0;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // handle
          Center(
            child: Container(
              width: 48, height: 4, margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(999)),
            ),
          ),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Olvidaste la contraseña',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: expired ? Colors.red.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: expired ? Colors.red.shade300 : Colors.grey.shade300),
                ),
                child: Text(
                  expired ? 'Expiró' : 'Expira en ${_formatTime(_secondsLeft)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: expired ? Colors.red : Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            'Ingresa el código que te enviamos a ${widget.email}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 16),

          // ====== Inputs responsivos tipo “cajitas” ======
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 12.0;
              final n = widget.length;
              // calcula ancho de cada caja según el espacio disponible
              final boxWidth = ((constraints.maxWidth - gap * (n - 1)) / n)
                  .clamp(56.0, 72.0); // min 56, máx 72 como en el mock
              final boxHeight = (boxWidth * 1.05).clamp(60.0, 76.0);

              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(n, (i) {
                  return Padding(
                    padding: EdgeInsets.only(right: i == n - 1 ? 0 : gap),
                    child: _OtpBox(
                      width: boxWidth,
                      height: boxHeight,
                      controller: _controllers[i],
                      focusNode: _nodes[i],
                      isLast: i == n - 1,
                      onNext: () => _focusIndex(i + 1),
                      onPrev: () => _focusIndex(i - 1),
                    ),
                  );
                }),
              );
            },
          ),

          const SizedBox(height: 20),

          AppButton(
            label: expired ? 'Código expirado' : 'Verificar',
            enabled: !expired,
            backgroundColor: AppColors.red500,
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            borderRadius: 999,
            onPressed: () => _verify(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Caja individual del OTP responsiva (A–Z y 0–9 en mayúsculas)
class _OtpBox extends StatelessWidget {
  final double width;
  final double height;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const _OtpBox({
    required this.width,
    required this.height,
    required this.controller,
    required this.focusNode,
    required this.isLast,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    final hasFocus = focusNode.hasFocus;

    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: false,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        // para códigos alfanuméricos con mayúsculas
        keyboardType: TextInputType.visiblePassword,
        textCapitalization: TextCapitalization.characters,
        textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
        cursorWidth: 2,
        decoration: InputDecoration(
          isCollapsed: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          filled: true,
          fillColor: Colors.white,
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.red500, width: 2),
          ),
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          UpperCaseTextFormatter(),
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
        ],
        onChanged: (value) {
          if (value.length > 1) {
            controller.text = value.characters.last.toUpperCase();
            controller.selection = TextSelection.collapsed(offset: controller.text.length);
          }
          if (controller.text.isNotEmpty) {
            if (!isLast) onNext();
          } else {
            onPrev();
          }
        },
        onTap: () {
          controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
        },
      ),
    );
  }
}
