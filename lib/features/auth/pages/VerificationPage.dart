import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/AppButton.dart';
import '../../../shared/widgets/TopBar.dart';
import '../controllers/AuthController.dart';
import 'package:flutter/services.dart';

import '../controllers/RegisterFlowController.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {


  Timer? _timer;
  int _secondsLeft = 0;

  final List<TextEditingController> _controllers = List.generate(5, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(5, (index) => FocusNode());
  
  bool isLoading = false;
  String? errorMessage;
  String? email;
  bool fromRegister = false;
  bool showSuccessDialog = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener argumentos de la navegación
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      email = args['email'] as String?;
      fromRegister = args['fromRegister'] as bool? ?? false;
    }

    // Obtener expiresAt y arrancar el timer
    final flow = Provider.of<RegisterFlowController>(context, listen: false);
    final expiresAt = flow.expiresAt;
    if (expiresAt != null) {
      _secondsLeft = math.max(0, expiresAt.difference(DateTime.now()).inSeconds);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
        if (!mounted) return;
        setState(() {
          _secondsLeft = math.max(0, expiresAt.difference(DateTime.now()).inSeconds);
        });
        if (_secondsLeft <= 0) {
          t.cancel();
          await flow.reset();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.register);
          }
        }
      });
    }

  }

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String _formatTime(int total) {
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }


  String get verificationCode {
    return _controllers.map((controller) => controller.text).join();
  }

  bool get isCodeComplete {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  void _onCodeChanged(String value, int index) {
    setState(() {
      errorMessage = null;
    });

    if (value.isNotEmpty) {
      // Mover al siguiente campo
      if (index < 4) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Si es el último campo, quitar focus
        _focusNodes[index].unfocus();
      }
    }
  }

  void _onBackspace(int index) {
    if (index > 0 && _controllers[index].text.isEmpty) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _handleVerification() async {
    if (!isCodeComplete) {
      setState(() {
        errorMessage = 'Por favor ingrese el código completo';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final auth = Provider.of<AuthController>(context, listen: false);
      final flow = Provider.of<RegisterFlowController>(context, listen: false);

      bool success = false;
      if (fromRegister) {
        success = await auth.verifyCodeEmail(
          email: flow.email?? "",
          inputCode: verificationCode,
        );
      }

      if (!mounted) return;

      if (success) {
        final email = flow.email ?? "";
        final username = flow.username ?? "";
        final password = flow.password ?? "";
        await _handleRegister(email, username, password);

        await flow.reset();
        _showSuccessModal();
      } else {
        setState(() {
          errorMessage = 'Código de verificación inválido';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error de conexión: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() { isLoading = false; });
      }
    }
  }

  // Dart
  Future<void> _handleRegister(String email, String username, String password) async {
    setState(() { isLoading = true; errorMessage = null; });

    final auth = Provider.of<AuthController>(context, listen: false);
    try {
      final response = await auth.register(
        username,
        email,
        password,
      );

      if (response != null ) {
        _showSuccessModal();
      } else {
        setState(() {
          errorMessage = 'Error al registrar usuario';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error de conexión: $e';
      });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Círculo verde con check
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Registro exitoso',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                '¡Felicidades! Tu cuenta ya ha sido creada. Por favor inicia sesión para obtener una experiencia increíble.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Inicia Sesión',
                  onPressed: () async {
                    Navigator.of(context).pop(); // Cerrar modal
                    AppRoutes.navigateToAndClearStack(context, AppRoutes.login);
                    return true;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _resendCode() async {
    // Implementar reenvío de código
    setState(() {
      errorMessage = null;
    });

    try {
      final auth = Provider.of<AuthController>(context, listen: false);
      
      if (fromRegister) {
        // Aquí podrías implementar un método para reenviar código de registro
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código reenviado')),
        );
      } else {
        final success = await auth.sendCodeEmail(email!);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código reenviado')),
          );
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al reenviar código: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
            const SizedBox(height: 10),

        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Container(
            margin: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 60,
                height: 60,
                child: SvgPicture.asset(
                  'lib/assets/icons/email-lock.svg',
                  color: Colors.white,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),


        const SizedBox(height: 40),

            // Título
        const Text(
              'Código de verificación',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Descripción
            Text(
              'Hemos enviado un código de verificación a\n${email ?? 'example@gmail.com'}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

           LayoutBuilder(
             builder: (context, constraints) {
               const gap = 6.0;
               final n = _controllers.length;
               final boxWidth = ((constraints.maxWidth - gap * (n - 1)) / n)
                   .clamp(56.0, 72.0);
               final boxHeight = (boxWidth * 1.05).clamp(60.0, 76.0);

               return Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween, // <- Esto reparte el espacio
                 children: List.generate(n, (i) {
                   return SizedBox(
                     width: boxWidth,
                     height: boxHeight,
                     child: _OtpBox(
                       width: boxWidth,
                       height: boxHeight,
                       controller: _controllers[i],
                       focusNode: _focusNodes[i],
                       isLast: i == n - 1,
                       onNext: () => _focusNodes[i < n - 1 ? i + 1 : i].requestFocus(),
                       onPrev: () => _focusNodes[i > 0 ? i - 1 : 0].requestFocus(),
                     ),
                   );
                 }),
               );
             },
           ),
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _secondsLeft == 0 ? Colors.red.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _secondsLeft == 0 ? Colors.red.shade300 : Colors.grey.shade300),
                    ),
                    child: Text(
                      _secondsLeft == 0
                          ? 'Expiró'
                          : 'Expira en ${_formatTime(_secondsLeft)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _secondsLeft == 0 ? Colors.red : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 40),

            // Botón verificar
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: isLoading ? 'Verificando...' : 'Verificar',
                onPressed: () async {
                  if (isLoading) return false;
                  await _handleVerification();
                  return true;
                },
              ),
            ),

            const SizedBox(height: 24),

            // Reenviar código
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No recibiste un código? ',
                  style: TextStyle(color: Colors.grey),
                ),
                GestureDetector(
                  onTap: _resendCode,
                  child: const Text(
                    'Reenvía',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 40),
           ],
        ),
    );
  }
}




// Formatter personalizado
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

// Widget OTP Box
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
    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: false,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
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
            borderSide: BorderSide(color: Colors.red, width: 2),
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

