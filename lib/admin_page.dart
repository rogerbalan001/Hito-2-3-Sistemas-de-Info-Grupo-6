import 'package:flutter/material.dart';
import 'data/mock_data.dart';
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
    'Tipos de Reserva',
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
        _card(),
      ],
        ),
      ),
    );
  }

  Widget _card() {
    final info = _currentTable();
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
              '${_rowCount()} registro(s)',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }

  int _rowCount() {
    switch (_tab) {
      case 0:
        return MockData.accommodations.length;
      case 1:
        return MockData.statusDistribution.length;
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

  Widget _currentTable() {
    switch (_tab) {
      case 0:
        return _hospedajes();
      case 1:
        return _tiposReserva();
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

  Widget _hospedajes() {
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
      MockData.accommodations.map((a) {
        return DataRow(cells: [
          DataCell(Text(a.name)),
          DataCell(Text(a.type)),
          DataCell(Text(a.location)),
          DataCell(Text('\$${a.pricePerNight.round()}')),
          DataCell(Text('${a.capacity ?? '-'}')),
          DataCell(_estadoBadge(a.available)),
          ..._accionesCells(),
        ]);
      }).toList(),
    );
  }

  Widget _tiposReserva() {
    return _table(
      const [
        DataColumn(label: Text('Estado')),
        DataColumn(label: Text('Reservas')),
        DataColumn(label: Text('Acciones')),
      ],
      MockData.statusDistribution.map((s) {
        return DataRow(cells: [
          DataCell(Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Color(s.colorValue),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(s.status),
            ],
          )),
          DataCell(Text('${s.count}')),
          ..._accionesCells(),
        ]);
      }).toList(),
    );
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
