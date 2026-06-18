import 'package:flutter/material.dart';
import 'models/accommodation.dart';
import 'services/accommodation_repository.dart';
import 'accommodation_details_page.dart';
import 'payment_page.dart';
import 'theme/app_theme.dart';

/// Pantalla de Búsqueda (contenido plano; la barra superior la pone el shell).
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _repository = AccommodationRepository();
  final _searchController = TextEditingController();
  double _maxBudget = 200.0;
  String _query = '';
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _abrirDetalle(Accommodation a) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccommodationDetailsPage(accommodation: a),
      ),
    );
  }

  /// Ya no crea la reserva directamente: abre la pasarela de pago. La reserva
  /// solo se crea (en estado "Pagado") si el pago con PayPal se confirma.
  void _reservar(Accommodation a) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(accommodation: a),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Accommodation>>(
      stream: _repository.watchAll(),
      builder: (context, snapshot) {
        final cargando =
            snapshot.connectionState == ConnectionState.waiting;
        final todos = snapshot.data ?? const <Accommodation>[];
        final results =
            _repository.search(todos, query: _query, maxBudget: _maxBudget);
        return _buildContent(context, results, cargando);
      },
    );
  }

  Widget _buildContent(
      BuildContext context, List<Accommodation> results, bool cargando) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        const Text('Búsqueda de Opciones Económicas',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Encuentra el alojamiento perfecto para tu presupuesto',
            style: TextStyle(color: AppColors.mutedForeground)),
        const SizedBox(height: 20),

        // Barra de búsqueda + botón de filtros.
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _query = val),
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre o ubicación...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => setState(() => _showFilters = !_showFilters),
              icon: const Icon(Icons.tune, size: 18),
              label: const Text('Filtros'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _showFilters
                    ? AppColors.emerald700
                    : AppColors.foreground,
                backgroundColor:
                    _showFilters ? AppColors.emerald50 : Colors.white,
                side: BorderSide(
                    color: _showFilters
                        ? AppColors.emerald300
                        : AppColors.border),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),

        if (_showFilters) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Presupuesto Máximo: \$${_maxBudget.round()}/noche',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.emerald600,
                    thumbColor: AppColors.emerald600,
                    inactiveTrackColor: AppColors.emerald100,
                    overlayColor: AppColors.emerald100,
                  ),
                  child: Slider(
                    value: _maxBudget,
                    min: 10,
                    max: 200,
                    divisions: 19,
                    label: '\$${_maxBudget.round()}',
                    onChanged: (val) => setState(() => _maxBudget = val),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),
        Text(
            cargando
                ? 'Cargando alojamientos...'
                : '${results.length} resultado(s) encontrado(s)',
            style: const TextStyle(
                fontSize: 14, color: AppColors.mutedForeground)),
        const SizedBox(height: 12),

        if (cargando)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (results.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Icon(Icons.search, size: 48, color: AppColors.mutedForeground),
                SizedBox(height: 12),
                Text('No se encontraron resultados',
                    style: TextStyle(
                        fontSize: 16, color: AppColors.mutedForeground)),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth >= 720 ? 2 : 1;
              final cardW = cols == 1
                  ? c.maxWidth
                  : (c.maxWidth - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: results
                    .map((a) => SizedBox(
                          width: cardW,
                          child: _AccommodationCard(
                            accommodation: a,
                            onOpen: () => _abrirDetalle(a),
                            onReserve: () => _reservar(a),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
      ],
    );
  }
}

IconData _transportIcon(String t) {
  switch (t) {
    case 'lancha':
      return Icons.directions_boat;
    case 'tren':
      return Icons.train;
    case 'colectivo':
      return Icons.airport_shuttle;
    default:
      return Icons.directions_bus;
  }
}

/// Tarjeta horizontal de alojamiento (foto izquierda + datos), estilo Figma.
class _AccommodationCard extends StatelessWidget {
  final Accommodation accommodation;
  final VoidCallback onOpen;
  final VoidCallback onReserve;
  const _AccommodationCard({
    required this.accommodation,
    required this.onOpen,
    required this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    final a = accommodation;
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(12)),
                  child: SizedBox(
                    width: 130,
                    // La imagen va dentro de un Stack con Positioned.fill para
                    // que NO aporte altura intrínseca: así IntrinsicHeight mide
                    // solo la columna de texto y la imagen rellena esa altura.
                    // (Pasar height: double.infinity directo al Image rompía la
                    // medición y las tarjetas colapsaban a altura cero.)
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: EcoImage(url: a.imageUrl, height: 160),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(a.name,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.emerald100,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(a.type.toLowerCase(),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.emerald700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.place_outlined,
                                size: 13, color: AppColors.mutedForeground),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text('${a.location}, ${a.region}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.mutedForeground)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          a.description ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: AppColors.mutedForeground),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: a.transport
                              .map((t) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.blue50,
                                      borderRadius:
                                          BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(_transportIcon(t),
                                            size: 12,
                                            color: AppColors.blue600),
                                        const SizedBox(width: 4),
                                        Text(t,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.blue600,
                                                fontWeight:
                                                    FontWeight.w500)),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 10,
                                runSpacing: 4,
                                children: [
                                  RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: '\$${a.pricePerNight.round()}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.emerald700,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '/noche',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.mutedForeground,
                                        ),
                                      ),
                                    ]),
                                  ),
                                  if (a.capacity != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.group_outlined,
                                            size: 13,
                                            color: AppColors.mutedForeground),
                                        const SizedBox(width: 2),
                                        Text('${a.capacity}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors
                                                    .mutedForeground)),
                                      ],
                                    ),
                                  StarRating(rating: a.rating, fontSize: 12),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: onReserve,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.emerald600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                minimumSize: const Size(0, 34),
                                textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Reservar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
