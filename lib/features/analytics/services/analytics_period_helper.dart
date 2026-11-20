import 'package:intl/intl.dart';

import '../providers/analytics_provider.dart';

/// Represents a distinct time slice/bucket for analytics aggregation and
/// chart rendering.
class PeriodBucket {
  /// Short label for chart X-axis labels to avoid text overlap (e.g. 'Nov 1–7',
  /// 'May', '2026', 'W1').
  final String label;

  /// User-facing descriptive label (e.g. 'Week 1 – November 1–7',
  /// 'October 2026', '2026').
  final String fullLabel;

  /// Badge label for screen status pills (e.g. 'Week - Nov 1–7',
  /// 'Month - October', 'Year - 2026').
  final String badgeLabel;

  final DateTime startDate;
  final DateTime endDate;

  const PeriodBucket({
    required this.label,
    required this.fullLabel,
    required this.badgeLabel,
    required this.startDate,
    required this.endDate,
  });

  @override
  String toString() =>
      'PeriodBucket(label: $label, fullLabel: $fullLabel, start: $startDate, end: $endDate)';
}

/// Shared date-range and period-bucket calculation helper for all analytics
/// screens, handling leap years, variable month lengths, and month/year boundaries.
class AnalyticsPeriodHelper {
  /// Default period selected by default across FinPulse.
  static const AnalyticsPeriod defaultPeriod = AnalyticsPeriod.monthly;

  /// Baseline anchor date representing the project sprint dataset (Nov 2026).
  static final DateTime defaultAnchor = DateTime(2026, 11, 20);

  /// Available period options.
  static const List<AnalyticsPeriod> periodOptions = [
    AnalyticsPeriod.weekly,
    AnalyticsPeriod.monthly,
    AnalyticsPeriod.yearly,
  ];

  /// Returns period option names (e.g. ['Weekly', 'Monthly', 'Yearly']).
  static List<String> getPeriodOptions() {
    return const ['Weekly', 'Monthly', 'Yearly'];
  }

  /// Returns formatted period option labels (e.g. ['Weekly : 2026', ...]).
  static List<String> getPeriodOptionLabels([DateTime? referenceDate]) {
    return periodOptions
        .map((p) => getPeriodTypeLabel(p, referenceDate))
        .toList();
  }

