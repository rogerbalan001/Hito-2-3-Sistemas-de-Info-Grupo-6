import 'package:flutter/material.dart';
import 'theme/app_theme.dart'; // Ajusta esta ruta si tu archivo app_theme.dart está en otra carpeta
import 'add_accommodation_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InicioView();
  }
}

class _InicioView extends StatelessWidget {
  const _InicioView();

  @override
  Widget build(BuildContext context) {
    // Foto sacada del Figma/Unsplash del proyecto para el Hero
    const heroImage =
        'https://images.unsplash.com/photo-1611946022552-d2ca5ffba186?auto=format&fit=crop&w=1080&q=80';

    return Scaffold(
      backgroundColor: AppColors.background,
      // 1. BARRA DE NAVEGACIÓN EXTENDIDA (APPBAR)
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
          Padding(
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
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // STACK PARA MONTAR EL HERO Y LAS ESTADÍSTICAS SUPERPUESTAS (OVERLAP)
          Stack(
            clipBehavior: Clip.none,
            children: [
              // 2. SECCIÓN HERO CON FOTO DE FONDO
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
                      
                      // DOS BOTONES CENTRALES EN FILA
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
                      ),
                    ],
                  ),
                ),
              ),
              
              // 3. CONTENEDOR DE ESTADÍSTICAS HORIZONTAL (SOLAPADO)
              Positioned(
                bottom: -40,
                left: 24,
                right: 24,
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
          
          const SizedBox(height: 80),

          // 4. SECCIÓN INTERNA: ¿CÓMO FUNCIONA?
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Cómo funciona EcoSpot?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Conectamos comunidades locales con viajeros conscientes.',
                  style: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                ),
                const SizedBox(height: 28),
                const _StepCard(
                  icon: Icons.search_outlined,
                  title: '1. Encuentra tu spot',
                  desc: 'Filtra por precio máximo, destino y tipo de hospedaje ecológico según tu presupuesto real.',
                ),
                const SizedBox(height: 20),
                const _StepCard(
                  icon: Icons.mark_email_read_outlined,
                  title: '2. Solicita tu reserva',
                  desc: 'Envía una solicitud al operador turístico local. Recibirás respuesta rápida en tu panel.',
                ),
                const SizedBox(height: 20),
                const _StepCard(
                  icon: Icons.spa_outlined,
                  title: '3. Viaja sostenible',
                  desc: 'Disfruta de Venezuela reduciendo tu huella ecológica y apoyando la economía de la región.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// TARJETA DE ESTADÍSTICAS INDIVIDUAL
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
    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

// TARJETA DE PASOS INTERNOS
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.emerald50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.emerald600, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
