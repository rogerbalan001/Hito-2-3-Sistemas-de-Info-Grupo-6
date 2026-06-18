import 'package:flutter/material.dart';
import 'data/mock_data.dart';
import 'theme/app_theme.dart';

/// Comunidad y Feedback: estadísticas + reseñas validando precios.
class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);
  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final List<Review> _reviews = [...MockData.reviews];
  final _searchController = TextEditingController();
  String _search = '';
  bool _showForm = false;

  // Form
  final _nameController = TextEditingController();
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _priceOk = true;

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  List<Review> get _filtered {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return _reviews;
    return _reviews
        .where((r) =>
            r.comment.toLowerCase().contains(q) ||
            r.userName.toLowerCase().contains(q))
        .toList();
  }

  double get _avgRating => _reviews.isEmpty
      ? 0
      : _reviews.map((r) => r.rating).reduce((a, b) => a + b) /
          _reviews.length;

  int get _priceAccuracyRate => _reviews.isEmpty
      ? 0
      : ((_reviews.where((r) => r.priceAccuracy).length / _reviews.length) *
              100)
          .round();

  void _publish() {
    final name = _nameController.text.trim();
    final comment = _commentController.text.trim();
    if (name.isEmpty || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa nombre y comentario')),
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
    setState(() {
      _reviews.insert(
        0,
        Review(
          userName: name,
          avatar: initials,
          rating: _rating,
          comment: comment,
          priceAccuracy: _priceOk,
          date: '2026-06-11',
          accommodationName: 'Reseña general',
          accommodationLocation: '',
        ),
      );
      _nameController.clear();
      _commentController.clear();
      _rating = 5;
      _priceOk = true;
      _showForm = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reseña publicada exitosamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            ElevatedButton.icon(
              onPressed: () => setState(() => _showForm = !_showForm),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Escribir Reseña'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Stats 2x2 / 4.
        _StatsWrap(children: [
          _MiniStat(
              value: '${_reviews.length}',
              label: 'Total Reseñas',
              color: AppColors.emerald700),
          _MiniStat(
              value: _avgRating.toStringAsFixed(1),
              label: 'Rating Promedio',
              color: AppColors.amber600),
          _MiniStat(
              value: '$_priceAccuracyRate%',
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

        Text('Mostrando ${_filtered.length} de ${_reviews.length} reseñas',
            style: const TextStyle(
                fontSize: 13, color: AppColors.mutedForeground)),
        const SizedBox(height: 12),

        ..._filtered.map((r) => _ReviewCard(review: r)),
      ],
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
