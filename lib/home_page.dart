import 'package:flutter/material.dart';
import 'models/accommodation.dart';
import 'services/accommodation_repository.dart';
import 'services/auth_service.dart';
import 'accommodation_details_page.dart';
import 'my_reservations_page.dart';
import 'profile_page.dart';
import 'theme/app_theme.dart';

/// Shell principal tras iniciar sesión. Contiene el menú inferior que alterna
/// entre Inicio, Mis Reservas y Perfil. Usa IndexedStack para conservar el
/// estado de cada pestaña al cambiar entre ellas.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  final _pages = const [
    _InicioView(),
    MyReservationsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.emerald100,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.emerald700),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon:
                Icon(Icons.receipt_long, color: AppColors.emerald700),
            label: 'Reservas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.emerald700),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

/// Pestaña de Inicio: hero, estadísticas, alojamientos destacados y pasos.
class _InicioView extends StatelessWidget {
  const _InicioView();

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
    final destacados = AccommodationRepository().all().take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const EcoSpotLogo(),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout, color: AppColors.emerald700),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== Hero con foto de fondo =====
            Container(
              width: double.infinity,
              color: AppColors.emerald800,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.28,
                      child: Image.network(
                        'https://images.unsplash.com/photo-1611946022552-d2ca5ffba186?auto=format&fit=crop&w=1080&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 56),
                    child: Column(
                      children: [
                        const Text(
                          'Viaja Más, Gasta Menos',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Encuentra alojamientos económicos, paquetes '
                          'turísticos accesibles y transporte público '
                          'disponible. Tu próxima aventura no tiene que ser '
                          'costosa.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.emerald100,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/search'),
                            icon: const Icon(Icons.search, size: 20),
                            label:
                                const Text('Buscar Opciones Económicas'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald500,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
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
                          value: '12k+',
                          label: 'Viajeros',
                          color: AppColors.blue600),
                      SizedBox(width: 12),
                      _StatCard(
                          icon: Icons.trending_up,
                          value: '8.5k+',
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Alojamientos Destacados',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/search'),
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: destacados
                    .map((a) => _FeaturedCard(
                          accommodation: a,
                          onTap: () => _abrirDetalle(context, a),
                        ))
                    .toList(),
              ),
            ),

            // ===== ¿Cómo Funciona? =====
            const SizedBox(height: 16),
            const Text(
              '¿Cómo Funciona?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _StepCard(
                    icon: Icons.search,
                    title: '1. Busca',
                    desc:
                        'Filtra por presupuesto, tipo y transporte disponible.',
                  ),
                  SizedBox(height: 20),
                  _StepCard(
                    icon: Icons.verified_user_outlined,
                    title: '2. Reserva',
                    desc: 'Solicita tu reserva directamente al operador.',
                  ),
                  SizedBox(height: 20),
                  _StepCard(
                    icon: Icons.attach_money,
                    title: '3. Paga',
                    desc: 'Pago seguro al confirmar tu reserva.',
                  ),
                  SizedBox(height: 20),
                  _StepCard(
                    icon: Icons.star_outline,
                    title: '4. Disfruta',
                    desc: 'Vive la experiencia y deja tu reseña.',
                  ),
                ],
              ),
            ),

            // ===== Footer =====
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              color: AppColors.emerald900,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: const Text(
                '© 2026 EcoSpot - Gestión de Turismo Económico.\n'
                'Todos los derechos reservados.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.emerald100, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
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
                          child: const Text('Ver detalle'),
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

/// Tarjeta de estadística decorativa (estilo del diseño).
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
            Text(
              value,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paso de "¿Cómo Funciona?" con ícono en círculo emerald.
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
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.mutedForeground),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
