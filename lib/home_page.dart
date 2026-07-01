import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart'; // Ajusta la ruta si es necesario
import 'add_accommodation_page.dart';
import 'my_reservations_page.dart';
import 'profile_page.dart';

/// Shell principal tras iniciar sesión. Contiene el menú inferior que alterna
/// entre Inicio, Mis Reservas y Perfil.
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
            selectedIcon: Icon(Icons.receipt_long, color: AppColors.emerald700),
            label: 'Mis Reservas',
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

/// Contenido de la pestaña "Inicio"
class _InicioView extends StatelessWidget {
  const _InicioView();

  @override
  Widget build(BuildContext context) {
    const heroImage =
        'https://images.unsplash.com/photo-1611946022552-d2ca5ffba186?auto=format&fit=crop&w=1080&q=80';

    return Scaffold(
      backgroundColor: AppColors.background,
      // BARRA DE NAVEGACIÓN SUPERIOR (APPBAR) DINÁMICA
      appBar: AppBar(
        title: const EcoSpotLogo(),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.home_outlined, size: 18),
            label: const Text('Inicio'),
            style: TextButton.styleFrom(foregroundColor: AppColors.foreground),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/search'),
            icon: const Icon(Icons.search, size: 18),
            label: const Text('Buscar'),
            style: TextButton.styleFrom(foregroundColor: AppColors.mutedForeground),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.inventory_2_outlined, size: 18),
            label: const Text('Paquetes'),
            style: TextButton.styleFrom(foregroundColor: AppColors.mutedForeground),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.receipt_long_outlined, size: 18),
            label: const Text('Reservas'),
            style: TextButton.styleFrom(foregroundColor: AppColors.mutedForeground),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.people_outline, size: 18),
            label: const Text('Comunidad'),
            style: TextButton.styleFrom(foregroundColor: AppColors.mutedForeground),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.place_outlined, size: 18),
            label: const Text('Operadores'),
            style: TextButton.styleFrom(foregroundColor: AppColors.mutedForeground),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.dashboard_outlined, size: 18),
            label: const Text('Dashboard'),
            style: TextButton.styleFrom(foregroundColor: AppColors.mutedForeground),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, size: 18),
            label: const Text('Administración'),
            style: TextButton.styleFrom(foregroundColor: AppColors.mutedForeground),
          ),
          
          // CONTROL DE FLUJO DE USUARIO EN TIEMPO REAL (LOGIN / NOMBRE DE CUENTA)
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final user = snapshot.data!;
                final displayName = user.displayName ?? user.email ?? 'Cuenta';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/profile'),
                      icon: const Icon(Icons.account_circle_outlined, color: AppColors.emerald600, size: 20),
                      label: Text(
                        displayName,
                        style: const TextStyle(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }
              
              // Si no está logueado muestra el botón por defecto
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: const Icon(Icons.login, size: 16),
                  label: const Text('Iniciar Sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // SECCIÓN 1: STACK HERO + ESTADÍSTICAS
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 440,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(heroImage),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Viaja Más, Gasta Menos',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Encuentra hospedajes sostenibles y económicos en toda Venezuela',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/search'),
                              icon: const Icon(Icons.search, size: 20),
                              label: const Text('Buscar Opciones Económicas'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.emerald500,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          // Botón "Registrar mi Servicio" solo visible para administradores.
                          if (AuthService().isCurrentUserAdmin) ...[
                            const SizedBox(width: 16),
                            SizedBox(
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AddAccommodationPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.place_outlined, size: 20),
                                label: const Text('Registrar mi Servicio'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white, width: 1.5),
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: 60,
                right: 60,
                child: Row(
                  children: const [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.place_outlined,
                        value: '50+',
                        label: 'Destinos',
                        color: AppColors.emerald600,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.attach_money,
                        value: '\$10/noche',
                        label: 'Desde',
                        color: AppColors.amber600,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.groups_outlined,
                        value: '12,000+',
                        label: 'Viajeros',
                        color: AppColors.blue600,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.trending_up,
                        value: '8,500+',
                        label: 'Reseñas',
                        color: AppColors.purple600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 90),

          // SECCIÓN 2: ALOJAMIENTOS DESTACADOS
          const _FeaturedSection(),

          const SizedBox(height: 20),

          // SECCIÓN 3: PAQUETES TURÍSTICOS CON FONDO MENTA
          const _PackagesSection(),

          const SizedBox(height: 50),

          // SECCIÓN 4: ¿CÓMO FUNCIONA? HORIZONTAL REESTRUCTURADO
          const _HowItWorksHorizontal(),
          
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

// ==========================================
// COMPONENTES REESTRUCTURADOS EN ALTA FIDELIDAD
// ==========================================

class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Alojamientos Destacados',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.foreground),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/search'),
                child: Row(
                  children: const [
                    Text('Ver todos', style: TextStyle(color: AppColors.emerald600, fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16, color: AppColors.emerald600),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(
                child: _AccommodationCard(
                  imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=500&q=80',
                  title: 'Posada Sol del Caribe',
                  location: 'Isla Margarita',
                  tag: 'posada',
                  price: '25',
                  rating: '4.5 (89)',
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _AccommodationCard(
                  imageUrl: 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?auto=format&fit=crop&w=500&q=80',
                  title: 'Camping Montaña Azul',
                  location: 'Mérida',
                  tag: 'camping',
                  price: '10',
                  rating: '4.2 (56)',
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _AccommodationCard(
                  imageUrl: 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=500&q=80',
                  title: 'Hostel Colonial Center',
                  location: 'Cartagena',
                  tag: 'hostel',
                  price: '18',
                  rating: '4.7 (134)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccommodationCard extends StatelessWidget {
  final String imageUrl, title, location, tag, price, rating;
  const _AccommodationCard({
    required this.imageUrl, required this.title, required this.location,
    required this.tag, required this.price, required this.rating
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.emerald50, borderRadius: BorderRadius.circular(20)),
                      child: Text(tag, style: const TextStyle(color: AppColors.emerald700, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 14, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text(location, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: [
                        Text('\$$price', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.emerald700)),
                        const Text('/noche', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text('Reservar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _PackagesSection extends StatelessWidget {
  const _PackagesSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFEAF7F2), // Fondo verde menta de la imagen original
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Paquetes Turísticos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.foreground),
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: const [
                    Text('Ver todos', style: TextStyle(color: AppColors.emerald600, fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16, color: AppColors.emerald600),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(
                child: _PackageCard(
                  imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=500&q=80',
                  title: 'Aventura Andina',
                  details: 'Mérida - 5 días / 4 noches',
                  tags: ['Alojamiento', 'Transporte', 'Guía', 'Comidas'],
                  price: '120',
                  rating: '4.6',
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _PackageCard(
                  imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=500&q=80',
                  title: 'Paraíso Caribeño',
                  details: 'Isla Margarita - 4 días / 3 noches',
                  tags: ['Alojamiento', 'Ferry', 'Tours', 'Desayunos'],
                  price: '150',
                  rating: '4.8',
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _PackageCard(
                  imageUrl: 'https://images.unsplash.com/photo-1454496522488-7a8e488e8606?auto=format&fit=crop&w=500&q=80',
                  title: 'Selva Mágica',
                  details: 'Canaima - 3 días / 2 noches',
                  tags: ['Alojamiento', 'Vuelo', 'Excursiones', 'Comidas'],
                  price: '200',
                  rating: '4.9',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final String imageUrl, title, details, price, rating;
  final List<String> tags;
  const _PackageCard({
    required this.imageUrl, required this.title, required this.details,
    required this.tags, required this.price, required this.rating
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(details, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(6)),
                    child: Text(t, style: const TextStyle(color: AppColors.emerald700, fontSize: 11)),
                  )).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$$price', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.emerald700)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(rating, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _HowItWorksHorizontal extends StatelessWidget {
  const _HowItWorksHorizontal();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          const Text(
            '¿Cómo Funciona?',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.foreground),
          ),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: _HorizontalStep(
                  icon: Icons.search,
                  title: 'Busca',
                  desc: 'Filtra por presupuesto, tipo y transporte disponible',
                ),
              ),
              Expanded(
                child: _HorizontalStep(
                  icon: Icons.shield_outlined,
                  title: 'Reserva',
                  desc: 'Solicita tu reserva directamente al operador',
                ),
              ),
              Expanded(
                child: _HorizontalStep(
                  icon: Icons.attach_money,
                  title: 'Paga',
                  desc: 'Pago seguro vía PayPal o tarjeta',
                ),
              ),
              Expanded(
                child: _HorizontalStep(
                  icon: Icons.star_outline,
                  title: 'Disfruta',
                  desc: 'Vive la experiencia y deja tu reseña',
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _HorizontalStep extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  const _HorizontalStep({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: AppColors.emerald50, shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.emerald600, size: 28),
        ),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.foreground)),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}
