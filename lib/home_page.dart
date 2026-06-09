import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            // ===== Hero =====
            Container(
              width: double.infinity,
              color: AppColors.emerald800,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
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
                    'Encuentra alojamientos económicos, paquetes turísticos '
                    'accesibles y transporte público disponible. Tu próxima '
                    'aventura no tiene que ser costosa.',
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
                      onPressed: () => Navigator.pushNamed(context, '/search'),
                      icon: const Icon(Icons.search, size: 20),
                      label: const Text('Buscar Opciones Económicas'),
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

            // ===== Stats =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: const [
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
                      color: AppColors.amber500),
                ],
              ),
            ),

            // ===== ¿Cómo Funciona? =====
            const SizedBox(height: 24),
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
                    title: '1. Busca destinos',
                    desc:
                        'Filtra por presupuesto, tipo y transporte disponible.',
                  ),
                  SizedBox(height: 20),
                  _StepCard(
                    icon: Icons.verified_user_outlined,
                    title: '2. Reserva segura',
                    desc: 'Solicita tu reserva directamente al operador.',
                  ),
                  SizedBox(height: 20),
                  _StepCard(
                    icon: Icons.star_outline,
                    title: '3. Disfruta y califica',
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
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700),
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
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
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
