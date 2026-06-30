import 'package:flutter/material.dart';
import 'models/accommodation.dart';
import 'services/reservation_service.dart';
import 'utils/auth_guard.dart';
import 'widgets/reservation_extras_sheet.dart';
import 'main_shell.dart';
import 'theme/app_theme.dart';

/// CU-02: Consultar detalle de servicio.
/// Se abre con Navigator.push desde la lista de búsqueda, recibiendo el
/// [Accommodation] por constructor. Muestra foto, rating, amenidades,
/// descripción, reglas y el botón definitivo de "Reservar" (RF04).
class AccommodationDetailsPage extends StatelessWidget {
  final Accommodation accommodation;
  const AccommodationDetailsPage({Key? key, required this.accommodation})
      : super(key: key);

  IconData _iconFor(String type) {
    switch (type) {
      case 'Camping':
        return Icons.park;
      case 'Hostal':
        return Icons.bed;
      case 'Cabaña':
        return Icons.cabin;
      case 'Eco-Lodge':
        return Icons.forest;
      default:
        return Icons.hotel;
    }
  }

  String _descripcion() {
    if (accommodation.description != null &&
        accommodation.description!.trim().isNotEmpty) {
      return accommodation.description!;
    }
    return 'Alojamiento de tipo ${accommodation.type.toLowerCase()} ubicado en '
        '${accommodation.location}. Una opción económica y sostenible, ideal '
        'para viajeros que buscan vivir la experiencia local sin gastar de más.';
  }

  List<String> _reglas() {
    if (accommodation.rules.isNotEmpty) return accommodation.rules;
    return const [
      'Check-in desde las 2:00 PM · Check-out hasta las 11:00 AM',
      'No se permiten fiestas ni eventos',
      'Respetar las áreas comunes y el entorno natural',
      'Mascotas permitidas bajo previo aviso',
    ];
  }

  /// Crea la reserva en estado "Solicitado". El pago se habilita después,
  /// cuando el administrador apruebe la solicitud (desde "Mis Reservas").
  Future<void> _reservar(BuildContext context) async {
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

    // Datos adicionales: método de pago y cantidad de personas.
    final extras = await askReservationExtras(
      context,
      maxPersonas: accommodation.capacity,
    );
    if (extras == null) return;
    if (!context.mounted) return;

    try {
      await ReservationService().crearReserva(
        alojamiento: accommodation.name,
        ubicacion: accommodation.location,
        precioPorNoche: accommodation.pricePerNight,
        fechaInicio: rango.start,
        fechaFin: rango.end,
        metodoPago: extras.metodoPago,
        cantidadPersonas: extras.personas,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud enviada. Cuando el administrador la '
              'apruebe podrás pagarla desde "Mis Reservas".'),
        ),
      );
      // Lleva directo a "Mis Reservas" (pestaña 3) reiniciando la pila de
      // navegación, sin importar desde dónde se llegó a esta pantalla.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 3)),
        (route) => false,
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
    final a = accommodation;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detalle del alojamiento')),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Galería de fotos: si hay más de una, se desliza horizontalmente
          // con puntos indicadores; con una sola (o ninguna) se ve igual que
          // antes.
          _Galeria(fotos: a.allImages, fallbackIcon: _iconFor(a.type)),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        a.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.emerald100,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        a.type,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.emerald700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 16, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text(a.location,
                        style: const TextStyle(
                            color: AppColors.mutedForeground)),
                    const SizedBox(width: 12),
                    if (a.rating > 0)
                      StarRating(rating: a.rating, reviewCount: a.reviewCount),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.attach_money,
                      label: '\$${a.pricePerNight.round()}/noche',
                      color: AppColors.emerald700,
                    ),
                    const SizedBox(width: 10),
                    if (a.capacity != null)
                      _InfoChip(
                        icon: Icons.group_outlined,
                        label: 'Hasta ${a.capacity} personas',
                        color: AppColors.blue600,
                      ),
                  ],
                ),
                if (a.bedrooms != null || a.bathrooms != null || a.beds != null) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (a.bedrooms != null)
                        _InfoChip(
                          icon: Icons.bed_outlined,
                          label: '${a.bedrooms} habitaciones',
                          color: AppColors.purple600,
                        ),
                      if (a.beds != null)
                        _InfoChip(
                          icon: Icons.king_bed_outlined,
                          label: '${a.beds} camas',
                          color: AppColors.purple600,
                        ),
                      if (a.bathrooms != null)
                        _InfoChip(
                          icon: Icons.bathtub_outlined,
                          label: '${a.bathrooms} baños',
                          color: AppColors.purple600,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),

                const _SectionTitle('Descripción'),
                const SizedBox(height: 6),
                Text(
                  _descripcion(),
                  style: const TextStyle(
                      fontSize: 14, height: 1.5, color: AppColors.foreground),
                ),

                if (a.amenities.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const _SectionTitle('Amenidades'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: a.amenities
                        .map((am) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.emerald50,
                                borderRadius: BorderRadius.circular(999),
                                border:
                                    Border.all(color: AppColors.emerald100),
                              ),
                              child: Text(
                                am,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.emerald700,
                                    fontWeight: FontWeight.w500),
                              ),
                            ))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 24),
                const _SectionTitle('Reglas del lugar'),
                const SizedBox(height: 8),
                ..._reglas().map(
                  (regla) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 18, color: AppColors.emerald600),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(regla,
                              style: const TextStyle(
                                  fontSize: 14, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _reservar(context),
                    icon: const Icon(Icons.event_available, size: 20),
                    label: const Text('Reservar ahora'),
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700));
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: color, fontSize: 13)),
        ],
      ),
    );
  }
}

/// Galería de fotos del alojamiento: un [PageView] deslizable con puntos
/// indicadores cuando hay más de una foto. Con una sola foto (o ninguna) se
/// comporta igual que la imagen de cabecera anterior.
class _Galeria extends StatefulWidget {
  final List<String> fotos;
  final IconData fallbackIcon;
  const _Galeria({required this.fotos, required this.fallbackIcon});

  @override
  State<_Galeria> createState() => _GaleriaState();
}

class _GaleriaState extends State<_Galeria> {
  final _controller = PageController();
  int _pagina = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fotos.length <= 1) {
      return EcoImage(
        url: widget.fotos.isEmpty ? null : widget.fotos.first,
        height: 230,
        fallbackIcon: widget.fallbackIcon,
      );
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.fotos.length,
            onPageChanged: (i) => setState(() => _pagina = i),
            itemBuilder: (context, i) => EcoImage(
              url: widget.fotos[i],
              height: 230,
              fallbackIcon: widget.fallbackIcon,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.fotos.length; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _pagina ? 8 : 6,
                  height: i == _pagina ? 8 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _pagina
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
