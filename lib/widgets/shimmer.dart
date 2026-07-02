import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Mejora 4 — Skeleton / Shimmer loading.
/// Reemplaza el spinner genérico mientras Firestore devuelve datos.
/// Uso: `_ShimmerCard()` para tarjetas de alojamiento,
///      `_ShimmerList(count: 4)` para listas.

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const ShimmerBox({
    Key? key,
    required this.width,
    required this.height,
    this.radius = 8,
  }) : super(key: key);
  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: const Alignment(-1.5, 0),
            end: const Alignment(1.5, 0),
            transform: _SlideGradient(_anim.value),
            colors: const [
              Color(0xFFEEEEEE),
              Color(0xFFF8F8F8),
              Color(0xFFEEEEEE),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

class _SlideGradient extends GradientTransform {
  final double progress;
  const _SlideGradient(this.progress);
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * 2 * (progress - 0.5), 0, 0);
  }
}

/// Tarjeta skeleton para lista de alojamientos (horizontal).
class ShimmerAccommodationCard extends StatelessWidget {
  const ShimmerAccommodationCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        ShimmerBox(width: 110, height: 90, radius: 10),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: double.infinity, height: 14, radius: 6),
              const SizedBox(height: 8),
              ShimmerBox(width: 120, height: 12, radius: 6),
              const SizedBox(height: 12),
              ShimmerBox(width: 80, height: 12, radius: 6),
              const SizedBox(height: 12),
              ShimmerBox(width: 100, height: 28, radius: 8),
            ],
          ),
        ),
      ]),
    );
  }
}

/// Tarjeta skeleton para grid de alojamientos (vertical).
class ShimmerGridCard extends StatelessWidget {
  const ShimmerGridCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
              width: double.infinity, height: 140, radius: 14),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 13, radius: 6),
                const SizedBox(height: 8),
                ShimmerBox(width: 100, height: 11, radius: 6),
                const SizedBox(height: 10),
                ShimmerBox(width: 70, height: 11, radius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista de skeletons para pantallas de carga.
class ShimmerList extends StatelessWidget {
  final int count;
  final bool grid;
  const ShimmerList({Key? key, this.count = 4, this.grid = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (grid) {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 0.8,
        children:
            List.generate(count, (_) => const ShimmerGridCard()),
      );
    }
    return Column(
      children: List.generate(
          count, (_) => const ShimmerAccommodationCard()),
    );
  }
}
