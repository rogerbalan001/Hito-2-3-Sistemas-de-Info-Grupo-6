import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/mock_data.dart';
import 'models/accommodation.dart';
import 'services/accommodation_repository.dart';
import 'services/accommodation_service.dart';
import 'services/reservation_service.dart';
import 'services/review_service.dart';
import 'services/package_service.dart';
import 'services/catalog_service.dart';
import 'theme/app_theme.dart';

/// Pantalla de Administración (RF de mantenimiento).
/// Pestañas tipo "chip" que cambian la tabla mostrada. Cada pestaña lee su
/// colección de Cloud Firestore en tiempo real (solo la pestaña activa se
/// suscribe) y ofrece acciones reales de agregar/editar/eliminar.
/// Es contenido plano (sin Scaffold) porque la barra superior la aporta
/// [MainShell].
class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _tab = 0;

  // Servicios de catálogo simple (una sola columna "nombre").
  final CatalogService _transporte = CatalogService('transporte');
  final CatalogService _regiones = CatalogService('regiones');

  @override
  void initState() {
    super.initState();
    // Control de fechas: al abrir la administración, promueve a "Disfrutado"
    // las reservas pagadas cuya estadía ya terminó. Silencioso si falla.
    ReservationService().promoverReservasVencidas().catchError((_) {});
  }

  static const _tabs = [
    'Hospedajes',
    'Reservas',
    'Paquetes Turísticos',
    'Transporte',
    'Regiones',
    'Moderar Reseñas',
  ];

  // Solo Paquetes/Transporte/Regiones permiten "Agregar" desde aquí. Los
  // hospedajes se publican desde su propio flujo, las reservas las crean los
  // viajeros y las reseñas las escriben los usuarios en Comunidad.
  bool get _puedeAgregar => _tab == 2 || _tab == 3 || _tab == 4;

  @override
  Widget build(BuildContext context) {
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
                    onTap: () => setState(() => _tab = i),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            _card(),
          ],
        ),
      ),
    );
  }

  Widget _card() {
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
                if (_puedeAgregar)
                  ElevatedButton.icon(
                    onPressed: _onAgregar,
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
          _tabBody(),
        ],
      ),
    );
  }

  /// Cuerpo de la pestaña activa. Solo esta pestaña se suscribe a Firestore.
  Widget _tabBody() {
    switch (_tab) {
      case 0:
        return StreamBuilder<List<Accommodation>>(
          stream: AccommodationRepository().watchAll(),
          builder: (context, s) {
            final l = s.data ?? const <Accommodation>[];
            return _tabla(_hospedajes(l), l.length);
          },
        );
      case 1:
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: ReservationService().todasLasReservas(),
          builder: (context, s) {
            final docs = s.data?.docs ?? [];
            return _tabla(_reservasTab(docs), docs.length);
          },
        );
      case 2:
        return StreamBuilder<List<TouristPackage>>(
          stream: PackageService().watchAll(),
          builder: (context, s) {
            final l = s.data ?? const <TouristPackage>[];
            return _tabla(_paquetes(l), l.length);
          },
        );
      case 3:
        return StreamBuilder<List<NamedItem>>(
          stream: _transporte.watchAll(),
          builder: (context, s) {
            final l = s.data ?? const <NamedItem>[];
            return _tabla(
                _simpleList(l, 'Transporte', _transporte), l.length);
          },
        );
      case 4:
        return StreamBuilder<List<NamedItem>>(
          stream: _regiones.watchAll(),
          builder: (context, s) {
            final l = s.data ?? const <NamedItem>[];
            return _tabla(_simpleList(l, 'Región', _regiones), l.length);
          },
        );
      default:
        return StreamBuilder<List<Review>>(
          stream: ReviewService().watchAll(),
          builder: (context, s) {
            final l = s.data ?? const <Review>[];
            return _tabla(_resenas(l), l.length);
          },
        );
    }
  }

  /// Envuelve una tabla con scroll horizontal y el contador de registros.
  Widget _tabla(Widget tabla, int count) {
    final ancho = MediaQuery.of(context).size.width - 64;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: ancho > 1036 ? 1036 : ancho),
            child: tabla,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Text(
            '$count registro(s)',
            style: const TextStyle(
                fontSize: 13, color: AppColors.mutedForeground),
          ),
        ),
      ],
    );
  }

  void _onAgregar() {
    switch (_tab) {
      case 2:
        _formPaquete();
        break;
      case 3:
        _formNamed(_transporte, 'Transporte');
        break;
      case 4:
        _formNamed(_regiones, 'Región');
        break;
    }
  }

  Widget _vacio(String mensaje) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(mensaje,
            style: const TextStyle(color: AppColors.mutedForeground)),
      ),
    );
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

  // ===================== Hospedajes =====================

  Widget _hospedajes(List<Accommodation> hospedajes) {
    if (hospedajes.isEmpty) {
      return _vacio('No hay alojamientos registrados');
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

  Future<void> _eliminarAlojamiento(Accommodation a) async {
    if (a.id == null) return;
    // Protección: no se puede eliminar un alojamiento que tiene reservas
    // activas (Solicitado, Aprobado o Pagado). Cancelar una reserva en curso
    // sin avisar al viajero causaría una mala experiencia.
    final tieneActivas =
        await ReservationService().tieneReservasActivas(a.name);
    if (tieneActivas) {
      _avisar(
        'No se puede eliminar "${a.name}" porque tiene reservas activas '
        '(Solicitado, Aprobado o Pagado). Cancélalas primero desde la pestaña Reservas.',
      );
      return;
    }
    final confirmar = await _confirmarEliminar(a.name);
    if (confirmar != true) return;
    try {
      await AccommodationService().eliminarAlojamiento(a.id!);
      _avisar('"${a.name}" eliminado');
    } catch (e) {
      _avisar('No se pudo eliminar: $e');
    }
  }

  Future<void> _editarAlojamiento(Accommodation a) async {
    if (a.id == null) return;
    final nombreCtrl = TextEditingController(text: a.name);
    final tipoCtrl = TextEditingController(text: a.type);
    final destinoCtrl = TextEditingController(text: a.location);
    final precioCtrl =
        TextEditingController(text: a.pricePerNight.toStringAsFixed(0));
    final capacidadCtrl = TextEditingController(text: '${a.capacity ?? 0}');
    final descripcionCtrl = TextEditingController(text: a.description ?? '');
    final reglasCtrl = TextEditingController(text: a.rules.join('\n'));
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
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: reglasCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Reglas del lugar (una por línea)',
                    alignLabelWithHint: true,
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Disponible'),
                  value: disponible,
                  activeColor: AppColors.emerald600,
                  onChanged: (val) => setStateDialog(() => disponible = val),
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
        precioPorNoche:
            double.tryParse(precioCtrl.text.trim()) ?? a.pricePerNight,
        capacidad:
            int.tryParse(capacidadCtrl.text.trim()) ?? (a.capacity ?? 0),
        descripcion: descripcionCtrl.text.trim(),
        available: disponible,
        reglas: reglasFromText(reglasCtrl.text),
      );
      _avisar('"${nombreCtrl.text.trim()}" actualizado');
    } catch (e) {
      _avisar('No se pudo actualizar: $e');
    }
  }

  // ===================== Reservas =====================

  Widget _reservasTab(List<QueryDocumentSnapshot<Map<String, dynamic>>> reservas) {
    if (reservas.isEmpty) {
      return _vacio('No hay reservas registradas');
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
        final destino =
            data['ubicacion'] ?? data['alojamiento'] ?? 'Desconocido';
        final precio = data['precioPorNoche'] ?? 0;
        final estado = data['estado'] ?? 'Solicitado';

        return DataRow(cells: [
          DataCell(Text(email.toString())),
          DataCell(Text(destino.toString())),
          DataCell(Text('\$$precio')),
          DataCell(_estadoReservaBadge(estado.toString())),
          DataCell(
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                  size: 18, color: AppColors.mutedForeground),
              tooltip: 'Cambiar estado',
              onSelected: (nuevoEstado) async {
                try {
                  await ReservationService().actualizarEstado(id, nuevoEstado);
                  _avisar('Estado actualizado a $nuevoEstado');
                } catch (e) {
                  _avisar('Error al actualizar: $e');
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                    value: 'Solicitado',
                    child: Text('Marcar como Solicitado')),
                PopupMenuItem(
                    value: 'Aprobado', child: Text('Aprobar Reserva')),
                PopupMenuItem(
                    value: 'Pagado', child: Text('Marcar como Pagado')),
                PopupMenuItem(
                    value: 'Disfrutado',
                    child: Text('Marcar como Disfrutado')),
                PopupMenuItem(
                    value: 'Cancelado', child: Text('Cancelar Reserva')),
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

  // ===================== Paquetes turísticos =====================

  Widget _paquetes(List<TouristPackage> paquetes) {
    if (paquetes.isEmpty) {
      return _vacio('No hay paquetes registrados');
    }
    return _table(
      const [
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('Destino')),
        DataColumn(label: Text('Duración')),
        DataColumn(label: Text('Precio')),
        DataColumn(label: Text('Rating')),
        DataColumn(label: Text('Acciones')),
      ],
      paquetes.map((p) {
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
          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: AppColors.blue600),
                onPressed: () => _formPaquete(existente: p),
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppColors.red600),
                onPressed: () => _eliminarPaquete(p),
                tooltip: 'Eliminar',
              ),
            ],
          )),
        ]);
      }).toList(),
    );
  }

  /// Formulario para agregar o editar un paquete turístico.
  Future<void> _formPaquete({TouristPackage? existente}) async {
    final editando = existente != null;
    final nombreCtrl = TextEditingController(text: existente?.name ?? '');
    final destinoCtrl =
        TextEditingController(text: existente?.destination ?? '');
    final duracionCtrl =
        TextEditingController(text: existente?.duration ?? '');
    final precioCtrl = TextEditingController(
        text: existente != null ? existente.price.toStringAsFixed(0) : '');
    final incluyeCtrl =
        TextEditingController(text: existente?.includes.join(', ') ?? '');
    final imagenCtrl = TextEditingController(text: existente?.imageUrl ?? '');
    final ratingCtrl = TextEditingController(
        text: existente != null ? existente.rating.toStringAsFixed(1) : '');

    final guardar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(editando ? 'Editar paquete' : 'Nuevo paquete'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: destinoCtrl,
                decoration: const InputDecoration(labelText: 'Destino'),
              ),
              TextField(
                controller: duracionCtrl,
                decoration: const InputDecoration(
                    labelText: 'Duración (ej. 5 días / 4 noches)'),
              ),
              TextField(
                controller: precioCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio (USD)'),
              ),
              TextField(
                controller: incluyeCtrl,
                decoration: const InputDecoration(
                    labelText: 'Incluye (separado por comas)'),
              ),
              TextField(
                controller: imagenCtrl,
                decoration:
                    const InputDecoration(labelText: 'URL de imagen (opcional)'),
              ),
              TextField(
                controller: ratingCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rating (0-5)'),
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
    );
    if (guardar != true) return;

    final paquete = TouristPackage(
      name: nombreCtrl.text.trim(),
      destination: destinoCtrl.text.trim(),
      duration: duracionCtrl.text.trim(),
      price: double.tryParse(precioCtrl.text.trim()) ?? 0,
      includes: incluyeCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      imageUrl: imagenCtrl.text.trim(),
      rating: double.tryParse(ratingCtrl.text.trim()) ?? 0,
    );
    try {
      if (existente != null) {
        await PackageService().actualizar(existente.id!, paquete);
        _avisar('"${paquete.name}" actualizado');
      } else {
        await PackageService().agregar(paquete);
        _avisar('"${paquete.name}" agregado');
      }
    } catch (e) {
      _avisar('No se pudo guardar: $e');
    }
  }

  Future<void> _eliminarPaquete(TouristPackage p) async {
    if (p.id == null) return;
    final confirmar = await _confirmarEliminar(p.name);
    if (confirmar != true) return;
    try {
      await PackageService().eliminar(p.id!);
      _avisar('"${p.name}" eliminado');
    } catch (e) {
      _avisar('No se pudo eliminar: $e');
    }
  }

  // ===================== Transporte / Regiones =====================

  Widget _simpleList(List<NamedItem> items, String colName, CatalogService s) {
    if (items.isEmpty) {
      return _vacio('No hay registros');
    }
    return _table(
      [
        DataColumn(label: Text(colName)),
        const DataColumn(label: Text('Acciones')),
      ],
      items.map((it) {
        return DataRow(cells: [
          DataCell(Text(it.nombre)),
          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: AppColors.blue600),
                onPressed: () => _formNamed(s, colName, existente: it),
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppColors.red600),
                onPressed: () => _eliminarNamed(s, it),
                tooltip: 'Eliminar',
              ),
            ],
          )),
        ]);
      }).toList(),
    );
  }

  /// Formulario para agregar o editar un elemento simple (transporte/región).
  Future<void> _formNamed(CatalogService s, String label,
      {NamedItem? existente}) async {
    final editando = existente != null;
    final ctrl = TextEditingController(text: existente?.nombre ?? '');
    final guardar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(editando ? 'Editar $label' : 'Nuevo $label'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(labelText: label),
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
    );
    if (guardar != true) return;
    final nombre = ctrl.text.trim();
    if (nombre.isEmpty) return;
    try {
      if (existente != null) {
        await s.actualizar(existente.id, nombre);
        _avisar('"$nombre" actualizado');
      } else {
        await s.agregar(nombre);
        _avisar('"$nombre" agregado');
      }
    } catch (e) {
      _avisar('No se pudo guardar: $e');
    }
  }

  Future<void> _eliminarNamed(CatalogService s, NamedItem it) async {
    final confirmar = await _confirmarEliminar(it.nombre);
    if (confirmar != true) return;
    try {
      await s.eliminar(it.id);
      _avisar('"${it.nombre}" eliminado');
    } catch (e) {
      _avisar('No se pudo eliminar: $e');
    }
  }

  // ===================== Moderar Reseñas =====================

  Widget _resenas(List<Review> reviews) {
    if (reviews.isEmpty) {
      return _vacio('No hay reseñas registradas');
    }
    return _table(
      const [
        DataColumn(label: Text('Usuario')),
        DataColumn(label: Text('Alojamiento')),
        DataColumn(label: Text('Rating')),
        DataColumn(label: Text('Precio')),
        DataColumn(label: Text('Acciones')),
      ],
      reviews.map((r) {
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
          DataCell(
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: AppColors.red600),
              onPressed: () => _eliminarResena(r),
              tooltip: 'Eliminar reseña',
            ),
          ),
        ]);
      }).toList(),
    );
  }

  Future<void> _eliminarResena(Review r) async {
    if (r.id == null) return;
    final confirmar = await _confirmarEliminar('la reseña de ${r.userName}');
    if (confirmar != true) return;
    try {
      await ReviewService().eliminar(r.id!);
      _avisar('Reseña eliminada');
    } catch (e) {
      _avisar('No se pudo eliminar: $e');
    }
  }

  // ===================== Helpers comunes =====================

  Future<bool?> _confirmarEliminar(String nombre) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar eliminación'),
        content: Text('¿Seguro que deseas eliminar "$nombre"? '
            'Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red600),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _avisar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
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

/// Chip de pestaña.
class _TabChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabChip({
    required this.label,
    required this.active,
    required this.onTap,
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
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppColors.foreground,
            ),
          ),
        ),
      ),
    );
  }
}
