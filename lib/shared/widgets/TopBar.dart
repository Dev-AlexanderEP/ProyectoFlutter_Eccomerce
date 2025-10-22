import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String backRouteName; // ← obligatorio
  final String? actionIconAsset; // ruta del asset svg
  final Widget? actionIcon; // ícono opcional a la derecha
  final VoidCallback? onActionPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const TopBar({
    super.key,
    required this.title,
    required this.backRouteName,
    this.actionIconAsset = 'lib/assets/icons/default.svg',
    this.actionIcon,
    this.onActionPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final fg = foregroundColor ?? Colors.black;
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      elevation: 0,
      backgroundColor: backgroundColor ?? Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        color: fg,
        onPressed: () {
          // Si quieres reemplazar la pantalla actual, usa pushReplacementNamed
          Navigator.pushNamed(context, backRouteName);
          // o: Navigator.pushNamedAndRemoveUntil(context, backRouteName, (_) => false);
        },
      ),
      title: Text(
        title,
        style: TextStyle(color: fg),
      ),
      actions: [
          IconButton(
            icon: SvgPicture.asset(
              actionIconAsset ?? 'lib/assets/icons/default.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
            onPressed: onActionPressed,
          ),
      ],
    );
  }
}
