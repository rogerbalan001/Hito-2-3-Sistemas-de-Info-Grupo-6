import 'package:flutter/material.dart';
import 'data/mock_data.dart';
import 'models/accommodation.dart';
import 'services/accommodation_repository.dart';
import 'services/auth_service.dart';
import 'services/reservation_service.dart';
import 'services/review_service.dart';
import 'theme/app_theme.dart';

/// Comunidad y Feedback: estadísticas + reseñas validando precios.
class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);
  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final _searchController = TextEditingController();
  String _search = '';
  bool _showForm = false;

  // Form
  final _nameController = TextEditingController();
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _priceOk = true;
  String? _alojamientoSel;
  String _ubicacionSel = '';

  // Alojamientos donde el usuario tiene reservas "Disfrutado"/"Pagado".
  // Solo estos aparecen en el selector de reseña.
  Set<String> _visitados = {};
  bool _cargandoVisitados = false;

  @override
  void initState() {
    super.initState();
    _cargarVisitados();
  }

  Future<void> _cargarVisitados() async {
    if (AuthService().currentUser == null) return;
    setState(() => _cargandoVisitados = true);
    final visitados = await ReservationService().alojamientosVisitados();
    if (mounted) setState(() {
      _visitados = visitados;
      _cargandoVisitados = false;
    });
  }

  /// Solo ofrece como opciones los alojamientos/paquetes donde el usuario
  /// tiene una reserva "Disfrutado" o "Pagado". Si no hay ninguno, el
  /// formulario avisa que necesita haber visitado un lugar primero.
  List<_OpcionResena> _opciones(List<Accommodation> alojamientos) {
    final vistos = <String>{};
    final opciones = <_OpcionResena>[];
    for (final a in alojamientos) {
      if (_visitados.contains(a.name) && vistos.add(a.name)) {
        opciones.add(_OpcionResena(a.name, a.location));
      }
    }
    for (final p in MockData.packages) {
      if (_visitados.contains(p.name) && vistos.add(p.name)) {
        opciones.add(_OpcionResena(p.name, p.destination));
      }
    }
    return opciones;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  List<Review> _filtrar(List<Review> reviews) {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return reviews;
    return reviews
        .where((r) =>
            r.comment.toLowerCase().contains(q) ||
            r.userName.toLowerCase().contains(q))
        .toList();
  }

  String _fechaHoy() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _publish() async {
    final name = _nameController.text.trim();
    final comment = _commentController.text.trim();
    if (name.isEmpty || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa nombre y comentario')),
      );
      return;
    }
    if (_alojamientoSel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Elige el alojamiento o paquete que reseñas')),
      );
      return;
    }
    final initials = name
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0])
        .take(2)
        .join()
        .toUpperCase();
    final review = Review(
      userName: name,
      avatar: initials,
      rating: _rating,
      comment: comment,
      priceAccuracy: _priceOk,
      date: _fechaHoy(),
      accommodationName: _alojamientoSel!,
      accommodationLocation: _ubicacionSel,
    );
    try {
      // Persiste en Firestore; la lista se actualiza sola por el stream.
      await ReviewService().agregar(review);
      if (!mounted) return;
      setState(() {
        _nameController.clear();
        _commentController.clear();
        _rating = 5;
        _priceOk = true;
        _alojamientoSel = null;
        _ubicacionSel = '';
        _showForm = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reseña publicada exitosamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo publicar la reseña: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Review>>(
      stream: ReviewService().watchAll(),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? const <Review>[];
        final filtered = _filtrar(reviews);
        final avg = reviews.isEmpty
            ? 0.0
            : reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                reviews.length;
        final rate = reviews.isEmpty
            ? 0
            : ((reviews.where((r) => r.priceAccuracy).length /
                        reviews.length) *
                    100)
                .round();
        return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Comunidad y Feedback',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text(
                      'Los viajeros validan si los costos reportados coinciden '
                      'con la realidad',
                      style: TextStyle(color: AppColors.mutedForeground)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Botón "Escribir Reseña": solo visible con sesión activa.
            if (AuthService().currentUser != null)
              ElevatedButton.icon(
                onPressed: () {
                  // Si el usuario no ha visitado ningún lugar, se le avisa
                  // en vez de abrir el formulario vacío.
                  if (!_cargandoVisitados && _visitados.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Solo puedes reseñar alojamientos donde '
                          'te hayas hospedado (reserva "Pagado" o "Disfrutado").',
                        ),
                      ),
                    );
                    return;
                  }
                  setState(() => _showForm = !_showForm);
                },
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text('Escribir Reseña'),
              ),
          ],
        ),
        const SizedBox(height: 20),

        // Stats 2x2 / 4.
        _StatsWrap(children: [
          _MiniStat(
              value: '${reviews.length}',
              label: 'Total Reseñas',
              color: AppColors.emerald700),
          _MiniStat(
              value: avg.toStringAsFixed(1),
              label: 'Rating Promedio',
              color: AppColors.amber600),
          _MiniStat(
              value: '$rate%',
              label: 'Precisión de Precios',
              color: AppColors.blue600),
          _MiniStat(
              value: '${MockData.accommodations.length}',
              label: 'Alojamientos Evaluados',
              color: AppColors.purple600),
        ]),
        const SizedBox(height: 20),

        if (_showForm) _buildForm(),

        // Buscador.
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _search = v),
            decoration: const InputDecoration(
              hintText: 'Buscar en reseñas...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text('Mostrando ${filtered.length} de ${reviews.length} reseñas',
            style: const TextStyle(
                fontSize: 13, color: AppColors.mutedForeground)),
        const SizedBox(height: 12),

        ...filtered.map((r) => _ReviewCard(review: r)),
      ],
        );
      },
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nueva Reseña',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tu nombre',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          // Selector del alojamiento o paquete que se está reseñando. Carga el
          // catálogo real en tiempo real y le suma los paquetes turísticos.
          StreamBuilder<List<Accommodation>>(
            stream: AccommodationRepository().watchAll(),
            builder: (context, snapshot) {
              final opciones = _opciones(snapshot.data ?? const []);
              final nombres = opciones.map((o) => o.nombre).toSet();
              return DropdownButtonFormField<String>(
                initialValue:
                    nombres.contains(_alojamientoSel) ? _alojamientoSel : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Alojamiento o paquete',
                  prefixIcon: Icon(Icons.home_work_outlined),
                ),
                hint: const Text('Selecciona uno'),
                items: [
                  for (final o in opciones)
                    DropdownMenuItem<String>(
                      value: o.nombre,
                      child: Text(
                        o.ubicacion.isEmpty
                            ? o.nombre
                            : '${o.nombre} · ${o.ubicacion}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (valor) {
                  setState(() {
                    _alojamientoSel = valor;
                    _ubicacionSel = opciones
                        .firstWhere((o) => o.nombre == valor,
                            orElse: () => const _OpcionResena('', ''))
                        .ubicacion;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 12),
          const Text('Calificación',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (i) {
              final n = i + 1;
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  n <= _rating ? Icons.star : Icons.star_border,
                  color: AppColors.amber500,
                  size: 28,
                ),
                onPressed: () => setState(() => _rating = n),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Comentario',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text('¿Los precios coinciden con la realidad?',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              ChoiceChip(
                label: const Text('Sí'),
                selected: _priceOk,
                selectedColor: AppColors.emerald100,
                onSelected: (_) => setState(() => _priceOk = true),
              ),
              const SizedBox(width: 6),
              ChoiceChip(
                label: const Text('No'),
                selected: !_priceOk,
                selectedColor: AppColors.red50,
                onSelected: (_) => setState(() => _priceOk = false),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _publish,
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Publicar Reseña'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Opción del selector de reseña: un alojamiento o paquete con su ubicación.
class _OpcionResena {
  final String nombre;
  final String ubicacion;
  const _OpcionResena(this.nombre, this.ubicacion);
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final r = review;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: AppColors.emerald100, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(r.avatar,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.emerald700)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(r.userName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < r.rating ? Icons.star : Icons.star_border,
                          size: 14,
                          color: AppColors.amber500,
                        ),
                      ),
                    ),
                    Text(r.date,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.mutedForeground)),
                  ],
                ),
                if (r.accommodationName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    r.accommodationLocation.isEmpty
                        ? r.accommodationName
                        : '${r.accommodationName} · ${r.accommodationLocation}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.mutedForeground),
                  ),
                ],
                const SizedBox(height: 6),
                Text(r.comment, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: r.priceAccuracy
                        ? AppColors.emerald50
                        : AppColors.red50,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          r.priceAccuracy
                              ? Icons.thumb_up_alt_outlined
                              : Icons.thumb_down_alt_outlined,
                          size: 12,
                          color: r.priceAccuracy
                              ? AppColors.emerald700
                              : AppColors.red600),
                      const SizedBox(width: 4),
                      Text(
                          r.priceAccuracy
                              ? 'Precio verificado'
                              : 'Precio no coincide',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: r.priceAccuracy
                                  ? AppColors.emerald700
                                  : AppColors.red600)),
                    ],
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

/// Fila de mini-estadísticas responsiva (2 o 4 columnas).
class _StatsWrap extends StatelessWidget {
  final List<Widget> children;
  const _StatsWrap({required this.children});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 720 ? 4 : 2;
      final w = (c.maxWidth - 12 * (cols - 1)) / cols;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children:
            children.map((e) => SizedBox(width: w, child: e)).toList(),
      );
    });
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _MiniStat(
      {required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}
