import 'package:flutter/material.dart';

/// Paleta y tema visual de EcoSpot.
///
/// Los colores replican la guía de estilo creada en Figma Make
/// (EcoSpot-Design): una paleta "emerald" con tarjetas blancas,
/// esquinas muy redondeadas y acentos en ámbar/azul.
class AppColors {
  AppColors._();

  // Verde principal (Tailwind "emerald").
  static const emerald50 = Color(0xFFECFDF5);
  static const emerald100 = Color(0xFFD1FAE5);
  static const emerald200 = Color(0xFFA7F3D0);
  static const emerald300 = Color(0xFF6EE7B7);
  static const emerald400 = Color(0xFF34D399);
  static const emerald500 = Color(0xFF10B981);
  static const emerald600 = Color(0xFF059669);
  static const emerald700 = Color(0xFF047857);
  static const emerald800 = Color(0xFF065F46);
  static const emerald900 = Color(0xFF064E3B);

  // Acentos.
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const blue50 = Color(0xFFEFF6FF);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue200 = Color(0xFFBFDBFE);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8);
  static const purple50 = Color(0xFFFAF5FF);
  static const purple600 = Color(0xFF9333EA);
  static const red50 = Color(0xFFFEF2F2);
  static const red600 = Color(0xFFDC2626);

  // Neutros (tomados del theme.css del diseño).
  static const background = Color(0xFFFFFFFF);
  static const foreground = Color(0xFF1A1A1A);
  static const mutedForeground = Color(0xFF717182);
  static const inputBackground = Color(0xFFF3F3F5);
  static const border = Color(0x1A000000); // rgba(0,0,0,0.1)
}

/// Construye el ThemeData global de la aplicación.
ThemeData buildEcoSpotTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.emerald600,
      primary: AppColors.emerald600,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.emerald800,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.emerald800,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: AppColors.emerald700),
    ),
    // Inputs redondeados con fondo gris claro, como en el diseño.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: AppColors.mutedForeground),
      labelStyle: const TextStyle(color: AppColors.mutedForeground),
      prefixIconColor: AppColors.mutedForeground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.emerald500, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.emerald600,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.emerald600),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
  );
}

/// Logo reutilizable: ícono de montaña + texto "EcoSpot".
class EcoSpotLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  const EcoSpotLogo({super.key, this.iconSize = 28, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.terrain, size: iconSize, color: AppColors.emerald700),
        const SizedBox(width: 8),
        Text(
          'EcoSpot',
          style: TextStyle(
            color: AppColors.emerald800,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Imagen de red con degradado de respaldo (equivalente a ImageWithFallback
/// del Figma). Si la URL es nula o falla la carga, muestra un degradado
/// emerald con un ícono, evitando que se vea un error roto.
class EcoImage extends StatelessWidget {
  final String? url;
  final double height;
  final double? width;
  final IconData fallbackIcon;
  const EcoImage({
    super.key,
    required this.url,
    required this.height,
    this.width,
    this.fallbackIcon = Icons.terrain,
  });

  Widget _fallback() {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.emerald300, AppColors.emerald700],
        ),
      ),
      child: Icon(fallbackIcon, color: Colors.white.withOpacity(0.9), size: 48),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = url;
    if (u == null || u.isEmpty) return _fallback();
    return Image.network(
      u,
      height: height,
      width: width ?? double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: height,
          width: width ?? double.infinity,
          color: AppColors.emerald50,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.emerald400),
          ),
        );
      },
    );
  }
}

/// Estrella + valoración + número de reseñas, como en las tarjetas del diseño.
class StarRating extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double fontSize;
  const StarRating({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, size: 16, color: AppColors.amber500),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
        if (reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
                fontSize: fontSize, color: AppColors.mutedForeground),
          ),
        ],
      ],
    );
  }
}

/// Pie de página verde, como en el diseño.
class EcoFooter extends StatelessWidget {
  const EcoFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.emerald900,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: const Text(
        '© 2026 EcoSpot - Gestión de Turismo Económico.\n'
        'Todos los derechos reservados.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.emerald100, fontSize: 13),
      ),
    );
  }
}

/// Encabezado de sección reutilizable: título + acción "Ver todos".
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const SectionHeader({super.key, required this.title, this.onSeeAll});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700)),
        ),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('Ver todos')),
      ],
    );
  }
}
