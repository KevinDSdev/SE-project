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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                            color: isDark
                                ? const Color(0xFF1E2818).withValues(alpha: 0.8)
                                : kColorLime.withValues(alpha: 0.16),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? kColorLime : const Color(0xFF8E95A3),
                      fontSize: 11,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? kColorLime : const Color(0xFF8E95A3),
                    fontSize: 11,
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
// 3. Donut Breakdown Chart (Large, high-visibility donut mode)
// -------------------------------------------------------------
class DonutBreakdownChart extends StatelessWidget {
  final double income;
  final double expenses;
  final double height;
  final Color primaryColor;
  final Color secondaryColor;
  final String primaryLabel;
  final String secondaryLabel;
  final String centerTitle;

  const DonutBreakdownChart({
    super.key,
    required this.income,
    required this.expenses,
    this.height = 200,
    this.primaryColor = kColorLime,
    this.secondaryColor = kColorRose,
    this.primaryLabel = 'Income Stream',
    this.secondaryLabel = 'Expense Outflow',
    this.centerTitle = 'Inflow',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppColors.getTextPrimary(isDark);
    final total = income + expenses == 0 ? 1.0 : income + expenses;
    final inRatio = (income / total).clamp(0.0, 1.0);
    final effectiveHeight = height < 195 ? 195.0 : height;
    final ringSize = (effectiveHeight - 28).clamp(145.0, 180.0);

    return SizedBox(
      height: effectiveHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CustomPaint(
                    painter: _LargeDonutPainter(
                      primaryRatio: inRatio,
                      primaryColor: primaryColor,
                      secondaryColor: secondaryColor,
                      strokeWidth: 22,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      centerTitle,
                      style: const TextStyle(
                        color: Color(0xFF8E95A3),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(inRatio * 100).round()}%',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _legendItem(
                  primaryLabel,
                  primaryColor,
                  'LKR ${NumberFormat('#,###').format(income.toInt())}',
                  textPrimary,
                ),
                const SizedBox(height: 16),
                _legendItem(
                  secondaryLabel,
                  secondaryColor,
                  'LKR ${NumberFormat('#,###').format(expenses.toInt())}',
                  textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(
    String label,
    Color color,
    String amount,
    Color textPrimary,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF8E95A3),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                amount,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LargeDonutPainter extends CustomPainter {
  final double primaryRatio;
  final Color primaryColor;
  final Color secondaryColor;
  final double strokeWidth;

  _LargeDonutPainter({
    required this.primaryRatio,
    required this.primaryColor,
    required this.secondaryColor,
    this.strokeWidth = 22,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final fgPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 6.2831853, false, bgPaint);
    if (primaryRatio > 0) {
      canvas.drawArc(
        rect,
        -1.5707963,
        6.2831853 * primaryRatio,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LargeDonutPainter oldDelegate) =>
      oldDelegate.primaryRatio != primaryRatio ||
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.secondaryColor != secondaryColor;
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

  static String _defaultCommaFormat(double v) =>
      NumberFormat('#,###').format(v.toInt());

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
              valueFormatter: valueFormatter ?? _defaultCommaFormat,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? lineColor : const Color(0xFFB0B7C3),
                    fontSize: 11,
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

    const double leftRightPad = 18;
    const double topPad = 28;
    const double btmPad = 8;
    final double chartHeight = size.height - topPad - btmPad;
    final double usableWidth = size.width - (leftRightPad * 2);
    final double stepX =
        values.length > 1 ? usableWidth / (values.length - 1) : 0;

    final List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final double normalized = (values[i] - minVal) / range;
      final double x = leftRightPad + (i * stepX);
      final double y =
          size.height - btmPad - 12 - (normalized * (chartHeight - 12));
      points.add(Offset(x, y));
    }

    // Area fill under curve
    final Path areaPath = Path();
    final double baselineY = size.height - 2;
    areaPath.moveTo(points.first.dx, baselineY);
    areaPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      areaPath.lineTo(p2.dx, p2.dy);
    }
    areaPath.lineTo(points.last.dx, baselineY);
    areaPath.close();

    final Paint areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.28),
          lineColor.withValues(alpha: 0.08),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(areaPath, areaPaint);

    // Subtle bottom axis line
    final Paint axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(4, baselineY),
      Offset(size.width - 4, baselineY),
      axisPaint,
    );

    // Straight/smooth connecting line
    final Path linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p2 = points[i + 1];
      linePath.lineTo(p2.dx, p2.dy);
    }

    final Paint linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // Nodes and labels
    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final isSelected = i == selectedIndex;

      if (isSelected) {
        final glowPaint = Paint()
          ..color = const Color(0xFF0C0F14)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pt, 6, glowPaint);

        final dotFill = Paint()
          ..color = lineColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pt, 4.5, dotFill);
      } else {
        final innerPaint = Paint()
          ..color = const Color(0xFF141820)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pt, 4.5, innerPaint);

        final ringPaint = Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2;
        canvas.drawCircle(pt, 4.5, ringPaint);
      }

