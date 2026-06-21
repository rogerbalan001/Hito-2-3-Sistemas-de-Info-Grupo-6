import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'services/paypal_service.dart';
import 'services/reservation_service.dart';
import 'theme/app_theme.dart';

/// Pasarela de pago (Hito 3 - Flujo de pago con PayPal Sandbox).
///
/// Reemplaza el flujo anterior, en el que la reserva se creaba directo en
/// estado "Solicitado" y quedaba a la espera de que alguien la "aprobara".
/// Ahora el viajero paga de una vez con el botón de PayPal (modo sandbox,
/// pagos de prueba) y, solo si el pago se confirma, la reserva se crea
/// directamente en estado "Pagado": ya no existe el paso de aprobación.
///
/// Es genérica (recibe nombre/ubicación/monto, no un [Accommodation]) para
/// poder reutilizarse tanto al reservar un alojamiento como un paquete
/// turístico.
///
/// NOTA TÉCNICA: la interoperabilidad con el SDK de JavaScript de PayPal usa
/// dart:js_interop + dart:js_interop_unsafe (la API moderna y soportada),
/// en vez de dart:js/dart:html (obsoletas).
class PaymentPage extends StatefulWidget {
  /// Nombre del alojamiento o paquete que se está pagando.
  final String nombre;
  /// Ubicación/destino a mostrar en el resumen.
  final String ubicacion;
  /// Monto total a cobrar (en USD).
  final double monto;

  const PaymentPage({
    Key? key,
    required this.nombre,
    required this.ubicacion,
    required this.monto,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // Id único para el <div> donde PayPal va a "montar" sus botones. Tiene que
  // ser distinto cada vez que se abre esta pantalla.
  late final String _viewId =
      'paypal-button-container-${DateTime.now().microsecondsSinceEpoch}';

  bool _sdkListo = false;
  bool _procesando = false;
  bool _pagoConfirmado = false;
  String? _error;

  // Alto del contenedor de los botones de PayPal. Arranca chico (solo caben
  // los botones), pero cuando el usuario elige "Tarjeta de débito o crédito",
  // PayPal expande un formulario alto DENTRO del mismo <div>. Si el alto se
  // queda fijo, ese formulario se desborda por debajo y los campos no se ven.
  // Por eso se vigila el alto real del contenido y se ajusta el contenedor.
  static const double _altoMinimo = 50;
  double _altoContenedor = _altoMinimo;
  Timer? _vigilanteAlto;

  @override
  void initState() {
    super.initState();
    _registrarVistaHtml();
    _cargarSdk();
  }

  @override
  void dispose() {
    _vigilanteAlto?.cancel();
    super.dispose();
  }

  /// Vigila el alto real del contenido del <div> de PayPal y ajusta el
  /// contenedor de Flutter para que el formulario de tarjeta quepa completo
  /// (y se contraiga de nuevo al cerrarlo). `scrollHeight` reporta el alto
  /// total del contenido aunque visualmente esté recortado.
  void _vigilarAlto() {
    _vigilanteAlto?.cancel();
    _vigilanteAlto =
        Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;
      final el = web.document.getElementById(_viewId);
      if (el == null) return;
      final alto = el.scrollHeight.toDouble();
      final objetivo = alto < _altoMinimo ? _altoMinimo : alto;
      if ((objetivo - _altoContenedor).abs() > 1) {
        setState(() => _altoContenedor = objetivo);
      }
    });
  }

