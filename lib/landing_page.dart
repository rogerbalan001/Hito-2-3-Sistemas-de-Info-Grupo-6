import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

/// Página pública de presentación (landing) de EcoSpot.
///
/// Es lo primero que ve un visitante sin sesión: un hero con la marca, una
/// breve propuesta de valor y dos accesos —"Iniciar Sesión" y "Crear
/// Cuenta"— que llevan a las pantallas de autenticación. Antes, la app abría
/// directo en el login; ahora el login queda detrás de esta presentación.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mismo gradiente de marca que usa el login, para dar continuidad.
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.emerald50, AppColors.blue50, AppColors.purple50],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Marca: ícono en caja redondeada + nombre.
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.emerald600,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emerald600.withOpacity(0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.terrain,
                          color: Colors.white, size: 44),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'EcoSpot',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.emerald800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Descubre y reserva alojamientos de turismo '
                      'ecológico en toda la región.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.mutedForeground,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Resumen de la propuesta de valor.
                    const _Beneficios(),
                    const SizedBox(height: 32),

                    // Accesos a autenticación.
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/login'),
                        icon: const Icon(Icons.login, size: 20),
                        label: const Text('Iniciar Sesión'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'),
                        icon: const Icon(Icons.person_add_alt_1, size: 20),
                        label: const Text('Crear Cuenta'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.emerald700,
                          side: const BorderSide(color: AppColors.emerald600),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Turismo responsable · Precios verificados por la '
                      'comunidad',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tres beneficios breves que resumen para qué sirve EcoSpot.
class _Beneficios extends StatelessWidget {
  const _Beneficios();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        children: [
          _Beneficio(
            icon: Icons.eco_outlined,
            titulo: 'Alojamientos eco-sostenibles',
            detalle: 'Posadas, campings y eco-lodges seleccionados.',
          ),
          SizedBox(height: 16),
          _Beneficio(
            icon: Icons.verified_outlined,
            titulo: 'Precios reales',
            detalle: 'La comunidad valida que el costo publicado se cumpla.',
          ),
          SizedBox(height: 16),
          _Beneficio(
            icon: Icons.event_available_outlined,
            titulo: 'Reserva en minutos',
            detalle: 'Elige tus fechas y paga de forma segura.',
          ),
        ],
      ),
    );
  }
}

class _Beneficio extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String detalle;
  const _Beneficio({
    required this.icon,
    required this.titulo,
    required this.detalle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.emerald50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.emerald700, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(detalle,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.mutedForeground)),
            ],
          ),
        ),
      ],
    );
  }
}
