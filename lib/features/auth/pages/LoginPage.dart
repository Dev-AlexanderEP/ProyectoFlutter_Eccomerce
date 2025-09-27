import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/core/constants/AppSpacing.dart';
import 'package:proyecto_flutter/core/theme/colors.dart';
import 'package:proyecto_flutter/features/auth/widgets/ShowChangePasswordSheet.dart';
import '../../../core/theme/type.dart';
import '../../../shared/widgets/AppButton.dart';
import '../../../shared/widgets/AppTextField.dart';
import '../../../shared/widgets/GoogleButton.dart';
import '../../../shared/widgets/TopBar.dart';
import '../controllers/AuthController.dart';
import '../widgets/ForgotPasswordSheet.dart';
import '../widgets/ShowVerifyPasswordSheet.dart';

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
  // funcion para poder logearse con formulario normal
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

  // Estado del flujo: 1 = pedir email, 2 = verificar código
  int _forgotFlowState = 1;
  // 1er sheet: email ingresado
  String? _recoveryEmail;
  // 2do sheet: expiración del código (se mantiene entre ciclos)
  DateTime? _verifyExpiresAt;
  // 3er sheet: nueva contraseña (solo se muestra y vuelve a 1) y confirmacion de cambio
  String? _newPassword;
  String? _confirmPassword;
  String? _codigo;




  /// Llama esta función desde onPressed del botón "Olvidé mi contraseña"
  Future<void> _handleForgotFlow() async {
    if (!mounted) return;

    if (_forgotFlowState == 1) {
      // 1) Pide el email (esta await YA cierra la sheet al retornar)
      final email = await showForgotPasswordSheet(context);
      if (!mounted) return;

      if (email == null || email.isEmpty) {
        // usuario canceló o no puso email -> quedamos en estado 1
        return;
      }

      // Guardamos email y pasamos a estado 2
      setState(() {
        _recoveryEmail = email;
        _forgotFlowState = 2;
        _verifyExpiresAt ??= DateTime.now().add(const Duration(minutes: 10));

      });

      // (Opcional) pequeña espera para que termine la animación de cierre
      await Future.delayed(const Duration(milliseconds: 50));

      // Abre inmediatamente Verify
      final verifiedOrExpired = await showVerifyPasswordSheet(
        context,
        email: email,
        expiresAt: _verifyExpiresAt!, // 👈 clave
        // length: 5,
      );
      if (!mounted) return;

      // Si se verificó (true) o expiró (false) → mostramos ForgotPasswordSheet y volvemos a estado 1
      if (verifiedOrExpired == true) {
        // Reinicia el flujo para un próximo intento
        setState(() {
          _forgotFlowState = 3;
          _verifyExpiresAt = null; // 👈 limpiamos para el próximo ciclo
          _verifyExpiresAt ??= DateTime.now().add(const Duration(minutes: 3));

        });
        bool respuesta = await showChangePasswordSheet(context, expiresAt: _verifyExpiresAt, email: email,   code: "12345", );
        if (respuesta) {
          setState(() {
            _forgotFlowState = 1;
            _verifyExpiresAt = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña cambiada con éxito')));
        } else {
          setState(() {
            _forgotFlowState = 1;
            _verifyExpiresAt = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo cambiar la contraseña')));
        }
        if (!mounted) return;

        return;
      } else if (verifiedOrExpired == false) {
        // Si fue null (cerró/canceló), mantenemos estado 2 para que al volver a presionar, retome Verify
        setState(() {
          _forgotFlowState = 1;
          _verifyExpiresAt = null; // 👈 limpiamos para el próximo ciclo
        });
        await showForgotPasswordSheet(context);
        if (!mounted) return;

        return;
      }

      // Si fue null (cerró/canceló), mantenemos estado 2 para que al volver a presionar, retome Verify

    } else if (_forgotFlowState == 2) {
      // 2) Abre Verify con el email guardado
      final email = _recoveryEmail;
      if (email == null || email.isEmpty) {
        setState(() => _forgotFlowState = 1);
        return;
      }

      final verifiedOrExpired = await showVerifyPasswordSheet(
        context,
        email: email,
        expiresAt: _verifyExpiresAt!, // 👈 seguimos usando el MISMO expiresAt

        // length: 5,
      );
      if (!mounted) return;

      // Si se verificó (true) o expiró (false) → mostramos ForgotPasswordSheet y volvemos a estado 1
      if (verifiedOrExpired == true) {
        // Reinicia el flujo para un próximo intento
        setState(() {
          _forgotFlowState = 3;
          _verifyExpiresAt = null; // 👈 limpiamos para el próximo ciclo
          _verifyExpiresAt ??= DateTime.now().add(const Duration(minutes: 3));

        });
        bool respuesta = await showChangePasswordSheet(context, expiresAt: _verifyExpiresAt , email: email,   code: "12345",);
        if (respuesta) {
          setState(() {
            _forgotFlowState = 1;
            _verifyExpiresAt = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña cambiada con éxito')));
        } else {
          setState(() {
            _forgotFlowState = 1;
            _verifyExpiresAt = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo cambiar la contraseña')));
        }
        if (!mounted) return;

        return;
      } else if (verifiedOrExpired == false) {
        // Si fue null (cerró/canceló), mantenemos estado 2 para que al volver a presionar, retome Verify
        setState(() {
          _forgotFlowState = 1;
          _verifyExpiresAt = null; // 👈 limpiamos para el próximo ciclo
        });
        await showForgotPasswordSheet(context);
        return;
      }

      // Si fue null, seguimos en 2
    } else if (_forgotFlowState == 3) {
      // 3) Ya se verificó, solo mostramos un SnackBar y volvemos a estado 1
      bool respuesta = await showChangePasswordSheet(context, expiresAt: _verifyExpiresAt , email: _recoveryEmail!,   code: "12345",);



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
                                      onPressed: () async {
                                        await _handleForgotFlow();
                                      },
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
