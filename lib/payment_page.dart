/// Fachada de la pasarela de pago (selección por plataforma en compilación).
///
/// El pago real usa el SDK de JavaScript de PayPal, que solo existe en la WEB
/// (`dart:ui_web`, `package:web`, `dart:js_interop`). En Android/iOS esas
/// librerías no existen y el código no compilaría.
///
/// Por eso se usa una IMPORTACIÓN CONDICIONAL:
///   - En web  → [payment_page_web.dart]   (botones reales de PayPal Sandbox).
///   - En móvil → [payment_page_stub.dart]  (confirmación de pago nativa).
///
/// Ambos archivos exponen la misma clase `PaymentPage` con idéntico
/// constructor, así que el resto de la app (p. ej. "Mis Reservas") no cambia.
export 'payment_page_stub.dart'
    if (dart.library.html) 'payment_page_web.dart';
