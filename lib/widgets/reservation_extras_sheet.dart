import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Datos adicionales que se piden al confirmar una reserva: método de pago y
/// cantidad de personas. Se completan en una hoja modal después de elegir
/// las fechas de la estadía y antes de crear la solicitud de reserva.
class ReservationExtras {
  final String metodoPago;
  final int personas;
  const ReservationExtras({required this.metodoPago, required this.personas});
}

const _metodosPago = [
  'Pago móvil',
  'Transferencia bancaria',
  'Zelle',
  'Efectivo',
  'Tarjeta (en el alojamiento)',
];

/// Abre una hoja modal pidiendo método de pago y cantidad de personas.
/// Devuelve `null` si el usuario cierra la hoja sin confirmar.
/// [maxPersonas] limita el contador a la capacidad del alojamiento/paquete,
/// si se conoce.
Future<ReservationExtras?> askReservationExtras(
  BuildContext context, {
  int? maxPersonas,
}) {
  return showModalBottomSheet<ReservationExtras>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _ReservationExtrasForm(maxPersonas: maxPersonas),
  );
}

class _ReservationExtrasForm extends StatefulWidget {
  final int? maxPersonas;
  const _ReservationExtrasForm({this.maxPersonas});

  @override
  State<_ReservationExtrasForm> createState() =>
      _ReservationExtrasFormState();
}

class _ReservationExtrasFormState extends State<_ReservationExtrasForm> {
  String _metodoPago = _metodosPago.first;
  int _personas = 1;

  @override
  Widget build(BuildContext context) {
    final tope = widget.maxPersonas ?? 10;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Un último paso',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text(
            'Completa estos datos para confirmar tu solicitud.',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 20),

          const Text('Método de pago',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _metodoPago,
                isExpanded: true,
                items: _metodosPago
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _metodoPago = v ?? _metodoPago),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text('Cantidad de personas',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed:
                    _personas > 1 ? () => setState(() => _personas--) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$_personas',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              IconButton(
                onPressed: _personas < tope
                    ? () => setState(() => _personas++)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
              const SizedBox(width: 8),
              if (widget.maxPersonas != null)
                Text('Máx. $tope',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.mutedForeground)),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(
                context,
                ReservationExtras(
                    metodoPago: _metodoPago, personas: _personas),
              ),
              child: const Text('Confirmar solicitud'),
            ),
          ),
        ],
      ),
    );
  }
}
