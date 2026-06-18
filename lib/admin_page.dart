import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/mock_data.dart';
import 'models/accommodation.dart';
import 'services/accommodation_repository.dart';
import 'services/accommodation_service.dart';
import 'services/reservation_service.dart';
import 'theme/app_theme.dart';

/// Pantalla de Administración (RF de mantenimiento).
/// Replica el diseño del Figma: pestañas tipo "chip" que cambian la tabla
/// mostrada en una tarjeta blanca, con botón "Agregar" y contador de registros.
/// Es contenido plano (sin Scaffold) porque la barra superior la aporta
/// [MainShell]. Las acciones (agregar/editar/eliminar) son de demostración.
class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _tab = 0;

  static const _tabs = [
    'Hospedajes',
    'Reservas',
    'Paquetes Turísticos',
    'Transporte',
    'Regiones',
    'Moderar Reseñas',
  ];

  // Reseñas pendientes de moderar (las que reportan precio no exacto).
  int get _pendientes =>
      MockData.reviews.where((r) => !r.priceAccuracy).length;

  void _demo(String accion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$accion (demostración)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Accommodation>>(
      stream: AccommodationRepository().watchAll(),
      builder: (context, snapshot) {
        final hospedajes = snapshot.data ?? const <Accommodation>[];
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: ReservationService().todasLasReservas(),
          builder: (context, snapshotRes) {
            final reservas = snapshotRes.data?.docs ?? [];
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  children: [
                    const Text(
                      'Administración',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tablas de mantenimiento para la gestión del sistema',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                    const SizedBox(height: 20),

                    // Pestañas tipo chip.
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (var i = 0; i < _tabs.length; i++)
                          _TabChip(
                            label: _tabs[i],
                            active: _tab == i,
                            badge: i == 5 && _pendientes > 0 ? _pendientes : null,
                            onTap: () => setState(() => _tab = i),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tarjeta con la tabla de la pestaña activa.
                    _card(hospedajes, reservas),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _card(List<Accommodation> hospedajes, List<QueryDocumentSnapshot<Map<String, dynamic>>> reservas) {
    final info = _currentTable(hospedajes, reservas);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _tabs[_tab],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _demo('Agregar registro'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // La tabla puede ser ancha: scroll horizontal en pantallas chicas.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 64 > 1036
                    ? 1036
                    : MediaQuery.of(context).size.width - 64,
              ),
              child: info,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Text(
              '${_rowCount(hospedajes, reservas)} registro(s)',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }

  int _rowCount(List<Accommodation> hospedajes, List<QueryDocumentSnapshot<Map<String, dynamic>>> reservas) {
    switch (_tab) {
      case 0:
        return hospedajes.length;
      case 1:
        return reservas.length;
      case 2:
        return MockData.packages.length;
      case 3:
        return MockData.transportLabels.length;
      case 4:
        return MockData.regions.length;
      default:
        return MockData.reviews.length;
    }
  }

  Widget _currentTable(List<Accommodation> hospedajes, List<QueryDocumentSnapshot<Map<String, dynamic>>> reservas) {
    switch (_tab) {
      case 0:
        return _hospedajes(hospedajes);
      case 1:
        return _reservasTab(reservas);
      case 2:
        return _paquetes();
      case 3:
        return _simpleList(MockData.transportLabels, 'Transporte');
      case 4:
        return _simpleList(MockData.regions, 'Región');
      default:
        return _resenas();
    }
  }

  // Estilo común de la tabla.
  DataTable _table(List<DataColumn> cols, List<DataRow> rows) {
    return DataTable(
      columns: cols,
      rows: rows,
      headingRowColor: WidgetStateProperty.all(AppColors.inputBackground),
      headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w700, color: AppColors.foreground, fontSize: 13),
      dataTextStyle:
          const TextStyle(color: AppColors.foreground, fontSize: 13),
      dividerThickness: 0.6,
      columnSpacing: 28,
    );
  }

  List<DataCell> _accionesCells() {
    return [
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                size: 18, color: AppColors.blue600),
            onPressed: () => _demo('Editar'),
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 18, color: AppColors.red600),
            onPressed: () => _demo('Eliminar'),
            tooltip: 'Eliminar',
          ),
        ],
      )),
    ];
  }

  Widget _hospedajes(List<Accommodation> hospedajes) {
    if (hospedajes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text('No hay alojamientos registrados',
              style: TextStyle(color: AppColors.mutedForeground)),
        ),
      );
    }
    return _table(
      const [
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('Tipo')),
        DataColumn(label: Text('Ubicación')),
        DataColumn(label: Text('Precio/Noche')),
        DataColumn(label: Text('Capacidad')),
        DataColumn(label: Text('Estado')),
        DataColumn(label: Text('Acciones')),
      ],
      hospedajes.map((a) {
        return DataRow(cells: [
          DataCell(Text(a.name)),
          DataCell(Text(a.type)),
          DataCell(Text(a.location)),
          DataCell(Text('\$${a.pricePerNight.round()}')),
          DataCell(Text('${a.capacity ?? '-'}')),
          DataCell(_estadoBadge(a.available)),
          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: AppColors.blue600),
                onPressed: () => _editarAlojamiento(a),
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppColors.red600),
                onPressed: () => _eliminarAlojamiento(a),
                tooltip: 'Eliminar',
              ),
            ],
          )),
        ]);
      }).toList(),
    );
  }

  /// Pide confirmación y elimina el alojamiento de Firestore. La tabla se
  /// actualiza sola porque escucha la colección en tiempo real.
  Future<void> _eliminarAlojamiento(Accommodation a) async {
    if (a.id == null) return;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar alojamiento'),
        content: Text('¿Seguro que deseas eliminar "${a.name}"? '
            'Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.red600),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await AccommodationService().eliminarAlojamiento(a.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${a.name}" eliminado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $e')),
      );
    }
  }

  /// Abre un formulario para modificar los datos del alojamiento.
  Future<void> _editarAlojamiento(Accommodation a) async {
    if (a.id == null) return;
    final nombreCtrl = TextEditingController(text: a.name);
    final tipoCtrl = TextEditingController(text: a.type);
    final destinoCtrl = TextEditingController(text: a.location);
    final precioCtrl =
        TextEditingController(text: a.pricePerNight.toStringAsFixed(0));
    final capacidadCtrl =
        TextEditingController(text: '${a.capacity ?? 0}');
    final descripcionCtrl = TextEditingController(text: a.description ?? '');
    var disponible = a.available;

    final guardar = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Editar alojamiento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: tipoCtrl,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                ),
                TextField(
                  controller: destinoCtrl,
                  decoration: const InputDecoration(labelText: 'Ubicación'),
                ),
                TextField(
                  controller: precioCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Precio por noche'),
                ),
                TextField(
                  controller: capacidadCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Capacidad'),
                ),
                TextField(
                  controller: descripcionCtrl,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(labelText: 'Descripción'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Disponible'),
                  value: disponible,
                  activeColor: AppColors.emerald600,
                  onChanged: (val) =>
                      setStateDialog(() => disponible = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald600,
                  foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    if (guardar != true) return;
    try {
      await AccommodationService().actualizarAlojamiento(
        a.id!,
        nombre: nombreCtrl.text.trim(),
        destino: destinoCtrl.text.trim(),
        tipo: tipoCtrl.text.trim(),
        precioPorNoche: double.tryParse(precioCtrl.text.trim()) ??
            a.pricePerNight,
        capacidad:
            int.tryParse(capacidadCtrl.text.trim()) ?? (a.capacity ?? 0),
        descripcion: descripcionCtrl.text.trim(),
        available: disponible,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${nombreCtrl.text.trim()}" actualizado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar: $e')),
      );
    }
  }

  Widget _reservasTab(List<QueryDocumentSnapshot<Map<String, dynamic>>> reservas) {
    if (reservas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text('No hay reservas registradas',
              style: TextStyle(color: AppColors.mutedForeground)),
        ),
      );
    }
    return _table(
      const [
        DataColumn(label: Text('Usuario')),
        DataColumn(label: Text('Destino')),
        DataColumn(label: Text('Precio')),
        DataColumn(label: Text('Estado')),
        DataColumn(label: Text('Acciones')),
      ],
      reservas.map((doc) {
        final data = doc.data();
        final id = doc.id;
        final email = data['usuarioEmail'] ?? 'Sin correo';
        final destino = data['ubicacion'] ?? data['alojamiento'] ?? 'Desconocido';
        final precio = data['precioPorNoche'] ?? 0;
        final estado = data['estado'] ?? 'Solicitado';

        return DataRow(cells: [
          DataCell(Text(email.toString())),
          DataCell(Text(destino.toString())),
          DataCell(Text('\$$precio')),
          DataCell(_estadoReservaBadge(estado.toString())),
          DataCell(
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18, color: AppColors.mutedForeground),
              tooltip: 'Cambiar estado',
              onSelected: (nuevoEstado) async {
                try {
                  await ReservationService().actualizarEstado(id, nuevoEstado);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Estado actualizado a $nuevoEstado')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al actualizar: $e')),
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'Solicitado', child: Text('Marcar como Solicitado')),
                PopupMenuItem(value: 'Aprobado', child: Text('Aprobar Reserva')),
                PopupMenuItem(value: 'Pagado', child: Text('Marcar como Pagado')),
                PopupMenuItem(value: 'Disfrutado', child: Text('Marcar como Disfrutado')),
                PopupMenuItem(value: 'Cancelado', child: Text('Cancelar Reserva')),
              ],
            ),
          ),
        ]);
      }).toList(),
    );
  }

  Widget _estadoReservaBadge(String estado) {
    Color bg;
    Color fg;
    switch (estado) {
      case 'Solicitado':
        bg = Colors.orange.shade50;
        fg = AppColors.amber500;
        break;
      case 'Aprobado':
        bg = Colors.blue.shade50;
        fg = AppColors.blue600;
        break;
      case 'Pagado':
      case 'Disfrutado':
        bg = AppColors.emerald50;
        fg = AppColors.emerald700;
        break;
      case 'Cancelado':
        bg = AppColors.red50;
        fg = AppColors.red600;
        break;
      default:
        bg = AppColors.inputBackground;
        fg = AppColors.mutedForeground;
    }
    return _miniBadge(estado, bg, fg);
  }

  Widget _paquetes() {
    return _table(
      const [
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('Destino')),
        DataColumn(label: Text('Duración')),
        DataColumn(label: Text('Precio')),
        DataColumn(label: Text('Rating')),
        DataColumn(label: Text('Acciones')),
      ],
      MockData.packages.map((p) {
        return DataRow(cells: [
          DataCell(Text(p.name)),
          DataCell(Text(p.destination)),
          DataCell(Text(p.duration)),
          DataCell(Text('\$${p.price.round()}')),
          DataCell(Row(
            children: [
              const Icon(Icons.star, size: 14, color: AppColors.amber500),
              const SizedBox(width: 4),
              Text(p.rating.toStringAsFixed(1)),
            ],
          )),
          ..._accionesCells(),
        ]);
      }).toList(),
    );
  }

  Widget _simpleList(List<String> items, String colName) {
    return _table(
      [
        DataColumn(label: Text(colName)),
        const DataColumn(label: Text('Acciones')),
      ],
      items.map((t) {
        return DataRow(cells: [
          DataCell(Text(t)),
          ..._accionesCells(),
        ]);
      }).toList(),
    );
  }

  Widget _resenas() {
    return _table(
      const [
        DataColumn(label: Text('Usuario')),
        DataColumn(label: Text('Alojamiento')),
        DataColumn(label: Text('Rating')),
        DataColumn(label: Text('Precio')),
        DataColumn(label: Text('Acciones')),
      ],
      MockData.reviews.map((r) {
        return DataRow(cells: [
          DataCell(Text(r.userName)),
          DataCell(Text(r.accommodationName)),
          DataCell(Row(
            children: [
              const Icon(Icons.star, size: 14, color: AppColors.amber500),
              const SizedBox(width: 4),
              Text('${r.rating}'),
            ],
          )),
          DataCell(
            r.priceAccuracy
                ? _miniBadge('Verificado', AppColors.emerald50,
                    AppColors.emerald700)
                : _miniBadge('Reportado', AppColors.red50, AppColors.red600),
          ),
          ..._accionesCells(),
        ]);
      }).toList(),
    );
  }

  Widget _estadoBadge(bool active) {
    return _miniBadge(
      active ? 'Activo' : 'Inactivo',
      active ? AppColors.emerald50 : AppColors.inputBackground,
      active ? AppColors.emerald700 : AppColors.mutedForeground,
    );
  }

  Widget _miniBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

/// Chip de pestaña con badge opcional (para "Moderar Reseñas").
class _TabChip extends StatelessWidget {
  final String label;
  final bool active;
  final int? badge;
  final VoidCallback onTap;
  const _TabChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.emerald600 : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active ? AppColors.emerald600 : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.foreground,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: const BoxDecoration(
                    color: AppColors.red600,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
