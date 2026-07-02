import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'data/mock_data.dart';
import 'services/dashboard_service.dart';
import 'theme/app_theme.dart';

/// Dashboard de Tendencias — versión minimalista.
/// KPIs en tiempo real desde Firestore + gráficas limpias con datos de ejemplo.
class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      children: [
        // Encabezado
        const Text('Tendencias',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        const Text('Vista general del sistema en tiempo real',
            style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
        const SizedBox(height: 24),

        // KPIs en tiempo real
        StreamBuilder<DashboardMetrics>(
          stream: DashboardService().watchMetrics(),
          builder: (context, snap) {
            final m = snap.data ?? DashboardMetrics.empty;
            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _KpiCard(
                  icon: Icons.attach_money_rounded,
                  value: '\$${m.ingresos.round()}',
                  label: 'Ingresos',
                  color: AppColors.emerald600,
                ),
                _KpiCard(
                  icon: Icons.calendar_today_outlined,
                  value: '${m.totalReservas}',
                  label: 'Reservas',
                  color: AppColors.blue600,
                ),
                _KpiCard(
                  icon: Icons.home_outlined,
                  value: '${MockData.accommodations.length}',
                  label: 'Alojamientos',
                  color: AppColors.purple600,
                ),
                _KpiCard(
                  icon: Icons.place_outlined,
                  value: '${MockData.searchesByDestination.length}',
                  label: 'Destinos',
                  color: const Color(0xFFD97706),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),

        // Estado de reservas (donut) — datos en vivo
        StreamBuilder<DashboardMetrics>(
          stream: DashboardService().watchMetrics(),
          builder: (context, snap) {
            final m = snap.data ?? DashboardMetrics.empty;
            final items = _buildEstados(m.porEstado);
            return _Section(
              title: 'Estado de Reservas',
              child: items.isEmpty
                  ? const _Empty('Aún no hay reservas registradas')
                  : _DonutChart(items: items),
            );
          },
        ),
        const SizedBox(height: 16),

        // Destinos más buscados (barras horizontales)
        _Section(
          title: 'Destinos Más Buscados',
          child: _HBars(
            data: MockData.searchesByDestination
                .map((d) => _BarItem(d.destination, d.searches.toDouble()))
                .toList(),
            color: AppColors.emerald500,
          ),
        ),
        const SizedBox(height: 16),

        // Evolución mensual (líneas)
        _Section(
          title: 'Reservas Mensuales',
          child: _LineChart(data: MockData.reservationsByMonth),
        ),
        const SizedBox(height: 16),

        // Distribución por precio (barras verticales)
        _Section(
          title: 'Distribución por Precio',
          child: _VBars(
            data: MockData.priceRangeDistribution
                .map((r) => _BarItem(r.label, r.count.toDouble()))
                .toList(),
            color: AppColors.purple600,
          ),
        ),
      ],
    );
  }

  List<_DonutItem> _buildEstados(Map<String, int> porEstado) {
    const colores = {
      'Solicitado': AppColors.amber500,
      'Aprobado': AppColors.blue600,
      'Pagado': AppColors.emerald500,
      'Disfrutado': AppColors.emerald800,
      'Cancelado': AppColors.red600,
    };
    final out = <_DonutItem>[];
    colores.forEach((estado, color) {
      final n = porEstado[estado] ?? 0;
      if (n > 0) out.add(_DonutItem(estado, n, color));
    });
    return out;
  }
}

// ── Widgets de layout ────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      );
}

class _Empty extends StatelessWidget {
  final String msg;
  const _Empty(this.msg);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
            child: Text(msg,
                style:
                    const TextStyle(color: AppColors.mutedForeground))),
      );
}

// ── KPI Card ────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _KpiCard(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.mutedForeground)),
              ],
            ),
          ],
        ),
      );
}

// ── Donut ────────────────────────────────────────────────────────────────────

class _DonutItem {
  final String label;
  final int value;
  final Color color;
  const _DonutItem(this.label, this.value, this.color);
}

