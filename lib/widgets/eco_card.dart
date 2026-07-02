import 'package:flutter/material.dart';
import '../models/accommodation.dart';
import '../theme/app_theme.dart';

/// Mejora 5+6 — Tarjeta de alojamiento con overlay de gradiente y diseño
/// responsivo. Se usa en Inicio y Búsqueda.
/// En lista: imagen a la izquierda (horizontal).
/// En grid: imagen arriba con overlay de gradiente y nombre superpuesto.

enum EcoCardStyle { list, grid }

class EcoAccommodationCard extends StatelessWidget {
  final Accommodation accommodation;
  final VoidCallback onTap;
  final VoidCallback onReserve;
  final EcoCardStyle style;

  const EcoAccommodationCard({
    Key? key,
    required this.accommodation,
    required this.onTap,
    required this.onReserve,
    this.style = EcoCardStyle.list,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return style == EcoCardStyle.grid
        ? _GridCard(a: accommodation, onTap: onTap, onReserve: onReserve)
        : _ListCard(a: accommodation, onTap: onTap, onReserve: onReserve);
  }
}

// ── Tarjeta horizontal (lista) ───────────────────────────────────────────────

class _ListCard extends StatelessWidget {
  final Accommodation a;
  final VoidCallback onTap;
  final VoidCallback onReserve;
  const _ListCard(
      {required this.a, required this.onTap, required this.onReserve});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            children: [
              // Imagen con gradiente lateral para badge de precio
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(14)),
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: EcoImage(
                          url: a.imageUrl,
                          height: 120,
                          fallbackIcon: Icons.hotel),
                    ),
                  ),
                  // Badge de precio superpuesto
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.emerald700,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '\$${a.pricePerNight.round()}/n',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(a.name,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.emerald100,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(a.type,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.emerald700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.place_outlined,
                            size: 12, color: AppColors.mutedForeground),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(a.location,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mutedForeground),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                      if (a.rating > 0) ...[
                        const SizedBox(height: 4),
                        StarRating(rating: a.rating, reviewCount: a.reviewCount),
                      ],
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: onReserve,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14),
                            textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          child: const Text('Reservar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tarjeta vertical (grid) ──────────────────────────────────────────────────

class _GridCard extends StatelessWidget {
  final Accommodation a;
  final VoidCallback onTap;
  final VoidCallback onReserve;
  const _GridCard(
      {required this.a, required this.onTap, required this.onReserve});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen con overlay de degradado y nombre superpuesto
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14)),
                    child: SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: EcoImage(
                          url: a.imageUrl,
                          height: 140,
                          fallbackIcon: Icons.hotel),
                    ),
                  ),
                  // Gradiente oscuro sobre la imagen
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14)),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.55),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Badge de tipo arriba a la derecha
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(a.type,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  // Precio abajo a la izquierda sobre el gradiente
                  Positioned(
                    bottom: 8,
                    left: 10,
                    child: Text(
                      '\$${a.pricePerNight.round()}/noche',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(blurRadius: 4, color: Colors.black38),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Info debajo
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.place_outlined,
                          size: 11, color: AppColors.mutedForeground),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(a.location,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.mutedForeground),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    if (a.rating > 0) ...[
                      const SizedBox(height: 4),
                      StarRating(
                          rating: a.rating,
                          reviewCount: a.reviewCount,
                          fontSize: 11),
                    ],
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: onReserve,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Reservar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