  /// Registra la fábrica que crea el <div> real del DOM donde se va a montar
  /// el botón de PayPal. Debe ocurrir antes de construir el HtmlElementView.
  void _registrarVistaHtml() {
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final div = web.document.createElement('div') as web.HTMLDivElement;
      div.id = _viewId;
      div.style.width = '100%';
      return div;
    });
  }

  Future<void> _cargarSdk() async {
    try {
      await PaypalService.ensureLoaded();
      if (!mounted) return;
      setState(() => _sdkListo = true);
      // El <div> recién se inserta en el DOM real después de este frame, y
      // en Flutter Web esa inserción puede tardar más de un frame. Por eso,
      // en vez de confiar en un solo postFrameCallback, se espera de forma
      // activa hasta confirmar que el elemento ya existe en el documento.
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _esperarElementoYMontar());
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo cargar PayPal: $e');
    }
  }

  /// Espera (con reintentos cortos) a que el <div> del botón exista de
  /// verdad en el documento antes de pedirle a PayPal que renderice ahí.
  /// Sin esto, PayPal puede fallar con "element does not exist" si se
  /// adelanta a la inserción real del nodo en el DOM.
  Future<void> _esperarElementoYMontar() async {
    const intentosMax = 50; // ~5 segundos en total
    for (var intento = 0; intento < intentosMax; intento++) {
      if (!mounted) return;
      if (web.document.getElementById(_viewId) != null) {
        _montarBotones();
        _vigilarAlto();
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (!mounted) return;
    setState(() => _error =
        'No se pudo preparar el botón de pago (tiempo de espera agotado). '
        'Intenta de nuevo.');
  }

  /// Convierte un Map de Dart en un objeto JS real pasando por JSON. Evita
  /// tener que construir el objeto propiedad por propiedad a mano.
  JSAny _aObjetoJs(Map<String, dynamic> data) {
    final texto = jsonEncode(data);
    final json = globalContext.getProperty<JSObject>('JSON'.toJS);
    return json.callMethod<JSAny>('parse'.toJS, texto.toJS);
  }

  void _montarBotones() {
    if (!globalContext.hasProperty('paypal'.toJS).toDart) {
      setState(() => _error = 'El SDK de PayPal no está disponible.');
      return;
    }
    final paypal = globalContext.getProperty<JSObject>('paypal'.toJS);

    final estilo = _aObjetoJs(const {
      'layout': 'vertical',
      'color': 'gold',
      'shape': 'rect',
      'label': 'paypal',
    });

    final configuracion = JSObject()
      ..setProperty('style'.toJS, estilo)
      ..setProperty('createOrder'.toJS, _crearOrden.toJS)
      ..setProperty('onApprove'.toJS, _alAprobarPago.toJS)
      ..setProperty('onError'.toJS, _alFallarPago.toJS)
      ..setProperty('onCancel'.toJS, _alCancelarPago.toJS);

    final boton =
        paypal.callMethod<JSObject>('Buttons'.toJS, configuracion);
    boton.callMethod<JSAny?>('render'.toJS, '#$_viewId'.toJS);
  }

  /// createOrder: se llama cuando el usuario toca el botón. Crea la orden en
  /// PayPal con el monto a cobrar. Devolver la promesa basta; el SDK espera
  /// por ella sola.
  JSAny? _crearOrden(JSAny? data, JSAny? actions) {
    final order = (actions as JSObject).getProperty<JSObject>('order'.toJS);
    final payload = _aObjetoJs({
      'purchase_units': [
        {
          'description': 'EcoSpot - ${widget.nombre}',
          'amount': {
            'currency_code': 'USD',
            'value': widget.monto.toStringAsFixed(2),
          },
        },
      ],
    });
    return order.callMethod<JSAny?>('create'.toJS, payload);
  }

  /// onApprove: se llama cuando el comprador aprueba el pago en la ventana
  /// de PayPal. Captura la orden (efectúa el cobro de prueba) y, si sale
  /// bien, recién ahí se crea la reserva.
  JSAny? _alAprobarPago(JSAny? data, JSAny? actions) {
    setState(() => _procesando = true);
    final order = (actions as JSObject).getProperty<JSObject>('order'.toJS);
    final captura = order.callMethod<JSPromise>('capture'.toJS);
    captura.toDart.then((JSAny? detalles) {
      _onPagoExitoso(detalles as JSObject?);
    }).catchError((Object err) {
      _onPagoFallido(err.toString());
    });
    return captura;
  }

  void _alFallarPago(JSAny? err) {
    _onPagoFallido(err?.toString() ?? 'Error desconocido');
  }

  void _alCancelarPago(JSAny? data) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pago cancelado')),
    );
  }

  Future<void> _onPagoExitoso(JSObject? detalles) async {
    String? orderId;
    String? estadoPaypal;
    if (detalles != null) {
      try {
        orderId = detalles.getProperty<JSString?>('id'.toJS)?.toDart;
        estadoPaypal = detalles.getProperty<JSString?>('status'.toJS)?.toDart;
      } catch (_) {
        // Si por algún motivo no se puede leer el detalle, igual se registra
        // el pago: PayPal ya confirmó la captura en su propio flujo.
      }
    }

    try {
      // RF04 actualizado: la reserva nace directamente en "Pagado", sin
      // pasar por una aprobación manual previa.
      await ReservationService().crearReserva(
        alojamiento: widget.nombre,
        ubicacion: widget.ubicacion,
        precioPorNoche: widget.monto,
        estado: 'Pagado',
        metodoPago: 'PayPal (Sandbox)',
        referenciaPago: orderId,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _procesando = false;
        _error = 'El pago se confirmó, pero no se pudo guardar la reserva: $e';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _procesando = false;
      _pagoConfirmado = true;
    });

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.emerald600),
            SizedBox(width: 10),
            Text('Pago confirmado'),
          ],
        ),
        content: Text(
          'Tu reserva de "${widget.nombre}" quedó confirmada '
          'y pagada.\n'
          '${estadoPaypal != null ? 'Estado de PayPal: $estadoPaypal\n' : ''}'
          '${orderId != null ? 'N.º de orden: $orderId' : ''}',
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
  }

  void _onPagoFallido(String mensaje) {
    if (!mounted) return;
    setState(() {
      _procesando = false;
      _error = 'No se pudo completar el pago: $mensaje';
    });
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
            'Pago de prueba (PayPal Sandbox): no se cobra dinero real. Usa una '
            'cuenta de comprador de sandbox para completar el pago.',
            style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 24),

          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_error!,
                  style:
                      const TextStyle(color: AppColors.red600, fontSize: 13)),
            ),
            const SizedBox(height: 16),
          ],

          if (_pagoConfirmado)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle,
                        color: AppColors.emerald600, size: 40),
                    SizedBox(height: 8),
                    Text('Reserva pagada y confirmada'),
                  ],
                ),
              ),
            )
          else if (!_sdkListo)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            // Alto dinámico: crece cuando PayPal expande el formulario de
            // tarjeta (ver [_vigilarAlto]) y se contrae al cerrarlo, para que
            // los campos nunca queden recortados fuera de la pantalla.
            SizedBox(
              height: _altoContenedor,
              child: HtmlElementView(viewType: _viewId),
            ),

          if (_procesando) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 8),
            const Center(
              child: Text('Confirmando el pago...',
                  style: TextStyle(color: AppColors.mutedForeground)),
            ),
          ],
        ],
      ),
    );
  }
}
