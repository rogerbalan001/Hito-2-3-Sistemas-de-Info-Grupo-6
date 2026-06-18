import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;

/// Carga del SDK de JavaScript de PayPal (modo SANDBOX, pagos de prueba).
///
/// Usa la interoperabilidad MODERNA y soportada de Dart para la Web
/// (dart:js_interop + dart:js_interop_unsafe + package:web). Las librerías
/// antiguas dart:html y dart:js están obsoletas (y no compilan con
/// dart2wasm), por eso aquí se evitan por completo.
class PaypalService {
  PaypalService._();

  /// Client ID de la app de SANDBOX en developer.paypal.com (Apps & Credentials).
  /// Es información pública (no es el "secret"): solo identifica la cuenta de
  /// pruebas que recibe los pagos simulados, por eso es seguro tenerlo aquí.
  static const String sandboxClientId =
      'BAAr64mHuIr6NWDHTN-X01caW8CgEpfEj-147XX1stn18t4Okmtci_x-8VERMV-EywdxLDmSLIVwGiQ7kE';

  static Future<void>? _cargaEnCurso;

  /// Inserta el <script> del SDK en <head> si aún no está presente, y
  /// resuelve cuando el objeto global `paypal` queda disponible. Si ya se
  /// había cargado antes, no lo vuelve a insertar.
  static Future<void> ensureLoaded() {
    if (globalContext.hasProperty('paypal'.toJS).toDart) {
      return Future.value();
    }
    return _cargaEnCurso ??= _cargar();
  }

  static Future<void> _cargar() {
    final completer = Completer<void>();

    final script =
        web.document.createElement('script') as web.HTMLScriptElement;
    script.type = 'text/javascript';
    script.src = 'https://www.paypal.com/sdk/js'
        '?client-id=$sandboxClientId'
        '&currency=USD'
        '&intent=capture'
        '&components=buttons';

    script.addEventListener(
      'load',
      ((web.Event _) => completer.complete()).toJS,
    );
    script.addEventListener(
      'error',
      ((web.Event _) => completer.completeError(
            'No se pudo cargar el SDK de PayPal (revisa tu conexión).',
          )).toJS,
    );

    web.document.head!.appendChild(script);
    return completer.future;
  }
}