class _DonutChart extends StatelessWidget {
  final List<_DonutItem> items;
  const _DonutChart({required this.items});

  @override
  Widget build(BuildContext context) {
    final total = items.fold(0, (s, i) => s + i.value);
    return Row(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(painter: _DonutPainter(items)),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map((it) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: it.color,
                              borderRadius: BorderRadius.circular(3)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('${it.label}: ${it.value}',
                              style: const TextStyle(fontSize: 12)),
                        ),
                        Text(
                          '${((it.value / total) * 100).round()}%',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedForeground),
                        ),
                      ]),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<_DonutItem> items;
  _DonutPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    final total = items.fold(0, (s, i) => s + i.value);
    if (total == 0) return;
    final stroke = size.width * 0.2;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    var angle = -math.pi / 2;
    for (final it in items) {
      final sweep = (it.value / total) * 2 * math.pi;
      canvas.drawArc(
        rect,
        angle,
        sweep - 0.04,
        false,
        Paint()
          ..color = it.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt,
      );
      angle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.items != items;
}

// ── Barras horizontales ──────────────────────────────────────────────────────

class _BarItem {
  final String label;
  final double value;
  const _BarItem(this.label, this.value);
}

class _HBars extends StatelessWidget {
  final List<_BarItem> data;
  final Color color;
  const _HBars({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    final maxV = data.fold(1.0, (m, i) => math.max(m, i.value));
    return Column(
      children: data
          .map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  SizedBox(
                    width: 90,
                    child: Text(b.label,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(children: [
                        Container(height: 18, color: AppColors.inputBackground),
                        FractionallySizedBox(
                          widthFactor: (b.value / maxV).clamp(0.02, 1.0),
                          child: Container(height: 18, color: color),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 32,
                    child: Text(b.value.round().toString(),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ))
          .toList(),
    );
  }
}

// ── Barras verticales ────────────────────────────────────────────────────────

class _VBars extends StatelessWidget {
  final List<_BarItem> data;
  final Color color;
  const _VBars({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    final maxV = data.fold(1.0, (m, i) => math.max(m, i.value));
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data
            .map((b) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(b.value.round().toString(),
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: (b.value / maxV).clamp(0.04, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(5)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(b.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ── Gráfica de líneas ────────────────────────────────────────────────────────

class _LineChart extends StatelessWidget {
  final List<MonthStat> data;
  const _LineChart({required this.data});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          SizedBox(
            height: 150,
            child: CustomPaint(
                painter: _LinePainter(data), size: Size.infinite),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data
                .map((m) => Text(m.month,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.mutedForeground)))
                .toList(),
          ),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            _Dot(color: AppColors.blue600, label: 'Reservas'),
            SizedBox(width: 16),
            _Dot(color: AppColors.emerald600, label: 'Ingresos'),
          ]),
        ],
      );
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.mutedForeground)),
        ],
      );
}

class _LinePainter extends CustomPainter {
  final List<MonthStat> data;
  _LinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxR =
        data.map((d) => d.reservations).fold(1, math.max).toDouble();
    final maxRev = data.map((d) => d.revenue).fold(1, math.max).toDouble();

    // Líneas de cuadrícula sutiles
    final gridPaint = Paint()
      ..color = const Color(0x0D000000)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    void drawLine(double Function(MonthStat) sel, double maxV, Color c) {
      final p = Paint()
        ..color = c
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final path = Path();
      final dots = Paint()..color = c;
      for (var i = 0; i < data.length; i++) {
        final dx = data.length == 1
            ? size.width / 2
            : size.width * i / (data.length - 1);
        final dy = size.height - (sel(data[i]) / maxV) * (size.height - 8) - 4;
        if (i == 0) path.moveTo(dx, dy); else path.lineTo(dx, dy);
        canvas.drawCircle(Offset(dx, dy), 3, dots);
      }
      canvas.drawPath(path, p);
    }

    drawLine((m) => m.reservations.toDouble(), maxR, AppColors.blue600);
    drawLine((m) => m.revenue.toDouble(), maxRev, AppColors.emerald600);
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.data != data;
}
