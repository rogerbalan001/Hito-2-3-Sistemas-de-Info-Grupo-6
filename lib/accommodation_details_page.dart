import 'package:flutter/material.dart';
import 'data/mock_data.dart' show Review;
import 'models/accommodation.dart';
import 'services/reservation_service.dart';
import 'services/review_service.dart';
import 'utils/auth_guard.dart';
import 'widgets/reservation_extras_sheet.dart';
import 'main_shell.dart';
import 'theme/app_theme.dart';

class AccommodationDetailsPage extends StatefulWidget {
  final Accommodation accommodation;
  const AccommodationDetailsPage({Key? key, required this.accommodation})
      : super(key: key);

  @override
  State<AccommodationDetailsPage> createState() =>
      _AccommodationDetailsPageState();
}

class _AccommodationDetailsPageState extends State<AccommodationDetailsPage> {
  Accommodation get a => widget.accommodation;
  DateTimeRange? _rangoSeleccionado;

  IconData _iconFor(String type) {
    switch (type) {
      case 'Camping':   return Icons.park;
      case 'Hostal':    return Icons.bed;
      case 'Cabaña':    return Icons.cabin;
      case 'Eco-Lodge': return Icons.forest;
      default:          return Icons.hotel;
    }
  }

  String _descripcion() {
    if (a.description != null && a.description!.trim().isNotEmpty) {
      return a.description!;
    }
    return 'Alojamiento de tipo ${a.type.toLowerCase()} ubicado en '
        '${a.location}. Una opción económica y sostenible, ideal para '
        'viajeros que buscan vivir la experiencia local sin gastar de más.';
  }

