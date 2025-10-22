import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/type.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/AppButton.dart';
import '../../../shared/widgets/AppTextField.dart';
import '../../../shared/widgets/GoogleButton.dart';
import '../../../shared/widgets/TopBar.dart';
import '../controllers/AuthController.dart';
import '../controllers/RegisterFlowController.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();


}

class _RegisterPageState extends State<RegisterPage> {

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final flow = Provider.of<RegisterFlowController>(context, listen: false);
    await flow.loadState();
    if (flow.state == 1) {
      AppRoutes.navigateTo(context, AppRoutes.verification, arguments: {
        'email': flow.email,
        'fromRegister': true,
      });
    }
  });
}
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

      var  success = await auth.sendCodeEmail(emailController.text.trim(),);

      if(success){
        final flow = Provider.of<RegisterFlowController>(context, listen: false);
        await flow.saveState(
          state: 1,
          username: usernameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          expiresAt: DateTime.now().add(const Duration(minutes: 10)), // ejemplo de expiración
        );
        if (!mounted) return;

        // Navegar a la página de verificación
        AppRoutes.navigateTo(context, AppRoutes.verification, arguments: {
          'email': emailController.text.trim(),
          'fromRegister': true,
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
    return IntrinsicHeight(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),

                  // Username Field

                  Text('Nombre de usuario', style: AppTypography.h2),

                  const SizedBox(height: 8),
                  AppTextField(
                    controller: usernameController,
                    hint: 'Jhon Doe',
                    actionIconAsset: 'lib/assets/icons/user.svg',
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
                  Text('Correo Electrónico', style: AppTypography.h2),

                  const SizedBox(height: 8),
                  AppTextField(
                    controller: emailController,
                    hint: 'example@gmail.com',
                    actionIconAsset: 'lib/assets/icons/mail.svg',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      setState(() {
                        emailError = _validateEmail(value);
                      });
                    },
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa tu correo';
                      if (!v.contains('@')) return 'Correo inválido';
                      return null;
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
                  Text('Contraseña', style: AppTypography.h2),

                  const SizedBox(height: 8),
                  AppTextField(
                    controller: passwordController,
                    hint: 'Contraseña',
                    actionIconAsset: 'lib/assets/icons/lock-keyhole.svg',
                    obscure: true,
                    showObscureToggle: true,
                    onChanged: (value) {
                      setState(() {
                        passwordError = _validatePassword(value);
                      });
                    },
                    validator: (v) =>
                    (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
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

                  Text('Confirmar Contraseña', style: AppTypography.h2),

                  const SizedBox(height: 8),
                  AppTextField(
                    controller: confirmPasswordController,
                    hint: 'Contraseña',
                    actionIconAsset: 'lib/assets/icons/lock-keyhole.svg',
                    obscure: true,
                    showObscureToggle: true,
                    onChanged: (value) {
                      setState(() {}); // Para actualizar la validación en tiempo real
                    },
                    validator: (v) =>
                    (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
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
    );
  }
}
