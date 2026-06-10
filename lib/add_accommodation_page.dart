import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'services/accommodation_service.dart';
import 'theme/app_theme.dart';

/// Gestión de Publicaciones.
/// Formulario donde un OPERADOR registra un alojamiento (nombre, destino, tipo,
/// precio, capacidad). Al guardar hace un push a la colección "accommodations"
/// de Cloud Firestore mediante AccommodationService.
class AddAccommodationPage extends StatefulWidget {
  const AddAccommodationPage({Key? key}) : super(key: key);

  @override
  State<AddAccommodationPage> createState() => _AddAccommodationPageState();
}

class _AddAccommodationPageState extends State<AddAccommodationPage> {
  final _service = AccommodationService();
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _destinoController = TextEditingController();
  final _precioController = TextEditingController();
  final _capacidadController = TextEditingController();
  final _descripcionController = TextEditingController();

  static const _tipos = ['Posada', 'Camping', 'Hostal', 'Cabaña', 'Eco-Lodge'];
  String _tipo = 'Posada';

  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _destinoController.dispose();
    _precioController.dispose();
    _capacidadController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      await _service.agregarAlojamiento(
        nombre: _nombreController.text.trim(),
        destino: _destinoController.text.trim(),
        tipo: _tipo,
        precioPorNoche: double.parse(_precioController.text.trim()),
        capacidad: int.parse(_capacidadController.text.trim()),
        descripcion: _descripcionController.text.trim(),
      );
      _showMessage('Alojamiento publicado correctamente');
      // Limpia el formulario para una nueva carga.
      _formKey.currentState!.reset();
      _nombreController.clear();
      _destinoController.clear();
      _precioController.clear();
      _capacidadController.clear();
      _descripcionController.clear();
      setState(() => _tipo = 'Posada');
    } catch (e) {
      _showMessage('No se pudo publicar: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Publicar alojamiento')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const Text(
            'Registra tu servicio',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Completa los datos para que los viajeros encuentren tu alojamiento.',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 20),

          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nombreController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del alojamiento',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa el nombre'
                      : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _destinoController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Destino / ubicación',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa el destino'
                      : null,
                ),
                const SizedBox(height: 14),

                // Tipo de alojamiento.
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _tipo,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.mutedForeground),
                      items: _tipos
                          .map((t) =>
                              DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (val) => setState(() => _tipo = val ?? _tipo),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _precioController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Precio/noche',
                          prefixText: '\$ ',
                        ),
                        validator: (v) {
                          final n = double.tryParse((v ?? '').trim());
                          if (n == null) return 'Número inválido';
                          if (n <= 0) return 'Debe ser mayor a 0';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _capacidadController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Capacidad',
                          prefixIcon: Icon(Icons.group_outlined),
                        ),
                        validator: (v) {
                          final n = int.tryParse((v ?? '').trim());
                          if (n == null) return 'Número inválido';
                          if (n <= 0) return 'Debe ser mayor a 0';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _descripcionController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _guardando ? null : _guardar,
                    icon: _guardando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_outlined, size: 20),
                    label: Text(_guardando ? 'Guardando...' : 'Guardar'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Mis publicaciones',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          // Lista en tiempo real de lo que ha publicado este operador.
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _service.misAlojamientos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Todavía no has publicado alojamientos.',
                    style: TextStyle(color: AppColors.mutedForeground),
                  ),
                );
              }
              return Column(
                children: docs.map((d) {
                  final data = d.data();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.home_work_outlined,
                            color: AppColors.emerald700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (data['nombre'] ?? '') as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${data['destino'] ?? ''} · '
                                '${data['tipo'] ?? ''}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.mutedForeground),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${((data['precioPorNoche'] ?? 0).toDouble()).round()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.emerald700,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
