import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../core/theme/type.dart'; // AppTypography (tu tipografía)
// Si ya tienes AppColors.red500 etc., puedes importarlos y usarlos aquí.

/// Campo de texto reutilizable con 3 estados de diseño:
/// - Inicial:    sin foco y vacío
/// - Lleno:      con texto (sin foco)
/// - En foco:    con foco (independiente de si hay texto)
///
/// Props clave:
/// - prefixIcon / suffixIcon
/// - suffixClear (botón ✖ para limpiar cuando hay texto + foco)
/// - showObscureToggle (👁️ para contraseñas)
/// - validator / onChanged
/// - Colores para cada estado (con defaults)
class AppTextField extends StatefulWidget {
  // --- Control / comportamiento ---
  final TextEditingController? controller;
  final FocusNode? focusNode;

  final String? hint;
  final bool obscure;
  final bool showObscureToggle;
  final bool suffixClear;
  final bool enabled;

  final String? actionIconAsset; // ruta del asset svg


  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines; // si obscure => se forzará a 1
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  // --- Estilo general ---
  final EdgeInsetsGeometry contentPadding;
  final double borderRadius;
  final double borderWidth;
  final Widget? prefixIcon;
  final Widget? suffixIcon; // prioridad sobre clear/eye

  // --- Colores por estado (puedes personalizarlos por props) ---
  // Estado inicial (sin foco + vacío)
  final Color initialFillColor;
  final Color initialBorderColor;
  final Color initialIconColor;

  // Estado lleno (con texto + sin foco)
  final Color filledFillColor;
  final Color filledBorderColor;
  final Color filledIconColor;

  // Estado con foco
  final Color focusedFillColor;
  final Color focusedBorderColor;
  final Color focusedIconColor;

  // Errores
  final Color errorBorderColor;

  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hint,
    this.obscure = false,
    this.showObscureToggle = false,
    this.suffixClear = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.borderRadius = 18, // look pill
    this.borderWidth = 1.2,
    this.prefixIcon,
    this.suffixIcon,
    this.actionIconAsset = 'lib/assets/icons/default.svg',


    // Defaults inspirados en tus mockups
    // Inicial
    this.initialFillColor = const Color(0xFFF2F2F2), // gris claro
    this.initialBorderColor = const Color(0xFFDDDDDD),
    this.initialIconColor = const Color(0xFF9E9E9E),

    // Lleno
  // Porcentaje	Decimal	Hex	Ejemplo en Flutter (Color)
  // 100%	      255	    FF	Color(0xFF000000) → negro 100%
  // 75%	      191	    BF	Color(0xBF000000) → negro 75%
  // 50%	      128	    80	Color(0x80000000) → negro 50%
  // 25%	      64	    40	Color(0x40000000) → negro 25%
  // 10%	      25	    19	Color(0x19000000) → negro 10%
    this.filledFillColor = Colors.white,
    this.filledBorderColor = const Color(0x80000000), // negro con 25% alpha
    this.filledIconColor = const Color(0x80000000),


    // Foco
    this.focusedFillColor = Colors.white,
    this.focusedBorderColor = const Color(0xFFEF4444), // rojo 500
    this.focusedIconColor = const Color(0xFFEF4444),

    // Error
    this.errorBorderColor = const Color(0xFFD32F2F),
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();

  bool _obscure = false;


  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;

    // Redibuja cuando cambia el foco o el contenido (para recalcular el estado visual)
    _focusNode.addListener(() => setState(() {}));
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  // ------- Estados -------
  bool get _isFocused => _focusNode.hasFocus;
  bool get _hasText => _controller.text.trim().isNotEmpty;

  /// Devuelve colores según el estado:
  /// - Si está en foco => "focused"
  /// - Si NO está en foco pero hay texto => "filled"
  /// - Si NO foco y vacío => "initial"
  Color _fillColor() {
    if (_isFocused) return widget.focusedFillColor;
    if (_hasText) return widget.filledFillColor;
    return widget.initialFillColor;
  }

  Color _borderColor() {
    if (_isFocused) return widget.focusedBorderColor;
    if (_hasText) return widget.filledBorderColor;
    return widget.initialBorderColor;
  }

  Color _iconColor() {
    if (_isFocused) return widget.focusedIconColor;
    if (_hasText) return widget.filledIconColor;
    return widget.initialIconColor;
  }

  OutlineInputBorder _border(Color color, {double? width}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(widget.borderRadius),
    borderSide: BorderSide(color: color, width: width ?? widget.borderWidth),
  );

  @override
  Widget build(BuildContext context) {
    // Suffix final (prioridad: custom > toggle eye > clear)
    Widget? suffix = widget.suffixIcon;
    if (suffix == null) {
      if (widget.showObscureToggle) {
        suffix = IconButton(
          tooltip: _obscure ? 'Mostrar' : 'Ocultar',
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: SvgPicture.asset(
            _obscure
                ? 'lib/assets/icons/eye.svg'       // 👁 mostrar
                : 'lib/assets/icons/eye-closed.svg',  // 🚫 ocultar
            width: 20,
            height: 20,
            color: _iconColor(), // opcional: para aplicar color dinámico
          ),
        );
      } else if (widget.suffixClear && _hasText && _isFocused) {
        suffix = IconButton(
          tooltip: 'Limpiar',
          onPressed: () => _controller.clear(),
          icon: const Icon(Icons.close),
          color: _iconColor(),
        );
      }
    }

    // Prefijo con color reactivo (si pasas un icono, le aplicamos color via IconTheme)

    Widget? prefix;
    prefix = SvgPicture.asset(
      widget.actionIconAsset!, // ruta a tu SVG
      width: 13,
      height: 13,
      color: _iconColor(), // opcional, para recolorizar
      fit: BoxFit.scaleDown,

    );

    final Color bColor = _borderColor();

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      obscureText: _obscure,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.obscure ? 1 : widget.maxLines,
      style: AppTypography.poppins(size: 16),
      onChanged: widget.onChanged,
      validator: widget.validator,
      cursorColor: widget.focusedBorderColor,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),

      decoration: InputDecoration(
        // Sin label, solo hint
        hintText: widget.hint,
        hintStyle: AppTypography.poppins(size: 16).copyWith(
          color: const Color(0xFF9E9E9E),
        ),

        // Tamaño/espacios
        isDense: true,
        contentPadding: widget.contentPadding,

        // Fondo según estado
        filled: true,
        fillColor: _fillColor(),

        // Iconos
        prefixIcon: prefix,
        suffixIcon: suffix,

        // Bordes: usamos el mismo color calculado tanto en enabled como en focused
        enabledBorder: _border(bColor),
        focusedBorder: _border(bColor, width: widget.borderWidth + 0.6), // leve énfasis
        errorBorder: _border(widget.errorBorderColor),
        focusedErrorBorder: _border(widget.errorBorderColor, width: widget.borderWidth + 0.6),
      ),
    );
  }
}
