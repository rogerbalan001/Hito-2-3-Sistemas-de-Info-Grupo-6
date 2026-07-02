import 'package:flutter/material.dart';
import 'models/accommodation.dart';
import 'services/accommodation_repository.dart';
import 'services/reservation_service.dart';
import 'utils/auth_guard.dart';
import 'widgets/reservation_extras_sheet.dart';
import 'widgets/shimmer.dart';
import 'widgets/eco_card.dart';
import 'accommodation_details_page.dart';
import 'main_shell.dart';
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
  bool _isGrid = false; // Mejora 6 — toggle grid/lista

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

  /// Crea la reserva en estado "Solicitado". El pago se habilita después,
  /// cuando el administrador apruebe la solicitud (desde "Mis Reservas").
  Future<void> _reservar(Accommodation a) async {
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
    if (!mounted) return;

    // Datos adicionales: método de pago y cantidad de personas.
    final extras = await askReservationExtras(context, maxPersonas: a.capacity);
    if (extras == null) return;
    if (!mounted) return;

    try {
      await ReservationService().crearReserva(
        alojamiento: a.name,
        ubicacion: a.location,
        precioPorNoche: a.pricePerNight,
        fechaInicio: rango.start,
        fechaFin: rango.end,
        metodoPago: extras.metodoPago,
        cantidadPersonas: extras.personas,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud enviada. Cuando el administrador la '
              'apruebe podrás pagarla desde "Mis Reservas".'),
        ),
      );
      // Lleva directo a "Mis Reservas" (pestaña 3), sin importar que esta
      // pantalla sea en sí una pestaña del shell.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 3)),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar la solicitud: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Accommodation>>(
      stream: _repository.watchAll(),
      builder: (context, snapshot) {
        final cargando =
            snapshot.connectionState == ConnectionState.waiting;
        final errorMessage = snapshot.hasError ? '${snapshot.error}' : null;
        final todos = snapshot.data ?? const <Accommodation>[];
        final results =
            _repository.search(todos, query: _query, maxBudget: _maxBudget);
        return _buildContent(context, results, cargando, errorMessage);
      },
    );
  }

  Widget _buildContent(BuildContext context, List<Accommodation> results,
      bool cargando, String? errorMessage) {
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
        // Contador + toggle grid/lista
        Row(
          children: [
            Expanded(
              child: Text(
                  cargando
                      ? 'Cargando alojamientos...'
                      : '${results.length} resultado(s) encontrado(s)',
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.mutedForeground)),
            ),
            // Mejora 6 — Toggle vista grid / lista
            if (!cargando && results.isNotEmpty)
              Row(children: [
                _ViewToggle(
                  icon: Icons.grid_view_rounded,
                  active: _isGrid,
                  onTap: () => setState(() => _isGrid = true),
                ),
                const SizedBox(width: 4),
                _ViewToggle(
                  icon: Icons.view_list_rounded,
                  active: !_isGrid,
                  onTap: () => setState(() => _isGrid = false),
                ),
              ]),
          ],
        ),
        const SizedBox(height: 12),

        // Mejora 4 — Shimmer en lugar del spinner
        if (cargando)
          ShimmerList(count: 4, grid: false)
        else if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.mutedForeground),
                const SizedBox(height: 12),
                Text('No se pudieron cargar los alojamientos: $errorMessage',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.mutedForeground)),
              ],
            ),
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
        // Mejora 6 — Diseño responsivo: grid en pantallas anchas o modo grid
        else if (_isGrid)
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth >= 600 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: results.length,
              itemBuilder: (_, i) => EcoAccommodationCard(
                accommodation: results[i],
                onTap: () => _abrirDetalle(results[i]),
                onReserve: () => _reservar(results[i]),
                style: EcoCardStyle.grid,
              ),
            );
          })
        else
          Column(
            children: results
                .map((a) => EcoAccommodationCard(
                      accommodation: a,
                      onTap: () => _abrirDetalle(a),
                      onReserve: () => _reservar(a),
                      style: EcoCardStyle.list,
                    ))
                .toList(),
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

/// Botón de toggle para cambiar entre vista lista y grid.
class _ViewToggle extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ViewToggle(
      {required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: active ? AppColors.emerald100 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              size: 20,
              color: active
                  ? AppColors.emerald700
                  : AppColors.mutedForeground),
        ),
      );
}

