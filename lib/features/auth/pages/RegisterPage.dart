import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/AppButton.dart';
import '../../../shared/widgets/AppTextField.dart';
import '../../../shared/widgets/GoogleButton.dart';
import '../../../shared/widgets/TopBar.dart';
import '../controllers/AuthController.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? errorMessage;
  String? usernameError;
  String? emailError;
  String? passwordError;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre de usuario es requerido';
    }
    if (value.contains(RegExp(r'[0-9]'))) {
      return 'No tiene que haber números';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es requerido';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Tiene que poner un correo válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    setState(() {
      usernameError = _validateUsername(usernameController.text);
      emailError = _validateEmail(emailController.text);
      passwordError = _validatePassword(passwordController.text);
      errorMessage = null;
    });

    // Validar que las contraseñas coincidan
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Las contraseñas no coinciden';
      });
      return;
    }

    // Si hay errores de validación, no continuar
    if (usernameError != null || emailError != null || passwordError != null) {
      return;
    }

    setState(() { isLoading = true; });

    try {
      final auth = Provider.of<AuthController>(context, listen: false);
      final result = await auth.register(
        usernameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result != null && result.success) {
        // Navegar a la página de verificación
        AppRoutes.navigateTo(context, AppRoutes.verification, arguments: {
          'email': emailController.text.trim(),
          'fromRegister': true,
        });
      } else {
        setState(() {
          errorMessage = result?.message ?? 'Error al registrar usuario';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopBar(
          title: 'Crear Cuenta',
          backRouteName: AppRoutes.login,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Username Field
                  const Text(
                    'Nombre de usuario',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: usernameController,
                    hint: 'Jhon Doe',
                    prefixIcon: const Icon(Icons.person_outline),
                    onChanged: (value) {
                      setState(() {
                        usernameError = _validateUsername(value);
                      });
                    },
                  ),
                  if (usernameError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        usernameError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Email Field
                  const Text(
                    'Correo Electrónico',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: emailController,
                    hint: 'example@gmail.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      setState(() {
                        emailError = _validateEmail(value);
                      });
                    },
                  ),
                  if (emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        emailError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Password Field
                  const Text(
                    'Contraseña',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: passwordController,
                    hint: '••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    obscure: true,
                    showObscureToggle: true,
                    onChanged: (value) {
                      setState(() {
                        passwordError = _validatePassword(value);
                      });
                    },
                  ),
                  if (passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        passwordError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Confirm Password Field
                  const Text(
                    'Confirmar Contraseña',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: confirmPasswordController,
                    hint: '••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    obscure: true,
                    showObscureToggle: true,
                    onChanged: (value) {
                      setState(() {}); // Para actualizar la validación en tiempo real
                    },
                  ),
                  if (passwordController.text != confirmPasswordController.text && 
                      confirmPasswordController.text.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Las contraseñas no coinciden',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),

                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(color: Colors.red.shade600, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: isLoading ? 'Creando cuenta...' : 'Crear una cuenta',
                      onPressed: () async {
                        if (isLoading) return false;
                        await _handleRegister();
                        return true;
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  const Center(
                    child: Text(
                      'O usa otro método',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Google Button
                  const GoogleButton(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
