import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'data/mock_data.dart';
import 'theme/app_theme.dart';

/// Dashboard de Tendencias: métricas + gráficos (barras, dona, líneas).
class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        const Text('Dashboard de Tendencias',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Panel administrativo con métricas y visualizaciones',
            style: TextStyle(color: AppColors.mutedForeground)),
        const SizedBox(height: 20),

        // KPIs.
        _KpiWrap(children: const [
          _Kpi(
              icon: Icons.attach_money,
              value: '\$682',
              label: 'Ingresos Totales',
              color: AppColors.emerald600,
              bg: AppColors.emerald50),
          _Kpi(
              icon: Icons.trending_up,
              value: '5',
              label: 'Reservas',
              color: AppColors.blue600,
              bg: AppColors.blue50),
          _Kpi(
              icon: Icons.groups_outlined,
              value: '12',
              label: 'Huéspedes',
              color: AppColors.purple600,
              bg: AppColors.purple50),
          _Kpi(
              icon: Icons.place_outlined,
              value: '6',
              label: 'Destinos',
              color: AppColors.amber600,
              bg: Color(0xFFFFFBEB)),
        ]),
        const SizedBox(height: 16),

        _ChartCard(
          title: 'Destinos Más Buscados',
          child: _HorizontalBars(
            data: [
              for (final d in MockData.searchesByDestination)
                MapEntry(d.destination, d.searches.toDouble())
            ],
            color: AppColors.emerald500,
          ),
        ),
        const SizedBox(height: 16),

        _ChartCard(
          title: 'Reservas e Ingresos Mensuales',
          child: _MonthlyLineChart(data: MockData.reservationsByMonth),
        ),
        const SizedBox(height: 16),

        _ChartCard(
          title: 'Distribución por Rango de Precio',
          child: _VerticalBars(
            data: [
              for (final r in MockData.priceRangeDistribution)
                MapEntry(r.label, r.count.toDouble())
            ],
            color: AppColors.purple600,
          ),
        ),
        const SizedBox(height: 16),

        _ChartCard(
          title: 'Estado de Reservas',
          child: _DonutWithLegend(data: MockData.statusDistribution),
        ),
        const SizedBox(height: 16),

        _ChartCard(
          title: 'Presupuesto Promedio por Destino',
          child: _BudgetTable(data: MockData.searchesByDestination),
        ),
      ],
    );
  }
}

// ===================== Layout helpers =====================

