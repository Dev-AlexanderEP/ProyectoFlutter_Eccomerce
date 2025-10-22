// import 'package:flutter/material.dart';
//
// import '../../../core/theme/colors.dart';
// import '../../../shared/widgets/AppButton.dart';
// import '../../../shared/widgets/AppTextField.dart';
// import '../controllers/AuthController.dart';
// import 'package:provider/provider.dart';
//
//
// Future<String?> showForgotPasswordSheet(BuildContext context) {
//   final emailCtrl = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true, // permite altura dinámica y empuje por teclado
//     backgroundColor: Colors.white,
//     barrierColor: Colors.black54,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//     ),
//     useSafeArea: true,
//     builder: (ctx) {
//       return Padding(
//         // deja espacio para el teclado
//         padding: EdgeInsets.only(
//           left: 16,
//           right: 16,
//           bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
//           top: 12,
//         ),
//         child: SingleChildScrollView(
//           // si el contenido supera la pantalla (teclado abierto), permite scroll
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min, // 👈 clave: altura = contenido
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // handle superior
//                 Center(
//                   child: Container(
//                     width: 48,
//                     height: 4,
//                     margin: const EdgeInsets.only(bottom: 12),
//                     decoration: BoxDecoration(
//                       color: Colors.black12,
//                       borderRadius: BorderRadius.circular(999),
//                     ),
//                   ),
//                 ),
//
//                 const Text("Olvidaste la contraseña",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
//                 const SizedBox(height: 4),
//                 const Text("Puedes recuperar tu cuenta con tu correo",
//                     style: TextStyle(fontSize: 14, color: Colors.black54)),
//
//                 const SizedBox(height: 16),
//                 const Text("Correo electrónico",
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                 const SizedBox(height: 8),
//
//                 AppTextField(
//                   controller: emailCtrl,
//                   hint: 'example@gmail.com',
//                   actionIconAsset: 'lib/assets/icons/mail.svg',
//                   suffixIconAsset: 'lib/assets/icons/check.svg',
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (v) {
//                     if (v == null || v.isEmpty) return 'Ingresa tu correo';
//                     if (!v.contains('@')) return 'Correo inválido';
//                     return null;
//                   },
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 AppButton(
//                   label: 'Enviar código',
//                   enabled: true,
//                   backgroundColor: AppColors.red500,
//                   textColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                   borderRadius: 999,
//                   onPressed: () async {
//                     final ok = formKey.currentState!.validate();
//                     if (!ok) return false;
//
//                     final email = emailCtrl.text.trim();
//
//
//                     // Llamar al AuthController (inyectado con Provider o como lo uses)
//                     final auth = context.read<AuthController>();
//                     final sent = await auth.sendForgotPasswordCode(email);
//
//                     if (sent) {
//                       Navigator.pop(ctx, email);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text("Código enviado al correo $email")),
//                       );
//                       return true;
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Error al enviar el código")),
//                       );
//                       return false;
//                     }
//                   },
//                 ),
//
//
//                 const SizedBox(height: 8),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }
//
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/colors.dart';
import '../../../shared/widgets/AppButton.dart';
import '../../../shared/widgets/AppTextField.dart';
import '../controllers/AuthController.dart';

Future<String?> showForgotPasswordSheet(BuildContext context) {
  final emailCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // IMPORTANTE: retorna el Future del bottom sheet y tipa a <String>
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true, // altura dinámica + empuje por teclado
    backgroundColor: Colors.white,
    barrierColor: Colors.black54,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    useSafeArea: true,
    builder: (ctx) {
      return Padding(
        // margen inferior para no tapar el teclado
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          top: 12,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // alto = contenido
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // handle superior
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

                const Text(
                  "Olvidaste la contraseña",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Puedes recuperar tu cuenta con tu correo",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),

                const SizedBox(height: 16),
                const Text(
                  "Correo electrónico",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                AppTextField(
                  controller: emailCtrl,
                  hint: 'example@gmail.com',
                  actionIconAsset: 'lib/assets/icons/mail.svg',
                  suffixIconAsset: 'lib/assets/icons/check.svg',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu correo';
                    if (!v.contains('@')) return 'Correo inválido';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                AppButton(
                  label: 'Enviar código',
                  enabled: true,
                  backgroundColor: AppColors.red500,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  borderRadius: 999,
                  onPressed: () async {
                    // NO devolver bool aquí
                    final ok = formKey.currentState!.validate();
                    if (!ok) return false;

                    final email = emailCtrl.text.trim();

                    // Usar el provider dentro del builder: ctx.read(...)
                    final auth = ctx.read<AuthController>();
                    final sent = await auth.sendCodeEmail(email);

                    if (sent) {
                      // Devuelve el email al padre (LoginPage)
                      Navigator.pop(ctx, email);

                      // SnackBar en el Scaffold padre
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Código enviado al correo $email")),
                      );
                      return true; // <-- devuelve bool

                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Error al enviar el código")),
                      );
                      return false; // <-- devuelve bool

                    }
                  },
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    },
  );
}