  /// Dynamically computes the 4 week segments for the current month:
  /// - Week 1: day 1 through day 7.
  /// - Week 2: day 8 through day 14.
  /// - Week 3: day 15 through day 21.
  /// - Week 4: day 22 through the last day of the month (handling leap years).
  static List<PeriodBucket> getWeeklyBuckets([DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime.now();
    final year = now.year;
    final month = now.month;
    final lastDay = DateTime(year, month + 1, 0).day;
    final monthName = DateFormat('MMMM').format(now);
    final shortMonth = DateFormat('MMM').format(now);

    return [
      PeriodBucket(
        label: '$shortMonth 1–7',
        fullLabel: 'Week 1 – $monthName 1–7',
        badgeLabel: 'Week - $shortMonth 1–7',
        startDate: DateTime(year, month, 1),
        endDate: DateTime(year, month, 7, 23, 59, 59),
      ),
      PeriodBucket(
        label: '$shortMonth 8–14',
        fullLabel: 'Week 2 – $monthName 8–14',
        badgeLabel: 'Week - $shortMonth 8–14',
        startDate: DateTime(year, month, 8),
        endDate: DateTime(year, month, 14, 23, 59, 59),
      ),
      PeriodBucket(
        label: '$shortMonth 15–21',
        fullLabel: 'Week 3 – $monthName 15–21',
        badgeLabel: 'Week - $shortMonth 15–21',
        startDate: DateTime(year, month, 15),
        endDate: DateTime(year, month, 21, 23, 59, 59),
      ),
      PeriodBucket(
        label: '$shortMonth 22–$lastDay',
        fullLabel: 'Week 4 – $monthName 22–$lastDay',
        badgeLabel: 'Week - $shortMonth 22–$lastDay',
        startDate: DateTime(year, month, 22),
        endDate: DateTime(year, month, lastDay, 23, 59, 59),
      ),
    ];
  }

  /// Alias for [getWeeklyBuckets] representing 4 monthly week segments.
  static List<PeriodBucket> getFourWeekSegments([DateTime? referenceDate]) =>
      getWeeklyBuckets(referenceDate);

  /// Computes a rolling list of 6 consecutive calendar weeks ending at [referenceDate].
  static List<PeriodBucket> getSixWeekBuckets([DateTime? referenceDate]) {
    final anchor = referenceDate ?? DateTime.now();
    final List<PeriodBucket> buckets = [];

    for (int i = 5; i >= 0; i--) {
      final start = anchor.subtract(Duration(days: i * 7 + 6));
      final end = anchor.subtract(Duration(days: i * 7));
      final shortStart = DateFormat('MMM d').format(start);
      final shortEnd = DateFormat('MMM d').format(end);
      final weekIndex = 6 - i;

      buckets.add(
        PeriodBucket(
          label: 'W$weekIndex',
          fullLabel: 'Week $weekIndex ($shortStart – $shortEnd)',
          badgeLabel: 'Week $weekIndex',
          startDate: DateTime(start.year, start.month, start.day),
          endDate: DateTime(end.year, end.month, end.day, 23, 59, 59),
        ),
      );
    }
    return buckets;
  }

  /// Computes the latest 6 months ending at [referenceDate], correctly handling
  /// month-end boundaries, leap years, and year-end transitions (e.g. crossing
  /// from January back to December).
  ///
  /// Defaults to October 2026 to match FinPulse's May – Oct 6-month sprint
  /// dataset when running in baseline environment.
  static List<PeriodBucket> getMonthlyBuckets([DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime(2026, 10, 1);
    final List<PeriodBucket> buckets = [];

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final lastDay = DateTime(date.year, date.month + 1, 0).day;
      final shortName = DateFormat('MMM').format(date);
      final fullName = DateFormat('MMMM yyyy').format(date);
      final fullMonthName = DateFormat('MMMM').format(date);

      buckets.add(
        PeriodBucket(
          label: shortName,
          fullLabel: fullName,
          badgeLabel: 'Month - $fullMonthName',
          startDate: DateTime(date.year, date.month, 1),
          endDate: DateTime(date.year, date.month, lastDay, 23, 59, 59),
        ),
      );
    }
    return buckets;
  }

  /// Computes the latest 6 years ending at [referenceDate] (e.g. 2021 – 2026).
  static List<PeriodBucket> getYearlyBuckets([DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime(2026, 1, 1);
    final endYear = now.year;
    final List<PeriodBucket> buckets = [];

    for (int y = endYear - 5; y <= endYear; y++) {
      buckets.add(
        PeriodBucket(
          label: '$y',
          fullLabel: '$y',
          badgeLabel: 'Year - $y',
          startDate: DateTime(y, 1, 1),
          endDate: DateTime(y, 12, 31, 23, 59, 59),
        ),
      );
    }
    return buckets;
  }

  /// Returns the period buckets for the given [period] type.
  static List<PeriodBucket> getBucketsForPeriod(
    AnalyticsPeriod period, [
    DateTime? referenceDate,
  ]) {
    switch (period) {
      case AnalyticsPeriod.weekly:
        return getWeeklyBuckets(referenceDate);
      case AnalyticsPeriod.monthly:
        return getMonthlyBuckets(referenceDate);
      case AnalyticsPeriod.yearly:
        return getYearlyBuckets(referenceDate);
      case AnalyticsPeriod.custom:
        return getMonthlyBuckets(referenceDate);
    }
  }

  /// Returns short X-axis labels for the given [period] type.
  static List<String> getLabelsForPeriod(
    AnalyticsPeriod period, [
    DateTime? referenceDate,
  ]) {
    return getBucketsForPeriod(
      period,
      referenceDate,
    ).map((b) => b.label).toList();
  }

  /// Formats the top bar period label (e.g. 'Weekly : 2026', 'Monthly : 2026',
  /// 'Yearly : 2026').
  static String getPeriodTypeLabel(
    AnalyticsPeriod period, [
    DateTime? referenceDate,
  ]) {
    final year = (referenceDate ?? DateTime.now()).year;
    switch (period) {
      case AnalyticsPeriod.weekly:
        return 'Weekly : $year';
      case AnalyticsPeriod.monthly:
        return 'Monthly : $year';
      case AnalyticsPeriod.yearly:
        return 'Yearly : $year';
      case AnalyticsPeriod.custom:
        return 'Custom : $year';
    }
  }
}
