import 'dart:math';

/// MODELO - Representa un token QR de un solo uso para abrir una puerta.
class QrAccessToken {
  final String codigo;
  final String reservaId;
  final DateTime expiraEn;
  bool usado;

  QrAccessToken({
    required this.codigo,
    required this.reservaId,
    required this.expiraEn,
    this.usado = false,
  });

  /// Indica si el token ya venció respecto al instante recibido.
  bool estaVencido(DateTime ahora) => ahora.isAfter(expiraEn);
}

/// PUERTO (Dependency Inversion) - Contrato para integrar el intercomunicador Fanvil.
abstract class FanvilGateway {
  /// Ordena al equipo Fanvil abrir la puerta indicada.
  Future<bool> abrirPuerta(String idDispositivo);
}

/// ADAPTADOR - Implementación real vía API HTTP del Fanvil dentro de la LAN del edificio.
class FanvilHttpGateway implements FanvilGateway {
  final String baseUrl;
  final String apiKey;
  FanvilHttpGateway({required this.baseUrl, required this.apiKey});

  /// Ejecuta la petición HTTP real de apertura sobre el dispositivo Fanvil.
  @override
  Future<bool> abrirPuerta(String idDispositivo) async {
    throw UnimplementedError('Pendiente de credenciales de obra/IP final.');
  }
}

/// SERVICIO - Genera y valida tokens QR de acceso al edificio.
class QrAccessService {
  final FanvilGateway gateway;
  final Map<String, QrAccessToken> _tokens = {};
  final Random _rng;

  QrAccessService({required this.gateway, Random? random})
      : _rng = random ?? Random.secure();

  /// Genera un código QR numérico de 8 dígitos, válido por [validezMinutos].
  QrAccessToken generarToken({required String reservaId, int validezMinutos = 15}) {
    final codigo = List.generate(8, (_) => _rng.nextInt(10)).join();
    final token = QrAccessToken(
      codigo: codigo,
      reservaId: reservaId,
      expiraEn: DateTime.now().add(Duration(minutes: validezMinutos)),
    );
    _tokens[codigo] = token;
    return token;
  }

  /// Verifica que el código exista, no esté vencido y no haya sido usado.
  bool validarToken(String codigoEscaneado, {DateTime? ahora}) {
    final token = _tokens[codigoEscaneado];
    if (token == null) return false;
    if (token.usado) return false;
    if (token.estaVencido(ahora ?? DateTime.now())) return false;
    return true;
  }

  /// Valida el token y, si es correcto, ordena al Fanvil abrir la puerta (un solo uso).
  Future<bool> intentarAbrirPuerta(
    String codigoEscaneado,
    String idDispositivoFanvil, {
    DateTime? ahora,
  }) async {
    if (!validarToken(codigoEscaneado, ahora: ahora)) return false;
    final abierto = await gateway.abrirPuerta(idDispositivoFanvil);
    if (abierto) _tokens[codigoEscaneado]!.usado = true;
    return abierto;
  }
}
