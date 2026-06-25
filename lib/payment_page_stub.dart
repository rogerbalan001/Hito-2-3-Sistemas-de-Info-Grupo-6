import 'package:flutter/material.dart';

import 'services/reservation_service.dart';
import 'theme/app_theme.dart';

/// Pasarela de pago — implementación para MÓVIL/escritorio.
///
/// El SDK de JavaScript de PayPal solo existe en la web; aquí (Android/iOS) se
/// confirma el pago de forma nativa (modo demostración) para que el flujo de
/// reservas funcione igual en el APK. La selección entre esta versión y la web
/// la hace [payment_page.dart] por importación condicional.
class PaymentPage extends StatefulWidget {
  /// Id de la reserva (ya aprobada) que se está pagando. Si es null, se crea
  /// una reserva nueva en estado "Pagado".
  final String? reservaId;
  final String nombre;
  final String ubicacion;
  final double monto;

  const PaymentPage({
    Key? key,
    this.reservaId,
    required this.nombre,
    required this.ubicacion,
    required this.monto,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _procesando = false;

  Future<void> _confirmarPago() async {
    setState(() => _procesando = true);
    try {
      // Pago simulado en la app móvil (no hay SDK de PayPal en Android).
      await Future.delayed(const Duration(milliseconds: 600));
      if (widget.reservaId != null) {
        await ReservationService().registrarPago(
          widget.reservaId!,
          metodoPago: 'Tarjeta (app, demostración)',
        );
      } else {
        await ReservationService().crearReserva(
          alojamiento: widget.nombre,
          ubicacion: widget.ubicacion,
          precioPorNoche: widget.monto,
          estado: 'Pagado',
          metodoPago: 'Tarjeta (app, demostración)',
        );
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.emerald600),
              SizedBox(width: 10),
              Text('Pago confirmado'),
            ],
          ),
          content: Text(
            'Tu reserva de "${widget.nombre}" quedó confirmada y pagada.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo procesar el pago: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pago de la reserva')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Resumen del alojamiento/paquete y el monto a pagar.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.nombre,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 16, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text(widget.ubicacion,
                        style:
                            const TextStyle(color: AppColors.mutedForeground)),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total a pagar',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      '\$${widget.monto.toStringAsFixed(2)} USD',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.emerald700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Pago de demostración en la aplicación móvil. En la versión web el '
            'pago se realiza con PayPal (Sandbox).',
            style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _procesando ? null : _confirmarPago,
              icon: _procesando
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.payment),
              label: Text(_procesando ? 'Procesando...' : 'Confirmar pago'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald600,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
