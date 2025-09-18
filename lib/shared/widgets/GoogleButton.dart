import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../data/RemoteRepositorie/login/GoogleLoginAuthRemoteRepositorie.dart';

// 👇 Tu CLIENTE WEB (no el de Android)
const webClientId =
    '1033339672280-iia2echuns2ng6a2eudorroopk4jabev.apps.googleusercontent.com';

final googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile', 'openid'],
  serverClientId: webClientId, // necesario para recibir idToken (JWT)
);

class GoogleButton extends StatefulWidget {
  const GoogleButton({super.key});
  @override
  State<GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<GoogleButton> {
  String? _status;
  bool _loading = false;

  late final http.Client _client;
  late final GoogleLoginRemoteRepositorie _googleRepo;

  @override
  void initState() {
    super.initState();
    _client = http.Client();
    _googleRepo = GoogleLoginRemoteRepositorie(client: _client);
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _status = 'Iniciando sesión...';
    });

    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        setState(() {
          _loading = false;
          _status = 'Cancelado por el usuario';
        });
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken; // <- credential (JWT de Google)

      if (idToken == null) {
        setState(() {
          _loading = false;
          _status = 'No se obtuvo idToken de Google';
        });
        return;
      }

      final resp = await _googleRepo.googleLogin(
        credential: idToken,
        clientId: webClientId, // el MISMO que pones en serverClientId
      );

      if (!mounted) return;

      if (resp != null) {
        final accessToken = resp['accessToken'] as String?;
        final email = resp['email'] as String?;
        final name = resp['name'] as String?;
        final roles = resp['roles'] as String?;

        setState(() {
          _loading = false;
          _status =
          'Login OK\nUsuario: ${name ?? email}\nRoles: ${roles ?? '-'}\nToken interno: ${accessToken != null ? 'recibido' : 'no'}';
        });
      } else {
        setState(() {
          _loading = false;
          _status = 'Backend rechazó el login con Google';
        });
      }
    } on SocketException catch (e) {
      setState(() {
        _loading = false;
        _status = 'Error de red: $e';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _logout() async {
    await googleSignIn.signOut();
    setState(() => _status = 'Sesión cerrada');
  }

  // ✅ Botón con estilo “Google” — método privado (FUERA de build)
  Widget _googleStyledButton({
    required bool loading,
    required VoidCallback? onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
      elevation: 0,
      shape: const StadiumBorder(
        side: BorderSide(color: Color(0xFFE0E0E0), width: 1), // borde gris
      ),
      child: InkWell(

        onTap: loading ? null : onPressed,
        customBorder: const StadiumBorder(),
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ícono a la izquierda
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'lib/assets/icons/google.png',
                  width: 20,
                  height: 20,
                ),
              ),
              // Texto o spinner centrado
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: loading
                    ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text(
                  key: ValueKey('label'),
                  'Inicia con Google',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 👇 Solo llamas al botón estilizado
        _googleStyledButton(
          loading: _loading,
          onPressed: _login,
        ),

        // Verificacion que los datos llegen bien
        // const SizedBox(height: 12),
        // if (_status != null)
        //   Text(_status!, textAlign: TextAlign.center),
        // const SizedBox(height: 8),
        // TextButton(onPressed: _logout, child: const Text('Cerrar sesión')),
      ],
    );
  }
}
