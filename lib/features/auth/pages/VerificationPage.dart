import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/AppButton.dart';
import '../../../shared/widgets/TopBar.dart';
import '../controllers/AuthController.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
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
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
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
      
      bool success;
      if (fromRegister) {
        success = await auth.verifyRegistrationCode(email!, verificationCode);
      } else {
        success = await auth.verifyForgotPasswordCode(
          email: email!,
          inputCode: verificationCode,
        );
      }

      if (!mounted) return;

      if (success) {
        // Mostrar modal de éxito
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
        final success = await auth.sendForgotPasswordCode(email!);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopBar(
          title: 'Verificación',
          backRouteName: fromRegister ? AppRoutes.register : AppRoutes.login,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Icono de email
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    color: Colors.white,
                    size: 40,
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

              // Campos de código
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  return SizedBox(
                    width: 50,
                    height: 50,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _controllers[index].text.isNotEmpty 
                                ? Colors.red 
                                : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                        ),
                        filled: true,
                        fillColor: _controllers[index].text.isNotEmpty 
                            ? Colors.red.shade50 
                            : Colors.grey.shade50,
                      ),
                      onChanged: (value) => _onCodeChanged(value, index),
                      onTap: () {
                        _controllers[index].selection = TextSelection.fromPosition(
                          TextPosition(offset: _controllers[index].text.length),
                        );
                      },
                    ),
                  );
                }),
              ),

              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],

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

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