  List<String> _reglas() {
    if (a.rules.isNotEmpty) return a.rules;
    return const [
      'Check-in desde las 2:00 PM · Check-out hasta las 11:00 AM',
      'No se permiten fiestas ni eventos',
      'Respetar las áreas comunes y el entorno natural',
      'Mascotas permitidas bajo previo aviso',
    ];
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  int get _noches {
    if (_rangoSeleccionado == null) return 0;
    return _rangoSeleccionado!.end.difference(_rangoSeleccionado!.start).inDays;
  }

  double get _totalEstimado => _noches * a.pricePerNight;

  Future<void> _elegirFechas() async {
    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _rangoSeleccionado,
      helpText: 'Elige las fechas de tu estadía',
      saveText: 'Confirmar',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.emerald600,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (rango != null) setState(() => _rangoSeleccionado = rango);
  }

  Future<void> _reservar() async {
    if (!requireLogin(context, accion: 'reservar')) return;
    if (_rangoSeleccionado == null) {
      await _elegirFechas();
      if (_rangoSeleccionado == null) return;
    }
    if (!mounted) return;
    final extras = await askReservationExtras(context, maxPersonas: a.capacity);
    if (extras == null) return;
    if (!mounted) return;
    try {
      await ReservationService().crearReserva(
        alojamiento: a.name,
        ubicacion: a.location,
        precioPorNoche: a.pricePerNight,
        fechaInicio: _rangoSeleccionado!.start,
        fechaFin: _rangoSeleccionado!.end,
        metodoPago: extras.metodoPago,
        cantidadPersonas: extras.personas,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Solicitud enviada! El administrador la revisará '
              'pronto. La verás en "Mis Reservas".'),
          duration: Duration(seconds: 4),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 3)),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Barra de reserva fija abajo (precio + botón).
      bottomNavigationBar: _BarraReserva(
        precio: a.pricePerNight,
        rango: _rangoSeleccionado,
        noches: _noches,
        total: _totalEstimado,
        onElegirFechas: _elegirFechas,
        onReservar: _reservar,
      ),
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen de fondo que se colapsa al hacer scroll.
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.emerald800,
            iconTheme: const IconThemeData(color: AppColors.emerald700),
            flexibleSpace: FlexibleSpaceBar(
              background: _Galeria(
                fotos: a.allImages,
                fallbackIcon: _iconFor(a.type),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Encabezado ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(a.name,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2)),
                          ),
                          const SizedBox(width: 10),
                          _Badge(a.type),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.place_outlined,
                            size: 15, color: AppColors.mutedForeground),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(a.location,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.mutedForeground)),
                        ),
                      ]),
                      if (a.rating > 0) ...[
                        const SizedBox(height: 6),
                        StarRating(
                            rating: a.rating, reviewCount: a.reviewCount),
                      ],
                    ],
                  ),
                ),

                const _Divider(),

                // ── Estadísticas rápidas (capacidad, hab, camas, baños) ─
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _StatsRow(accommodation: a),
                ),

                const _Divider(),

                // ── Precio por noche ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [
                    Text(
                      '\$${a.pricePerNight.round()}',
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.emerald700),
                    ),
                    const Text(' / noche',
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedForeground)),
                  ]),
                ),

                const _Divider(),

                // ── Selector de fechas visual ───────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _FechasSelector(
                    rango: _rangoSeleccionado,
                    noches: _noches,
                    total: _totalEstimado,
                    precio: a.pricePerNight,
                    onTap: _elegirFechas,
                  ),
                ),

                const _Divider(),

                // ── Descripción ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle('Sobre este lugar'),
                      const SizedBox(height: 8),
                      Text(_descripcion(),
                          style: const TextStyle(
                              fontSize: 14,
                              height: 1.7,
                              color: AppColors.foreground)),
                    ],
                  ),
                ),

                // ── Amenidades ──────────────────────────────────────────
                if (a.amenities.isNotEmpty) ...[
                  const _Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('Lo que ofrece este lugar'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: a.amenities
                              .map((am) => _AmenityChip(am))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Reglas ──────────────────────────────────────────────
                const _Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle('Reglas del lugar'),
                      const SizedBox(height: 10),
                      ..._reglas().map((r) => _ReglaItem(r)),
                    ],
                  ),
                ),

                // ── Reseñas ─────────────────────────────────────────────
                const _Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  child: const _SectionTitle('Reseñas de este lugar'),
                ),
                StreamBuilder<List<Review>>(
                  stream: ReviewService().watchAll(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final propias = (snap.data ?? [])
                        .where((r) => r.accommodationName == a.name)
                        .toList();
                    if (propias.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Text(
                          'Aún no hay reseñas para este lugar. '
                          '¡Sé el primero en opinar!',
                          style: TextStyle(color: AppColors.mutedForeground),
                        ),
                      );
                    }
                    // Promedio de esta propiedad.
                    final avg = propias
                            .map((r) => r.rating)
                            .reduce((a, b) => a + b) /
                        propias.length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                          child: Row(children: [
                            const Icon(Icons.star,
                                size: 18, color: AppColors.amber500),
                            const SizedBox(width: 4),
                            Text(avg.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                            const SizedBox(width: 6),
                            Text('(${propias.length} reseñas)',
                                style: const TextStyle(
                                    color: AppColors.mutedForeground,
                                    fontSize: 13)),
                          ]),
                        ),
                        ...propias.map(
                            (r) => Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      20, 0, 20, 12),
                                  child: _ReviewCard(review: r),
                                )),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 100), // espacio para la barra inferior
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets internos ────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Divider(height: 1, color: AppColors.border),
      );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700));
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge(this.label);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.emerald100,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.emerald700)),
      );
}

/// Fila de estadísticas rápidas (capacidad, habitaciones, camas, baños).
class _StatsRow extends StatelessWidget {
  final Accommodation accommodation;
  const _StatsRow({required this.accommodation});

