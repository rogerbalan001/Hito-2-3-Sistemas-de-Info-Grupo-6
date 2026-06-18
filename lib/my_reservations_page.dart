import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'services/reservation_service.dart';
import 'theme/app_theme.dart';

/// Hito 3 - Flujo de Reservas.
/// Interfaz que consume ReservationService.misReservas() y muestra las
/// reservaciones del usuario con su estado actual:
/// Solicitado -> Aceptado -> Pagado -> Disfrutado, cada uno con un color.
class MyReservationsPage extends StatelessWidget {
  const MyReservationsPage({Key? key}) : super(key: key);

  /// Color asociado a cada estado del ciclo de vida de la reserva.
  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Aceptado':
        return AppColors.blue600;
      case 'Pagado':
        return AppColors.emerald600;
      case 'Disfrutado':
        return AppColors.emerald800;
      case 'Cancelado':
        return AppColors.red600;
      case 'Solicitado':
      default:
        return AppColors.amber500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _ReservasHeader(),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ReservationService().misReservas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No se pudieron cargar las reservas:\n'
                    '${snapshot.error}'),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          // Orden en cliente por fecha descendente (evita índice compuesto).
          docs.sort((a, b) {
            final fa = a.data()['fecha'];
            final fb = b.data()['fecha'];
            if (fa is Timestamp && fb is Timestamp) {
              return fb.compareTo(fa);
            }
            return 0;
          });

          if (docs.isEmpty) {
            return const _EstadoVacio();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data();
              final estado = (data['estado'] ?? 'Solicitado') as String;
              final precio = (data['precioPorNoche'] ?? 0).toDouble();
              return _ReservaCard(
                alojamiento: (data['alojamiento'] ?? '') as String,
                ubicacion: (data['ubicacion'] ?? '') as String,
                precioPorNoche: precio,
                estado: estado,
                color: _colorEstado(estado),
              );
            },
          );
        },
          ),
        ),
      ],
    );
  }
}

class _ReservaCard extends StatelessWidget {
  final String alojamiento;
  final String ubicacion;
  final double precioPorNoche;
  final String estado;
  final Color color;

  const _ReservaCard({
    required this.alojamiento,
    required this.ubicacion,
    required this.precioPorNoche,
    required this.estado,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicador de color del estado.
          Container(
            width: 6,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alojamiento,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    // Chip de estado.
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        estado,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 14, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text(ubicacion,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.mutedForeground)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${precioPorNoche.round()}/noche',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.emerald700,
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

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 56, color: AppColors.mutedForeground),
            SizedBox(height: 16),
            Text(
              'Aún no tienes reservas',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              'Busca un alojamiento y solicita tu primera reserva.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}

/// Encabezado de la pestaña Reservas: título + flujo de estados.
/// Desde la integración de pagos, la reserva nace directo en "Pagado" (el
/// pago con PayPal se confirma al momento de reservar, sin aprobación
/// previa); "Disfrutado" se marca después de la estadía.
class _ReservasHeader extends StatelessWidget {
  const _ReservasHeader();

  @override
  Widget build(BuildContext context) {
    const pasos = [
      ['Pagado', AppColors.emerald600],
      ['Disfrutado', AppColors.emerald800],
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis Reservas',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tu historial de reservas pagadas',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 16),
          // Flujo de estados.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < pasos.length; i++) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (pasos[i][1] as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      pasos[i][0] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: pasos[i][1] as Color,
                      ),
                    ),
                  ),
                  if (i < pasos.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.arrow_forward,
                          size: 14, color: AppColors.mutedForeground),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
