import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/core/constants/AppSpacing.dart';
import 'package:proyecto_flutter/core/theme/colors.dart';
import '../../../core/theme/type.dart';
import '../../../shared/widgets/AppButton.dart';
import '../../../shared/widgets/AppTextField.dart';
import '../../../shared/widgets/GoogleButton.dart';
import '../../../shared/widgets/TopBar.dart';
import '../controllers/AuthController.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title; // valor inicial, inmutable

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus  = FocusNode();
  bool isLoading = false;
  String? errorMessage;


  @override
  void dispose() {
    userController.dispose();
    passController.dispose();
    _emailFocus.dispose();   // 👈 importante
    _passFocus.dispose();    // 👈 importante
    super.dispose();
  }

  Future<bool> _handleLogin(BuildContext context) async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final auth = Provider.of<AuthController>(context, listen: false);
      final ok = await auth.login(userController.text.trim(), passController.text.trim());
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
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets; // alto del teclado

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // cierra teclado al tocar fuera
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: TopBar(
          title: 'Iniciar Sesión',
          backRouteName: '/login',
          actionIconAsset: 'lib/assets/icons/user.svg',
        ),
        // 👇 MUY IMPORTANTE para que el body se reacomode con el teclado
        resizeToAvoidBottomInset: true,

        // 👇 Volvemos el contenido scrollable
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: AppSpacing.padCustom.left,
                  right: AppSpacing.padCustom.right,
                  top: AppSpacing.padCustom.top,
                  // deja espacio extra cuando el teclado está visible
                  bottom: (AppSpacing.padCustom.bottom) + viewInsets.bottom + 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- TU CONTENIDO TAL CUAL ---
                          Container(
                            decoration: const BoxDecoration(color: Colors.white),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Labels-Inputs
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Correo o Nombre de usuario', style: AppTypography.h2),
                                    const SizedBox(height: 6),
                                    AppTextField(
                                      focusNode: _emailFocus,
                                      controller: userController,
                                      hint: 'example@gmail.com',
                                      actionIconAsset: 'lib/assets/icons/mail.svg',

                                      suffixClear: true,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return 'Ingresa tu correo';
                                        if (!v.contains('@')) return 'Correo inválido';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Text('Contraseña', style: AppTypography.h2),
                                    const SizedBox(height: 6),
                                    AppTextField(
                                      focusNode: _passFocus,
                                      controller: passController,
                                      hint: 'Contraseña',
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      actionIconAsset: 'lib/assets/icons/lock-keyhole.svg',
                                      obscure: true,
                                      showObscureToggle: true,
                                      validator: (v) =>
                                      (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.all(10),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () => print("Ir a recuperación de contraseña"),
                                      child: Container(
                                        padding: const EdgeInsets.only(bottom: 1),
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: AppColors.red500, width: 2),
                                          ),
                                        ),
                                        child: const Text(
                                          "Olvidé mi contraseña",
                                          style: TextStyle(
                                            color: AppColors.red500,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 50),

                          AppButton(
                            label: 'Iniciar Sesión',
                            enabled: true,
                            backgroundColor: AppColors.red500,
                            textColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            borderRadius: 999,
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return false;
                              final ok = await _handleLogin(context);
                              return ok;
                            },
                          ),

                          if (errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                          ],

                          const SizedBox(height: 5),

                          Center(
                            child: TextButton(
                              onPressed: () => print("Ir a recuperación de contraseña"),
                              child: const Text(
                                "O usa otro metodo",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          // El botón ocupa el ancho disponible
                          SizedBox(width: double.infinity, child: GoogleButton()),

                          // Empuja el contenido hacia arriba si sobra espacio
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

}