  @override
  Widget build(BuildContext context) {
    final a = accommodation;
    final items = <_StatItem>[
      if (a.capacity != null)
        _StatItem(Icons.group_outlined, '${a.capacity}', 'huéspedes'),
      if (a.bedrooms != null)
        _StatItem(Icons.bed_outlined, '${a.bedrooms}', 'habitaciones'),
      if (a.beds != null)
        _StatItem(Icons.king_bed_outlined, '${a.beds}', 'camas'),
      if (a.bathrooms != null)
        _StatItem(Icons.bathtub_outlined, '${a.bathrooms}', 'baños'),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return Row(
      children: items
          .map((s) => Expanded(
                child: Column(
                  children: [
                    Icon(s.icon, size: 26, color: AppColors.emerald600),
                    const SizedBox(height: 4),
                    Text(s.value,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    Text(s.label,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.mutedForeground)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String value;
  final String label;
  const _StatItem(this.icon, this.value, this.label);
}

/// Sección visual de selección de fechas, estilo Airbnb.
class _FechasSelector extends StatelessWidget {
  final DateTimeRange? rango;
  final int noches;
  final double total;
  final double precio;
  final VoidCallback onTap;
  const _FechasSelector({
    required this.rango,
    required this.noches,
    required this.total,
    required this.precio,
    required this.onTap,
  });

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Fechas de tu estadía'),
        const SizedBox(height: 12),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: rango != null
                    ? AppColors.emerald500
                    : AppColors.border,
                width: rango != null ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Llegada',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedForeground)),
                    const SizedBox(height: 2),
                    Text(
                      rango != null ? _fmt(rango!.start) : 'Añadir fecha',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: rango != null
                              ? AppColors.foreground
                              : AppColors.mutedForeground),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.arrow_forward,
                      size: 16, color: AppColors.mutedForeground),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Salida',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedForeground)),
                    const SizedBox(height: 2),
                    Text(
                      rango != null ? _fmt(rango!.end) : 'Añadir fecha',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: rango != null
                              ? AppColors.foreground
                              : AppColors.mutedForeground),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.calendar_month_outlined,
                    color: AppColors.emerald600),
              ],
            ),
          ),
        ),
        if (rango != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.emerald50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 18, color: AppColors.emerald700),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '\$${precio.round()} × $noches ${noches == 1 ? 'noche' : 'noches'}',
                  style: const TextStyle(color: AppColors.emerald700),
                ),
              ),
              Text(
                '\$${total.round()} total',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.emerald700),
              ),
            ]),
          ),
        ],
      ],
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String label;
  const _AmenityChip(this.label);

  static const _iconos = {
    'Wifi': Icons.wifi,
    'Aire acondicionado': Icons.ac_unit,
    'Agua caliente': Icons.hot_tub_outlined,
    'Cocina equipada': Icons.kitchen_outlined,
    'Estacionamiento': Icons.local_parking,
    'Piscina': Icons.pool,
    'Lavadora': Icons.local_laundry_service_outlined,
    'TV': Icons.tv_outlined,
    'Desayuno incluido': Icons.free_breakfast_outlined,
    'Se permiten mascotas': Icons.pets_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _iconos[label] ?? Icons.check_circle_outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: AppColors.emerald600),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _ReglaItem extends StatelessWidget {
  final String regla;
  const _ReglaItem(this.regla);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_outline,
                size: 16, color: AppColors.emerald600),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(regla,
                  style: const TextStyle(fontSize: 14, height: 1.5))),
        ]),
      );
}

/// Barra fija en la parte inferior con precio, resumen de fechas y botón
/// de reserva. Desaparece si el scroll llega al final.
class _BarraReserva extends StatelessWidget {
  final double precio;
  final DateTimeRange? rango;
  final int noches;
  final double total;
  final VoidCallback onElegirFechas;
  final VoidCallback onReservar;

  const _BarraReserva({
    required this.precio,
    required this.rango,
    required this.noches,
    required this.total,
    required this.onElegirFechas,
    required this.onReservar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: AppColors.foreground),
                  children: [
                    TextSpan(
                      text: '\$${precio.round()}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const TextSpan(
                      text: ' / noche',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              ),
              if (rango != null)
                Text('\$${total.round()} total ($noches noches)',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.emerald700,
                        fontWeight: FontWeight.w600))
              else
                GestureDetector(
                  onTap: onElegirFechas,
                  child: const Text('Seleccionar fechas',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.emerald600,
                          decoration: TextDecoration.underline)),
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: onReservar,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28),
            ),
            child: const Text('Reservar',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}

/// Galería de fotos deslizable.
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
        height: 260,
        fallbackIcon: widget.fallbackIcon,
      );
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.fotos.length,
            onPageChanged: (i) => setState(() => _pagina = i),
            itemBuilder: (_, i) => EcoImage(
              url: widget.fotos[i],
              height: 260,
              fallbackIcon: widget.fallbackIcon,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.fotos.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _pagina ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: i == _pagina
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        ),
        // Contador de fotos arriba a la derecha.
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${_pagina + 1}/${widget.fotos.length}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tarjeta de reseña.
class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.emerald100,
              child: Text(review.avatar,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emerald700)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.userName,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(review.date,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.mutedForeground)),
                ],
              ),
            ),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < review.rating ? Icons.star : Icons.star_border,
                  size: 14,
                  color: AppColors.amber500,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Text(review.comment,
              style: const TextStyle(fontSize: 14, height: 1.6)),
          if (review.priceAccuracy) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.emerald50,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.emerald200),
              ),
              child: const Text('✓ Precio verificado por la comunidad',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.emerald700,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ],
      ),
    );
  }
}
