import 'package:flutter/material.dart';
import 'models/accommodation.dart';
import 'services/accommodation_repository.dart';
import 'accommodation_details_page.dart';
import 'packages_page.dart';
import 'data/mock_data.dart';
import 'theme/app_theme.dart';

/// Pestaña de Inicio: hero con foto, estadísticas, alojamientos destacados,
/// paquetes turísticos y los pasos "¿Cómo Funciona?". Recibe [onNavigate]
/// para cambiar de pestaña en el shell (Buscar, Paquetes, Operadores).
class InicioPage extends StatelessWidget {
  final void Function(int index) onNavigate;
  const InicioPage({Key? key, required this.onNavigate}) : super(key: key);

  void _abrirDetalle(BuildContext context, Accommodation a) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccommodationDetailsPage(accommodation: a),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paquetes = MockData.packages.take(3).toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ===== Hero con foto de fondo y dos CTAs =====
        Container(
          width: double.infinity,
          color: AppColors.emerald800,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.30,
                  child: Image.network(
                    EcoImages.beach,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
                child: Column(
                  children: [
                    const Text(
                      'Viaja Más, Gasta Menos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: const Text(
                        'Encuentra alojamientos económicos, paquetes '
                        'turísticos accesibles y transporte público '
                        'disponible. Tu próxima aventura no tiene que ser '
                        'costosa.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.emerald100,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => onNavigate(1),
                            icon: const Icon(Icons.search, size: 20),
                            label:
                                const Text('Buscar Opciones Económicas'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald500,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 22),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => onNavigate(5),
                            icon: const Icon(Icons.place_outlined, size: 20),
                            label: const Text('Registrar mi Servicio'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 22),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ===== Stats (2x2) =====
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
          child: Column(
            children: const [
              Row(
                children: [
                  _StatCard(
                      icon: Icons.place_outlined,
                      value: '50+',
                      label: 'Destinos',
                      color: AppColors.emerald600),
                  SizedBox(width: 12),
                  _StatCard(
                      icon: Icons.attach_money,
                      value: '\$10',
                      label: 'Desde/noche',
                      color: AppColors.amber600),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(
                      icon: Icons.groups_outlined,
                      value: '12,000+',
                      label: 'Viajeros',
                      color: AppColors.blue600),
                  SizedBox(width: 12),
                  _StatCard(
                      icon: Icons.trending_up,
                      value: '8,500+',
                      label: 'Reseñas',
                      color: AppColors.purple600),
                ],
              ),
            ],
          ),
        ),

        // ===== Alojamientos destacados =====
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: SectionHeader(
            title: 'Alojamientos Destacados',
            onSeeAll: () => onNavigate(1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StreamBuilder<List<Accommodation>>(
            stream: AccommodationRepository().watchAll(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final destacados =
                  (snapshot.data ?? const <Accommodation>[]).take(3).toList();
              return Column(
                children: destacados
                    .map((a) => _FeaturedCard(
                          accommodation: a,
                          onTap: () => _abrirDetalle(context, a),
                        ))
                    .toList(),
              );
            },
          ),
        ),

        // ===== Paquetes turísticos (fondo emerald-50) =====
        const SizedBox(height: 8),
        Container(
          color: AppColors.emerald50,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            children: [
              SectionHeader(
                title: 'Paquetes Turísticos',
                onSeeAll: () => onNavigate(2),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  final cols = w >= 1000 ? 3 : (w >= 640 ? 2 : 1);
                  final cardW = (w - 16 * (cols - 1)) / cols;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: paquetes
                        .map((p) => SizedBox(
                            width: cardW, child: PackageCard(package: p)))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),

        // ===== ¿Cómo Funciona? =====
        const SizedBox(height: 32),
        const Text(
          '¿Cómo Funciona?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _StepCard(
                icon: Icons.search,
                title: 'Busca',
                desc: 'Filtra por presupuesto, tipo y transporte disponible.',
              ),
              SizedBox(height: 20),
              _StepCard(
                icon: Icons.verified_user_outlined,
                title: 'Reserva',
                desc: 'Solicita tu reserva directamente al operador.',
              ),
              SizedBox(height: 20),
              _StepCard(
                icon: Icons.attach_money,
                title: 'Paga',
                desc: 'Pago seguro vía PayPal o tarjeta.',
              ),
              SizedBox(height: 20),
              _StepCard(
                icon: Icons.star_outline,
                title: 'Disfruta',
                desc: 'Vive la experiencia y deja tu reseña.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
        const EcoFooter(),
      ],
    );
  }
}

/// Tarjeta de alojamiento destacado: foto arriba + datos + rating + precio.
class _FeaturedCard extends StatelessWidget {
  final Accommodation accommodation;
  final VoidCallback onTap;
  const _FeaturedCard({required this.accommodation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = accommodation;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: EcoImage(url: a.imageUrl, height: 170),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
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
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _TypeBadge(type: a.type),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 14, color: AppColors.mutedForeground),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            a.location,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedForeground),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    StarRating(rating: a.rating, reviewCount: a.reviewCount),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '\$${a.pricePerNight.round()}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.emerald700,
                                ),
                              ),
                              const TextSpan(
                                text: '/noche',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            minimumSize: const Size(0, 36),
                            textStyle: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Reservar'),
                        ),
                      ],
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

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.emerald100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        type,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.emerald700,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700)),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.mutedForeground)),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _StepCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.emerald100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppColors.emerald700, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(desc,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.mutedForeground)),
            ],
          ),
        ),
      ],
    );
  }
}
