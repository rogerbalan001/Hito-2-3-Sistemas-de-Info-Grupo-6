import 'package:flutter/material.dart';
import 'models/accommodation.dart';
import 'services/accommodation_repository.dart';
import 'accommodation_details_page.dart';
import 'theme/app_theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _repository = AccommodationRepository();
  final _searchController = TextEditingController();

  double _maxBudget = 50.0;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  void _abrirDetalle(Accommodation a) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccommodationDetailsPage(accommodation: a),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _repository.search(query: _query, maxBudget: _maxBudget);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const EcoSpotLogo()),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const Text(
            'Búsqueda de Opciones Económicas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Encuentra el alojamiento perfecto para tu presupuesto',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 20),

          // Barra de búsqueda.
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _query = val),
            decoration: const InputDecoration(
              hintText: 'Buscar por nombre o ubicación...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),

          // Tarjeta de filtros (presupuesto).
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Presupuesto Máximo: \$${_maxBudget.round()}/noche',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$10',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground)),
                      Text('\$200',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            '${results.length} resultado(s) encontrado(s)',
            style: const TextStyle(
                fontSize: 14, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 12),

          if (results.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  Icon(Icons.search,
                      size: 48, color: AppColors.mutedForeground),
                  SizedBox(height: 12),
                  Text(
                    'No se encontraron resultados',
                    style: TextStyle(
                        fontSize: 16, color: AppColors.mutedForeground),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Intenta subir el presupuesto o cambiar el destino.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13, color: AppColors.mutedForeground),
                  ),
                ],
              ),
            )
          else
            ...results.map((a) => _AccommodationCard(
                  accommodation: a,
                  fallbackIcon: _iconFor(a.type),
                  onOpen: () => _abrirDetalle(a),
                )),
        ],
      ),
    );
  }
}

/// Tarjeta de alojamiento con foto, rating, precio y acceso al detalle.
class _AccommodationCard extends StatelessWidget {
  final Accommodation accommodation;
  final IconData fallbackIcon;
  final VoidCallback onOpen;
  const _AccommodationCard({
    required this.accommodation,
    required this.fallbackIcon,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final a = accommodation;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: EcoImage(
                    url: a.imageUrl, height: 160, fallbackIcon: fallbackIcon),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
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
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.emerald100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            a.type,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.emerald700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 14, color: AppColors.mutedForeground),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            a.location,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedForeground),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    StarRating(rating: a.rating, reviewCount: a.reviewCount),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '\$${a.pricePerNight.round()}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.emerald700,
                                ),
                              ),
                              const TextSpan(
                                text: '/noche',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: onOpen,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            minimumSize: const Size(0, 36),
                            textStyle: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Ver detalle'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
