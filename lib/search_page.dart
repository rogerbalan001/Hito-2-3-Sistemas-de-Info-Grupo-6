import 'package:flutter/material.dart';
import 'models/accommodation.dart';
import 'services/accommodation_repository.dart';
import 'services/reservation_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);
  @override
  _SearchPageState createState() => _SearchPageState();
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

  Future<void> _reservar(Accommodation a) async {
    try {
      await ReservationService().crearReserva(
        alojamiento: a.name,
        ubicacion: a.location,
        precioPorNoche: a.pricePerNight,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Reserva guardada'),
          content: Text(
            'Has solicitado "${a.name}" (${a.location}).\n'
            'Estado de la reserva: Solicitado.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la reserva: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se consulta al repositorio aplicando los filtros activos.
    final results = _repository.search(query: _query, maxBudget: _maxBudget);

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Alojamientos'), backgroundColor: Colors.green[800]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _query = val),
              decoration: const InputDecoration(
                hintText: '¿A dónde quieres ir?',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('Presupuesto Máximo: '),
                Expanded(
                  child: Slider(
                    value: _maxBudget,
                    min: 10,
                    max: 200,
                    divisions: 19,
                    label: '\$${_maxBudget.round()}',
                    activeColor: Colors.green,
                    onChanged: (val) => setState(() => _maxBudget = val),
                  ),
                ),
                Text('\$${_maxBudget.round()}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${results.length} resultado(s) encontrado(s)',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No hay alojamientos que cumplan con los filtros.\nPrueba subir el presupuesto o cambiar el destino.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final a = results[index];
                      return ListTile(
                        leading: Icon(_iconFor(a.type), color: Colors.green),
                        title: Text(a.name),
                        subtitle: Text('Precio: \$${a.pricePerNight.round()}/noche - ${a.location}'),
                        trailing: ElevatedButton(
                          onPressed: () => _reservar(a),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Reservar'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
