import 'package:flutter/material.dart';
import 'models/accommodation.dart';
import 'payment_page.dart';
import 'theme/app_theme.dart';

/// CU-02: Consultar detalle de servicio.
/// Se abre con Navigator.push desde la lista de búsqueda, recibiendo el
/// [Accommodation] por constructor. Muestra foto, rating, amenidades,
/// descripción, reglas y el botón definitivo de "Reservar" (RF04).
class AccommodationDetailsPage extends StatelessWidget {
  final Accommodation accommodation;
  const AccommodationDetailsPage({Key? key, required this.accommodation})
      : super(key: key);

  IconData _iconFor(String type) {
    switch (type) {
      case 'Camping':
        return Icons.park;
      case 'Hostal':
        return Icons.bed;
      case 'Cabaña':
        return Icons.cabin;
      case 'Eco-Lodge':
        return Icons.forest;
      default:
        return Icons.hotel;
    }
  }

  String _descripcion() {
    if (accommodation.description != null &&
        accommodation.description!.trim().isNotEmpty) {
      return accommodation.description!;
    }
    return 'Alojamiento de tipo ${accommodation.type.toLowerCase()} ubicado en '
        '${accommodation.location}. Una opción económica y sostenible, ideal '
        'para viajeros que buscan vivir la experiencia local sin gastar de más.';
  }

  List<String> _reglas() {
    if (accommodation.rules.isNotEmpty) return accommodation.rules;
    return const [
      'Check-in desde las 2:00 PM · Check-out hasta las 11:00 AM',
      'No se permiten fiestas ni eventos',
      'Respetar las áreas comunes y el entorno natural',
      'Mascotas permitidas bajo previo aviso',
    ];
  }

  /// Ya no crea la reserva directamente: abre la pasarela de pago. La
  /// reserva solo se crea (en estado "Pagado") si el pago con PayPal se
  /// confirma allí.
  void _reservar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(accommodation: accommodation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = accommodation;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detalle del alojamiento')),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Foto de cabecera con respaldo en degradado.
          EcoImage(url: a.imageUrl, height: 230, fallbackIcon: _iconFor(a.type)),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        a.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.emerald100,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        a.type,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.emerald700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 16, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text(a.location,
                        style: const TextStyle(
                            color: AppColors.mutedForeground)),
                    const SizedBox(width: 12),
                    if (a.rating > 0)
                      StarRating(rating: a.rating, reviewCount: a.reviewCount),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.attach_money,
                      label: '\$${a.pricePerNight.round()}/noche',
                      color: AppColors.emerald700,
                    ),
                    const SizedBox(width: 10),
                    if (a.capacity != null)
                      _InfoChip(
                        icon: Icons.group_outlined,
                        label: 'Hasta ${a.capacity} personas',
                        color: AppColors.blue600,
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                const _SectionTitle('Descripción'),
                const SizedBox(height: 6),
                Text(
                  _descripcion(),
                  style: const TextStyle(
                      fontSize: 14, height: 1.5, color: AppColors.foreground),
                ),

                if (a.amenities.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const _SectionTitle('Amenidades'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: a.amenities
                        .map((am) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.emerald50,
                                borderRadius: BorderRadius.circular(999),
                                border:
                                    Border.all(color: AppColors.emerald100),
                              ),
                              child: Text(
                                am,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.emerald700,
                                    fontWeight: FontWeight.w500),
                              ),
                            ))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 24),
                const _SectionTitle('Reglas del lugar'),
                const SizedBox(height: 8),
                ..._reglas().map(
                  (regla) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 18, color: AppColors.emerald600),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(regla,
                              style: const TextStyle(
                                  fontSize: 14, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _reservar(context),
                    icon: const Icon(Icons.event_available, size: 20),
                    label: const Text('Reservar ahora'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700));
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: color, fontSize: 13)),
        ],
      ),
    );
  }
}