      final label = valueFormatter(values[i]);
      if (label.isNotEmpty) {
        final textSpan = TextSpan(
          text: label,
          style: TextStyle(
            color: lineColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
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
          pt.dy - textPainter.height - 8,
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
  final Color? labelColor;
  final Color? selectedLabelColor;
  final Color? selectedMonthColor;
  final int selectedIndex;
  final double height;
  final String Function(double)? valueFormatter;

  const SingleCategoryBarChart({
    super.key,
    required this.months,
    required this.values,
    required this.barColor,
    this.alternateBarColor,
    this.labelColor,
    this.selectedLabelColor,
    this.selectedMonthColor,
    this.selectedIndex = 5,
    this.height = 150,
    this.valueFormatter,
  });

  static String _defaultCommaFormat(double v) =>
      NumberFormat('#,###').format(v.toInt());

  @override
  Widget build(BuildContext context) {
    double maxVal = 0;
    for (final v in values) {
      if (v > maxVal) maxVal = v;
    }
    if (maxVal == 0) maxVal = 1;

    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(months.length, (index) {
                final val = values[index];
                final isSelected = index == selectedIndex;
                final barH = (val / maxVal) * (height - 62);

                final color = isSelected
                    ? (alternateBarColor ?? barColor)
                    : barColor;

                final topTextColor = isSelected
                    ? (selectedLabelColor ?? alternateBarColor ?? barColor)
                    : (labelColor ?? barColor);

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        (valueFormatter ?? _defaultCommaFormat)(val),
                        style: TextStyle(
                          color: topTextColor,
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 30,
                        height: barH.clamp(12, height - 62),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(months.length, (index) {
              final month = months[index];
              final isSelected = index == selectedIndex;
              final mColor = isSelected
                  ? (selectedMonthColor ??
                      alternateBarColor ??
                      barColor)
                  : const Color(0xFFB0B7C3);
              return Expanded(
                child: Center(
                  child: Text(
                    month,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: mColor,
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ],
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

  static String _defaultCommaFormat(double v) =>
      NumberFormat('#,###').format(v.toInt());

  @override
  Widget build(BuildContext context) {
    final fmt = valueFormatter ?? _defaultCommaFormat;
    switch (mode) {
      case ChartVisualMode.bar:
        return SingleCategoryBarChart(
          months: labels,
          values: values,
          barColor: color,
          selectedIndex: selectedIndex,
          height: height,
          valueFormatter: fmt,
        );
      case ChartVisualMode.donut:
        final total = values.fold<double>(0, (a, b) => a + b);
        final latest = values.isNotEmpty
            ? values[selectedIndex.clamp(0, values.length - 1)]
            : 0.0;
        final latestLabel = labels.isNotEmpty
            ? labels[selectedIndex.clamp(0, labels.length - 1)]
            : 'Current';
        return DonutBreakdownChart(
          income: latest,
          expenses: (total - latest).clamp(0, double.infinity),
          primaryColor: color,
          secondaryColor: color.withValues(alpha: 0.25),
          primaryLabel: '$latestLabel Period',
          secondaryLabel: 'Prior 5 Months',
          centerTitle: latestLabel,
          height: 205,
        );
      case ChartVisualMode.line:
        return CurvedTrendLineChart(
          labels: labels,
          values: values,
          lineColor: color,
          selectedIndex: selectedIndex,
          height: height,
          valueFormatter: fmt,
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
  final Color? labelColor;
  final Color? selectedLabelColor;
  final Color? selectedMonthColor;
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
    this.labelColor,
    this.selectedLabelColor,
    this.selectedMonthColor,
    this.selectedIndex = 5,
    this.height = 150,
    this.valueFormatter,
  });

  static String _defaultCommaFormat(double v) =>
      NumberFormat('#,###').format(v.toInt());

  @override
  Widget build(BuildContext context) {
    final fmt = valueFormatter ?? _defaultCommaFormat;
    switch (mode) {
      case ChartVisualMode.line:
        return CurvedTrendLineChart(
          labels: months,
          values: values,
          lineColor: barColor,
          selectedIndex: selectedIndex,
          height: height,
          valueFormatter: fmt,
        );
      case ChartVisualMode.donut:
        final total = values.fold<double>(0, (a, b) => a + b);
        final latest = values.isNotEmpty
            ? values[selectedIndex.clamp(0, values.length - 1)]
            : 0.0;
        final latestMonth = months.isNotEmpty
            ? months[selectedIndex.clamp(0, months.length - 1)]
            : 'Selected';
        return DonutBreakdownChart(
          income: latest,
          expenses: (total - latest).clamp(0, double.infinity),
          primaryColor: alternateBarColor ?? barColor,
          secondaryColor: barColor.withValues(alpha: 0.25),
          primaryLabel: '$latestMonth Share',
          secondaryLabel: 'Other Months',
          centerTitle: latestMonth,
          height: 205,
        );
      case ChartVisualMode.bar:
        return SingleCategoryBarChart(
          months: months,
          values: values,
          barColor: barColor,
          alternateBarColor: alternateBarColor,
          labelColor: labelColor,
          selectedLabelColor: selectedLabelColor,
          selectedMonthColor: selectedMonthColor,
          selectedIndex: selectedIndex,
          height: height,
          valueFormatter: fmt,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppColors.getTextPrimary(isDark);
    final axisColor =
        isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08);
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
            width: 34,
            height: height - 38,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: yAxisLabels.reversed
                  .map(
                    (lbl) => Text(
                      lbl,
                      style: const TextStyle(
                        color: Color(0xFFB0B7C3),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(months.length, (index) {
                      final val = values[index];
                      final isForecast = index == months.length - 1;
                      final Color barCol =
                          isForecast ? forecastColor : kColorSky;

                      // Exaggerate relative differences slightly for visual match with design
                      final double minVal =
                          values.reduce((a, b) => a < b ? a : b) * 0.72;
                      final double norm =
                          ((val - minVal) / (maxVal - minVal)).clamp(0.35, 1.0);
                      final barH = norm * (height - 62);

                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              NumberFormat('#,###').format(val.toInt()),
                              style: TextStyle(
                                color: isForecast ? forecastColor : textPrimary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 30,
                              height: barH.clamp(24, height - 62),
                              decoration: BoxDecoration(
                                color: barCol,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                Container(
                  height: 1,
                  color: axisColor,
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(months.length, (index) {
                    final month = months[index];
                    final isForecast = index == months.length - 1;
                    return Expanded(
                      child: Center(
                        child: Text(
                          month,
                          style: TextStyle(
                            color: isForecast
                                ? forecastColor
                                : const Color(0xFFB0B7C3),
                            fontSize: 12,
                            fontWeight:
                                isForecast ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.getTextPrimary(isDark),
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
                  child: Container(color: AppColors.getBorder(isDark)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: _buildItem(
            isDark: isDark,
            mode: ChartVisualMode.bar,
            title: 'Bar Graph',
            iconWidget: const Icon(
              Icons.bar_chart_rounded,
              color: kColorLime,
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildItem(
            isDark: isDark,
            mode: ChartVisualMode.line,
            title: 'Line Trend',
            iconWidget: const Icon(
              Icons.show_chart_rounded,
              color: kColorSky,
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildItem(
            isDark: isDark,
            mode: ChartVisualMode.donut,
            title: 'Donut Ring',
            iconWidget: SizedBox(
              width: 22,
              height: 22,
              child: CustomPaint(
                painter: _TwoToneDonutIconPainter(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem({
    required bool isDark,
    required ChartVisualMode mode,
    required String title,
    required Widget iconWidget,
  }) {
    final isSelected = selected == mode;
    final unselectedBg =
        isDark ? const Color(0xFF1E222D) : const Color(0xFFF1F5F9);
    final unselectedBorder =
        isDark ? const Color(0xFF2B303E) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return GestureDetector(
      onTap: () => onSelected(mode),
      child: Container(
        height: 86,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.18)
              : unselectedBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : unselectedBorder,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                iconWidget,
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: activeColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Color(0xFF0C0F14),
                      size: 11,
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

class _TwoToneDonutIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    final purplePaint = Paint()
      ..color = const Color(0xFFB088F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2;
    final greenPaint = Paint()
      ..color = kColorLime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 6.28318, false, purplePaint);
    canvas.drawArc(rect, -1.57, 2.2, false, greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
