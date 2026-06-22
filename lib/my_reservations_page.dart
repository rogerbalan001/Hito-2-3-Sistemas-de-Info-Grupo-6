import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'payment_page.dart';
import 'services/reservation_service.dart';
import 'theme/app_theme.dart';

/// Hito 3 - Flujo de Reservas.
/// Interfaz que consume ReservationService.misReservas() y muestra las
/// reservaciones del usuario con su estado actual:
/// Solicitado -> Aceptado -> Pagado -> Disfrutado, cada uno con un color.
class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({Key? key}) : super(key: key);

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  @override
  void initState() {
    super.initState();
    // Control de fechas: al entrar a "Mis Reservas", promueve a "Disfrutado"
    // las reservas pagadas cuya estadía ya terminó. Silencioso si falla.
    ReservationService().promoverReservasVencidas().catchError((_) {});
  }

  /// Color asociado a cada estado del ciclo de vida de la reserva.
  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Aprobado':
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
              final inicio = data['fechaInicio'];
              final fin = data['fechaFin'];
              return _ReservaCard(
                reservaId: docs[i].id,
                alojamiento: (data['alojamiento'] ?? '') as String,
                ubicacion: (data['ubicacion'] ?? '') as String,
                precioPorNoche: precio,
                estado: estado,
                color: _colorEstado(estado),
                fechaInicio: inicio is Timestamp ? inicio.toDate() : null,
                fechaFin: fin is Timestamp ? fin.toDate() : null,
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
  final String reservaId;
  final String alojamiento;
  final String ubicacion;
  final double precioPorNoche;
  final String estado;
  final Color color;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const _ReservaCard({
    required this.reservaId,
    required this.alojamiento,
    required this.ubicacion,
    required this.precioPorNoche,
    required this.estado,
    required this.color,
    this.fechaInicio,
    this.fechaFin,
  });

  /// El pago se habilita solo cuando el administrador aprobó la solicitud.
  bool get _puedePagar => estado == 'Aprobado' || estado == 'Aceptado';

  /// Formatea una fecha como dd/mm/aaaa para mostrarla en la tarjeta.
  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _irAPagar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          reservaId: reservaId,
          nombre: alojamiento,
          ubicacion: ubicacion,
          monto: precioPorNoche,
        ),
      ),
    );
  }

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
                // Fechas de la estadía elegidas al reservar.
                if (fechaInicio != null && fechaFin != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.event_outlined,
                          size: 14, color: AppColors.mutedForeground),
                      const SizedBox(width: 4),
                      Text('${_fmt(fechaInicio!)} → ${_fmt(fechaFin!)}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.mutedForeground)),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${precioPorNoche.round()}/noche',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.emerald700,
                      ),
                    ),
                    if (_puedePagar)
                      ElevatedButton.icon(
                        onPressed: () => _irAPagar(context),
                        icon: const Icon(Icons.payment, size: 16),
                        label: const Text('Pagar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emerald600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          minimumSize: const Size(0, 36),
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
/// La reserva nace "Solicitado", el administrador la pasa a "Aprobado", el
/// viajero la paga ("Pagado") y tras la estadía queda "Disfrutado".
class _ReservasHeader extends StatelessWidget {
  const _ReservasHeader();

  @override
  Widget build(BuildContext context) {
    const pasos = [
      ['Solicitado', AppColors.amber500],
      ['Aprobado', AppColors.blue600],
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
            'Sigue el estado de tus solicitudes y paga las aprobadas',
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
