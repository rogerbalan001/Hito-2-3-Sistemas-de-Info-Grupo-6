import 'package:flutter/material.dart';
import 'data/mock_data.dart';
import 'theme/app_theme.dart';

/// Pantalla de Paquetes Turísticos (cuadrícula responsiva de tarjetas).
class PackagesPage extends StatelessWidget {
  const PackagesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        const Text('Paquetes Turísticos',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text(
          'Experiencias completas a precios accesibles',
          style: TextStyle(color: AppColors.mutedForeground),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final cols = w >= 1000 ? 3 : (w >= 640 ? 2 : 1);
            final cardW = (w - 16 * (cols - 1)) / cols;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: MockData.packages
                  .map((p) => SizedBox(
                        width: cardW,
                        child: PackageCard(package: p),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

/// Tarjeta de paquete: foto, nombre, destino·duración, incluye, precio, rating.
class PackageCard extends StatelessWidget {
  final TouristPackage package;
  const PackageCard({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final p = package;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: EcoImage(url: p.imageUrl, height: 150),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${p.destination} · ${p.duration}',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.mutedForeground)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: p.includes
                      .map((i) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.emerald50,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(i,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.emerald700,
                                    fontWeight: FontWeight.w500)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${p.price}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.emerald700)),
                    StarRating(rating: p.rating),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