class _KpiWrap extends StatelessWidget {
  final List<Widget> children;
  const _KpiWrap({required this.children});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 820 ? 4 : 2;
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

class _Kpi extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color bg;
  const _Kpi({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.bg,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ===================== Charts =====================

class _HorizontalBars extends StatelessWidget {
  final List<MapEntry<String, double>> data;
  final Color color;
  const _HorizontalBars({required this.data, required this.color});
  @override
  Widget build(BuildContext context) {
    final maxV =
        data.map((e) => e.value).fold<double>(1, (a, b) => math.max(a, b));
    return Column(
      children: data
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(e.key,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.inputBackground,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: (e.value / maxV).clamp(0.02, 1.0),
                            child: Container(
                              height: 22,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 44,
                      child: Text(e.value.round().toString(),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _VerticalBars extends StatelessWidget {
  final List<MapEntry<String, double>> data;
  final Color color;
  const _VerticalBars({required this.data, required this.color});
  @override
  Widget build(BuildContext context) {
    final maxV =
        data.map((e) => e.value).fold<double>(1, (a, b) => math.max(a, b));
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data
            .map((e) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(e.value.round().toString(),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 150,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor:
                                  (e.value / maxV).clamp(0.02, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(e.key,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 10,
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

class _MonthlyLineChart extends StatelessWidget {
  final List<MonthStat> data;
  const _MonthlyLineChart({required this.data});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: CustomPaint(
            painter: _LinePainter(data),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: data
              .map((m) => Text(m.month,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.mutedForeground)))
              .toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _LegendDot(color: AppColors.blue600, label: 'Reservas'),
            SizedBox(width: 16),
            _LegendDot(color: AppColors.emerald600, label: 'Ingresos (\$)'),
          ],
        ),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<MonthStat> data;
  _LinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxRes = data
        .map((d) => d.reservations)
        .fold<int>(1, (a, b) => math.max(a, b))
        .toDouble();
    final maxRev = data
        .map((d) => d.revenue)
        .fold<int>(1, (a, b) => math.max(a, b))
        .toDouble();

    final grid = Paint()
      ..color = const Color(0x14000000)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    Offset pointFor(int i, double value, double maxV) {
      final dx = data.length == 1
          ? size.width / 2
          : size.width * i / (data.length - 1);
      final dy = size.height - (value / maxV) * (size.height - 8) - 4;
      return Offset(dx, dy);
    }

    void drawSeries(double Function(MonthStat) sel, double maxV, Color c) {
      final paint = Paint()
        ..color = c
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final path = Path();
      final dotPaint = Paint()..color = c;
      for (var i = 0; i < data.length; i++) {
        final p = pointFor(i, sel(data[i]), maxV);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, paint);
      for (var i = 0; i < data.length; i++) {
        final p = pointFor(i, sel(data[i]), maxV);
        canvas.drawCircle(p, 3.5, dotPaint);
      }
    }

    drawSeries((m) => m.reservations.toDouble(), maxRes,
        const Color(0xFF2563EB));
    drawSeries((m) => m.revenue.toDouble(), maxRev, const Color(0xFF059669));
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) =>
      oldDelegate.data != data;
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.mutedForeground)),
      ],
    );
  }
}

class _DonutWithLegend extends StatelessWidget {
  final List<StatusCount> data;
  const _DonutWithLegend({required this.data});
  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (a, b) => a + b.count);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: CustomPaint(painter: _DonutPainter(data)),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data
                .map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                                color: Color(s.colorValue),
                                borderRadius: BorderRadius.circular(3)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('${s.status}: ${s.count}',
                                style: const TextStyle(fontSize: 13)),
                          ),
                          Text(
                              total == 0
                                  ? '0%'
                                  : '${((s.count / total) * 100).round()}%',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mutedForeground)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<StatusCount> data;
  _DonutPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.fold<int>(0, (a, b) => a + b.count);
    if (total == 0) return;
    final rect = Offset.zero & size;
    final stroke = size.width * 0.22;
    final inner = rect.deflate(stroke / 2);
    var start = -math.pi / 2;
    for (final s in data) {
      final sweep = (s.count / total) * 2 * math.pi;
      final paint = Paint()
        ..color = Color(s.colorValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke;
      canvas.drawArc(inner, start, sweep - 0.03, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.data != data;
}

class _BudgetTable extends StatelessWidget {
  final List<DestinationStat> data;
  const _BudgetTable({required this.data});
  @override
  Widget build(BuildContext context) {
    final maxBudget =
        data.map((d) => d.avgBudget).fold<int>(1, (a, b) => math.max(a, b));
    return Column(
      children: [
        Row(
          children: const [
            Expanded(
                flex: 3,
                child: Text('Destino',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700))),
            Expanded(
                flex: 2,
                child: Text('Búsquedas',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700))),
            Expanded(
                flex: 3,
                child: Text('Presupuesto Prom.',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700))),
          ],
        ),
        const Divider(height: 18),
        ...data.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Text(d.destination,
                          style: const TextStyle(fontSize: 13))),
                  Expanded(
                      flex: 2,
                      child: Text(d.searches.toString(),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 13))),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Text('\$${d.avgBudget}/n',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.emerald700)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                    color: AppColors.inputBackground,
                                    borderRadius:
                                        BorderRadius.circular(4)),
                              ),
                              FractionallySizedBox(
                                widthFactor:
                                    (d.avgBudget / maxBudget).clamp(0.05, 1),
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                      color: AppColors.emerald500,
                                      borderRadius:
                                          BorderRadius.circular(4)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
