import 'package:flutter/material.dart';
import 'data/mock_data.dart';
import 'services/package_service.dart';
import 'services/reservation_service.dart';
import 'utils/auth_guard.dart';
import 'theme/app_theme.dart';

/// Pantalla de Paquetes Turísticos (cuadrícula responsiva de tarjetas).
class PackagesPage extends StatelessWidget {
  const PackagesPage({Key? key}) : super(key: key);

  /// Crea la reserva del paquete en estado "Solicitado". El pago se habilita
  /// después, cuando el administrador apruebe la solicitud.
  Future<void> _reservar(BuildContext context, TouristPackage p) async {
    // Sin sesión activa no se puede reservar: se avisa y se manda a login.
    if (!requireLogin(context, accion: 'reservar')) return;

    // Control de fechas: el viajero elige el rango de su estadía antes de
    // crear la solicitud. Si cancela el selector, se aborta la reserva.
    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Elige las fechas de tu estadía',
      saveText: 'Confirmar',
    );
    if (rango == null) return;
    if (!context.mounted) return;
    try {
      await ReservationService().crearReserva(
        alojamiento: p.name,
        ubicacion: p.destination,
        precioPorNoche: p.price,
        fechaInicio: rango.start,
        fechaFin: rango.end,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud enviada. Cuando el administrador la '
              'apruebe podrás pagarla desde "Mis Reservas".'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar la solicitud: $e')),
      );
    }
  }

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
        StreamBuilder<List<TouristPackage>>(
          stream: PackageService().watchAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final paquetes = snapshot.data ?? const <TouristPackage>[];
            if (paquetes.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text('No hay paquetes disponibles',
                      style: TextStyle(color: AppColors.mutedForeground)),
                ),
              );
            }
            return LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final cols = w >= 1000 ? 3 : (w >= 640 ? 2 : 1);
                final cardW = (w - 16 * (cols - 1)) / cols;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: paquetes
                      .map((p) => SizedBox(
                            width: cardW,
                            child: PackageCard(
                              package: p,
                              onReserve: () => _reservar(context, p),
                            ),
                          ))
                      .toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

/// Tarjeta de paquete: foto, nombre, destino·duración, incluye, precio,
/// rating y un botón "Reservar" que abre la pasarela de pago.
class PackageCard extends StatelessWidget {
  final TouristPackage package;
  final VoidCallback? onReserve;
  const PackageCard({super.key, required this.package, this.onReserve});

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('\$${p.price}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.emerald700)),
                    StarRating(rating: p.rating),
                  ],
                ),
                if (onReserve != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: onReserve,
                      icon: const Icon(Icons.event_available, size: 18),
                      label: const Text('Reservar'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
