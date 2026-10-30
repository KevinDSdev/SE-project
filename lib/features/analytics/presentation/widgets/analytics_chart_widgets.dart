import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../core/constants/app_colors.dart';
import '../../providers/analytics_provider.dart';

// Exact Palette
const Color kColorLime = Color(0xFF98E836);
const Color kColorRose = Color(0xFFF43F5E);
const Color kColorSky = Color(0xFF38BDF8);
const Color kColorPurple = Color(0xFF9353D3);
const Color kColorAmber = Color(0xFFF59E0B);

// -------------------------------------------------------------
// 1. Grouped Dual Bar Chart (Income & Expenses comparison)
// -------------------------------------------------------------
class GroupedDualBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;
  final int selectedIndex;
  final ValueChanged<int>? onSelectMonth;
  final double height;

  const GroupedDualBarChart({
    super.key,
    required this.monthlyData,
    this.selectedIndex = 5,
    this.onSelectMonth,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    double maxVal = 0;
    for (final m in monthlyData) {
      final inc = (m['income'] as num).toDouble();
      final exp = (m['expense'] as num).toDouble();
      if (inc > maxVal) maxVal = inc;
      if (exp > maxVal) maxVal = exp;
    }
    if (maxVal == 0) maxVal = 1;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(monthlyData.length, (index) {
          final item = monthlyData[index];
          final month = item['month'] as String;
          final inc = (item['income'] as num).toDouble();
          final exp = (item['expense'] as num).toDouble();
          final isSelected = index == selectedIndex;

          final inBarHeight = (inc / maxVal) * (height - 38);
          final expBarHeight = (exp / maxVal) * (height - 38);

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelectMonth?.call(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: const Color(0xFF1E2818).withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: kColorLime.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          )
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Income bar (green)
                        Container(
                          width: 12,
                          height: inBarHeight.clamp(8, height - 38),
                          decoration: BoxDecoration(
                            color: kColorLime,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Expense bar (red/pink)
                        Container(
                          width: 12,
                          height: expBarHeight.clamp(8, height - 38),
                          decoration: BoxDecoration(
                            color: kColorRose,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    month,
                    style: TextStyle(
                      color: isSelected ? kColorLime : const Color(0xFF8E95A3),
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// -------------------------------------------------------------
// 2. Dual Trend Line Chart (Main dashboard line mode)
// -------------------------------------------------------------
class DualTrendLineChart extends StatelessWidget {
  final List<String> labels;
  final List<double> incomeValues;
  final List<double> expenseValues;
  final int selectedIndex;
  final double height;

  const DualTrendLineChart({
    super.key,
    required this.labels,
    required this.incomeValues,
    required this.expenseValues,
    this.selectedIndex = 5,
    this.height = 155,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: height - 24,
          width: double.infinity,
          child: CustomPaint(
            painter: _DualLinePainter(
              incomeValues: incomeValues,
              expenseValues: expenseValues,
              selectedIndex: selectedIndex,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(labels.length, (index) {
            final isSelected = index == selectedIndex;
            return Expanded(
              child: Center(
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: isSelected ? kColorLime : const Color(0xFF8E95A3),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _DualLinePainter extends CustomPainter {
  final List<double> incomeValues;
  final List<double> expenseValues;
  final int selectedIndex;

  _DualLinePainter({
    required this.incomeValues,
    required this.expenseValues,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double maxVal = 0;
    for (final v in [...incomeValues, ...expenseValues]) {
      if (v > maxVal) maxVal = v;
    }
    if (maxVal == 0) maxVal = 1;

    const double topPad = 12;
    const double btmPad = 10;
    final double h = size.height - topPad - btmPad;
    final double stepX = size.width / (incomeValues.length - 1);

    _drawLine(canvas, size, incomeValues, maxVal, stepX, h, btmPad, kColorLime);
    _drawLine(canvas, size, expenseValues, maxVal, stepX, h, btmPad, kColorRose);
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<double> values,
    double maxVal,
    double stepX,
    double h,
    double btmPad,
    Color color,
  ) {
    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - btmPad - ((values[i] / maxVal) * h);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = size.height - btmPad - ((values[i - 1] / maxVal) * h);
        path.cubicTo((prevX + x) / 2, prevY, (prevX + x) / 2, y, x, y);
      }
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// -------------------------------------------------------------
// 3. Donut Breakdown Chart (Main dashboard donut mode)
// -------------------------------------------------------------
class DonutBreakdownChart extends StatelessWidget {
  final double income;
  final double expenses;
  final double height;

  const DonutBreakdownChart({
    super.key,
    required this.income,
    required this.expenses,
    this.height = 155,
  });

  @override
  Widget build(BuildContext context) {
    final total = income + expenses == 0 ? 1.0 : income + expenses;
    final inRatio = income / total;

    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: height - 36,
            height: height - 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 14,
                  color: kColorRose,
                ),
                CircularProgressIndicator(
                  value: inRatio,
                  strokeWidth: 14,
                  color: kColorLime,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Inflow',
                        style:
                            TextStyle(color: Color(0xFF8E95A3), fontSize: 10)),
                    Text(
                      '${(inRatio * 100).toInt()}%',
                      style: const TextStyle(
                          color: kColorLime,
                          fontSize: 15,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _legendItem('Income Stream', kColorLime,
                  'LKR ${NumberFormat('#,###').format(income.toInt())}'),
              const SizedBox(height: 12),
              _legendItem('Expense Outflow', kColorRose,
                  'LKR ${NumberFormat('#,###').format(expenses.toInt())}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, String amount) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(color: Color(0xFF8E95A3), fontSize: 11)),
            Text(amount,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// 4. Curved Trend Line Chart (with area glow, nodes, values)
// -------------------------------------------------------------
class CurvedTrendLineChart extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final Color lineColor;
  final int selectedIndex;
  final double height;
  final String Function(double)? valueFormatter;

  const CurvedTrendLineChart({
    super.key,
    required this.labels,
    required this.values,
    required this.lineColor,
    this.selectedIndex = 5,
    this.height = 140,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _CurvedLinePainter(
              values: values,
              lineColor: lineColor,
              selectedIndex: selectedIndex,
              valueFormatter: valueFormatter ?? (v) => v.toInt().toString(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(labels.length, (index) {
            final isSelected = index == selectedIndex;
            return Expanded(
              child: Center(
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: isSelected ? lineColor : const Color(0xFF8E95A3),
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CurvedLinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final int selectedIndex;
  final String Function(double) valueFormatter;

  _CurvedLinePainter({
    required this.values,
    required this.lineColor,
    required this.selectedIndex,
    required this.valueFormatter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final double minVal = values.reduce((a, b) => a < b ? a : b);
    final double maxVal = values.reduce((a, b) => a > b ? a : b);
    final double range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);

    const double topPad = 26;
    const double btmPad = 12;
    final double chartHeight = size.height - topPad - btmPad;
    final double stepX = size.width / (values.length - 1);

    final List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final double normalized = (values[i] - minVal) / range;
      final double x = i * stepX;
      final double y = size.height - btmPad - (normalized * chartHeight);
      points.add(Offset(x, y));
    }

    // Area gradient
    final Path areaPath = Path();
    areaPath.moveTo(points.first.dx, size.height);
    areaPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final cpx = (p1.dx + p2.dx) / 2;
      areaPath.cubicTo(cpx, p1.dy, cpx, p2.dy, p2.dx, p2.dy);
    }
    areaPath.lineTo(points.last.dx, size.height);
    areaPath.close();

    final Paint areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.35),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(areaPath, areaPaint);

    // Smooth curve
    final Path linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final cpx = (p1.dx + p2.dx) / 2;
      linePath.cubicTo(cpx, p1.dy, cpx, p2.dy, p2.dx, p2.dy);
    }

    final Paint linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Nodes and labels
    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final isSelected = i == selectedIndex;

      if (isSelected) {
        final glowPaint = Paint()
          ..color = lineColor.withValues(alpha: 0.4)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pt, 8, glowPaint);
      }

      final dotPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pt, isSelected ? 4.5 : 3.5, dotPaint);

      final innerPaint = Paint()
        ..color = const Color(0xFF0C0F14)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pt, isSelected ? 2.5 : 1.8, innerPaint);

      final label = valueFormatter(values[i]);
      if (label.isNotEmpty) {
        final textSpan = TextSpan(
          text: label,
          style: TextStyle(
            color: isSelected ? lineColor : const Color(0xFF8E95A3),
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout();

        final textOffset = Offset(
          (pt.dx - textPainter.width / 2)
              .clamp(0, size.width - textPainter.width),
          pt.dy - textPainter.height - 6,
        );
        textPainter.paint(canvas, textOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CurvedLinePainter oldDelegate) => true;
}

// -------------------------------------------------------------
// 5. Single Category Monthly Bar Chart
// -------------------------------------------------------------
class SingleCategoryBarChart extends StatelessWidget {
  final List<String> months;
  final List<double> values;
  final Color barColor;
  final Color? alternateBarColor;
  final int selectedIndex;
  final double height;
  final String Function(double)? valueFormatter;

  const SingleCategoryBarChart({
    super.key,
    required this.months,
    required this.values,
    required this.barColor,
    this.alternateBarColor,
    this.selectedIndex = 5,
    this.height = 140,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    double maxVal = 0;
    for (final v in values) {
      if (v > maxVal) maxVal = v;
    }
    if (maxVal == 0) maxVal = 1;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(months.length, (index) {
          final month = months[index];
          final val = values[index];
          final isSelected = index == selectedIndex;
          final barH = (val / maxVal) * (height - 54);

          final color = (alternateBarColor != null && !isSelected)
              ? alternateBarColor!
              : barColor;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  valueFormatter?.call(val) ??
                      (val >= 1000
                          ? '${(val / 1000).toStringAsFixed(0)}k'
                          : val.toInt().toString()),
                  style: TextStyle(
                    color: isSelected ? barColor : const Color(0xFF8E95A3),
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 22,
                  height: barH.clamp(8, height - 54),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  month,
                  style: TextStyle(
                    color: isSelected ? barColor : const Color(0xFF8E95A3),
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// -------------------------------------------------------------
// Adaptive Trend and Category Charts (Dynamic Visual Modes)
// -------------------------------------------------------------
class AdaptiveTrendChart extends StatelessWidget {
  final ChartVisualMode mode;
  final List<String> labels;
  final List<double> values;
  final Color color;
  final int selectedIndex;
  final String Function(double)? valueFormatter;
  final double height;

  const AdaptiveTrendChart({
    super.key,
    required this.mode,
    required this.labels,
    required this.values,
    required this.color,
    this.selectedIndex = 5,
    this.valueFormatter,
    this.height = 145,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case ChartVisualMode.bar:
        return SingleCategoryBarChart(
          months: labels,
          values: values,
          barColor: color,
          selectedIndex: selectedIndex,
          height: height,
          valueFormatter: valueFormatter,
        );
      case ChartVisualMode.donut:
        final total = values.fold<double>(0, (a, b) => a + b);
        final latest = values.isNotEmpty
            ? values[selectedIndex.clamp(0, values.length - 1)]
            : 0.0;
        return DonutBreakdownChart(
          income: latest,
          expenses: (total - latest).clamp(0, double.infinity),
          height: height,
        );
      case ChartVisualMode.line:
        return CurvedTrendLineChart(
          labels: labels,
          values: values,
          lineColor: color,
          selectedIndex: selectedIndex,
          height: height,
          valueFormatter: valueFormatter ?? (v) => v.toInt().toString(),
        );
    }
  }
}

class AdaptiveCategoryChart extends StatelessWidget {
  final ChartVisualMode mode;
  final List<String> months;
  final List<double> values;
  final Color barColor;
  final Color? alternateBarColor;
  final int selectedIndex;
  final double height;
  final String Function(double)? valueFormatter;

  const AdaptiveCategoryChart({
    super.key,
    required this.mode,
    required this.months,
    required this.values,
    required this.barColor,
    this.alternateBarColor,
    this.selectedIndex = 5,
    this.height = 145,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case ChartVisualMode.line:
        return CurvedTrendLineChart(
          labels: months,
          values: values,
          lineColor: barColor,
          selectedIndex: selectedIndex,
          height: height,
          valueFormatter: valueFormatter ?? (v) => v.toInt().toString(),
        );
      case ChartVisualMode.donut:
        final total = values.fold<double>(0, (a, b) => a + b);
        final latest = values.isNotEmpty
            ? values[selectedIndex.clamp(0, values.length - 1)]
            : 0.0;
        return DonutBreakdownChart(
          income: latest,
          expenses: (total - latest).clamp(0, double.infinity),
          height: height,
        );
      case ChartVisualMode.bar:
        return SingleCategoryBarChart(
          months: months,
          values: values,
          barColor: barColor,
          alternateBarColor: alternateBarColor,
          selectedIndex: selectedIndex,
          height: height,
          valueFormatter: valueFormatter,
        );
    }
  }
}

// -------------------------------------------------------------
// 6. Prediction Bar Chart (Past 5 Months vs. Forecast)
// -------------------------------------------------------------
class PredictionBarChartWidget extends StatelessWidget {
  final List<String> months;
  final List<double> values;
  final List<String> yAxisLabels;
  final Color forecastColor;
  final double height;

  const PredictionBarChartWidget({
    super.key,
    required this.months,
    required this.values,
    required this.yAxisLabels,
    required this.forecastColor,
    this.height = 190,
  });

  @override
  Widget build(BuildContext context) {
    double maxVal = 0;
    for (final v in values) {
      if (v > maxVal) maxVal = v;
    }
    if (maxVal == 0) maxVal = 1;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            height: height - 28,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: yAxisLabels.reversed
                  .map(
                    (lbl) => Text(
                      lbl,
                      style: const TextStyle(
                        color: Color(0xFF8E95A3),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(months.length, (index) {
                final month = months[index];
                final val = values[index];
                final isForecast = index == months.length - 1;
                final isCurrentActual = index == 3; // Sep

                Color barCol;
                if (isForecast) {
                  barCol = forecastColor;
                } else if (isCurrentActual) {
                  barCol = kColorSky;
                } else {
                  barCol = const Color(0xFF1E3547);
                }

                final barH = (val / maxVal) * (height - 52);

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        val >= 1000
                            ? '${(val / 1000).toStringAsFixed(0)},000'
                            : val.toInt().toString(),
                        style: TextStyle(
                          color: isForecast
                              ? forecastColor
                              : (isCurrentActual
                                  ? kColorSky
                                  : Colors.white),
                          fontSize: 10,
                          fontWeight: isForecast || isCurrentActual
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 24,
                        height: barH.clamp(10, height - 52),
                        decoration: BoxDecoration(
                          color: barCol,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        month,
                        style: TextStyle(
                          color: isForecast
                              ? forecastColor
                              : (isCurrentActual
                                  ? kColorSky
                                  : const Color(0xFF8E95A3)),
                          fontSize: 12,
                          fontWeight: isForecast || isCurrentActual
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 7. Anomaly Comparison Bar (Baseline Avg vs. Spike)
// -------------------------------------------------------------
class AnomalyComparisonBar extends StatelessWidget {
  final String label;
  final double avgAmount;
  final double spikeAmount;
  final String displayAmount;
  final bool hasSpike;

  const AnomalyComparisonBar({
    super.key,
    String? label,
    String? category,
    double? avgAmount,
    double? baseline,
    double? spikeAmount,
    double? actual,
    String? displayAmount,
    String? baselineLabel,
    String? actualLabel,
    bool? hasSpike,
  })  : label = label ?? category ?? '',
        avgAmount = avgAmount ?? baseline ?? 0.0,
        spikeAmount = spikeAmount ?? ((actual ?? 0.0) - (baseline ?? 0.0)),
        displayAmount = displayAmount ?? actualLabel ?? '',
        hasSpike = hasSpike ?? ((actual ?? 0.0) > (baseline ?? 0.0));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              displayAmount,
              style: TextStyle(
                color: hasSpike ? kColorRose : kColorSky,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                Expanded(
                  flex: (avgAmount * 10).toInt().clamp(1, 1000000),
                  child: Container(color: kColorSky),
                ),
                if (hasSpike && spikeAmount > 0) ...[
                  Expanded(
                    flex: (spikeAmount * 10).toInt().clamp(1, 1000000),
                    child: Container(color: kColorRose),
                  ),
                ],
                Expanded(
                  flex: ((100000 - (avgAmount + (hasSpike ? spikeAmount : 0))) * 10)
                      .clamp(0, 1000000)
                      .toInt(),
                  child: Container(color: AppColors.lightBorder),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// 8. Chart Style Selector Card (Bar Graph, Line Trend, Donut Ring)
// -------------------------------------------------------------
class ChartStylePicker extends StatelessWidget {
  final ChartVisualMode selected;
  final ValueChanged<ChartVisualMode> onSelected;
  final Color activeColor;

  const ChartStylePicker({
    super.key,
    required this.selected,
    required this.onSelected,
    this.activeColor = kColorLime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildItem(
            mode: ChartVisualMode.bar,
            title: 'Bar Graph',
            icon: Icons.bar_chart_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildItem(
            mode: ChartVisualMode.line,
            title: 'Line Trend',
            icon: Icons.show_chart_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildItem(
            mode: ChartVisualMode.donut,
            title: 'Donut Ring',
            icon: Icons.donut_large_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildItem({
    required ChartVisualMode mode,
    required String title,
    required IconData icon,
  }) {
    final isSelected = selected == mode;

    return GestureDetector(
      onTap: () => onSelected(mode),
      child: Container(
        height: 86,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.12)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: isSelected ? activeColor : kColorPurple,
                  size: 26,
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: activeColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Color(0xFF0C0F14),
                      size: 13,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
