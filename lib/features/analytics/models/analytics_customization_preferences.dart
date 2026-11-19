import '../providers/analytics_provider.dart';

/// Immutable model representing the four persisted Analytics Customization
/// preferences stored in SQLite.
class AnalyticsCustomizationPreferences {
  static const String defaultProfileKey = 'default';

  static const ChartVisualMode defaultMainChartStyle = ChartVisualMode.bar;
  static const AnalyticsPeriod defaultAnalyticsPeriod = AnalyticsPeriod.monthly;
  static const ChartVisualMode defaultSubTrendChartStyle = ChartVisualMode.line;
  static const ChartVisualMode defaultSubCategoryChartStyle =
      ChartVisualMode.bar;

  final String profileKey;
  final ChartVisualMode mainChartStyle;
  final AnalyticsPeriod defaultPeriod;
  final ChartVisualMode subTrendChartStyle;
  final ChartVisualMode subCategoryChartStyle;
  final DateTime? updatedAt;

  const AnalyticsCustomizationPreferences({
    this.profileKey = defaultProfileKey,
    this.mainChartStyle = defaultMainChartStyle,
    this.defaultPeriod = defaultAnalyticsPeriod,
    this.subTrendChartStyle = defaultSubTrendChartStyle,
    this.subCategoryChartStyle = defaultSubCategoryChartStyle,
    this.updatedAt,
  });

  const AnalyticsCustomizationPreferences.defaults({
    this.profileKey = defaultProfileKey,
    this.updatedAt,
  }) : mainChartStyle = defaultMainChartStyle,
       defaultPeriod = defaultAnalyticsPeriod,
       subTrendChartStyle = defaultSubTrendChartStyle,
       subCategoryChartStyle = defaultSubCategoryChartStyle;

  /// Validates and parses a raw database or SharedPreferences value into a
  /// [ChartVisualMode], returning [fallback] if missing or invalid.
  static ChartVisualMode parseChartVisualMode(
    Object? rawValue,
    ChartVisualMode fallback,
  ) {
    if (rawValue is String) {
      final normalized = rawValue.trim().toLowerCase();
      for (final mode in ChartVisualMode.values) {
        if (mode.name == normalized) {
          return mode;
        }
      }
    }
    return fallback;
  }

  /// Validates and parses a raw database or SharedPreferences value into an
  /// [AnalyticsPeriod], returning [fallback] if missing or invalid.
  static AnalyticsPeriod parseAnalyticsPeriod(
    Object? rawValue,
    AnalyticsPeriod fallback,
  ) {
    if (rawValue is String) {
      final normalized = rawValue.trim().toLowerCase();
      for (final period in AnalyticsPeriod.values) {
        if (period.name == normalized) {
          return period;
        }
      }
    }
    return fallback;
  }

  /// Safely constructs an [AnalyticsCustomizationPreferences] instance from a
  /// SQLite row map, applying defaults for any missing or invalid values.
  factory AnalyticsCustomizationPreferences.fromMap(Map<String, Object?> map) {
    final rawProfileKey = map['profile_key'];
    final profileKey =
        (rawProfileKey is String && rawProfileKey.trim().isNotEmpty)
        ? rawProfileKey.trim()
        : defaultProfileKey;

    final rawUpdatedAt = map['updated_at'];
    DateTime? parsedUpdatedAt;
    if (rawUpdatedAt is String && rawUpdatedAt.trim().isNotEmpty) {
      parsedUpdatedAt = DateTime.tryParse(rawUpdatedAt.trim());
    }

    return AnalyticsCustomizationPreferences(
      profileKey: profileKey,
      mainChartStyle: parseChartVisualMode(
        map['main_chart_style'],
        defaultMainChartStyle,
      ),
      defaultPeriod: parseAnalyticsPeriod(
        map['default_period'],
        defaultAnalyticsPeriod,
      ),
      subTrendChartStyle: parseChartVisualMode(
        map['sub_trend_chart_style'],
        defaultSubTrendChartStyle,
      ),
      subCategoryChartStyle: parseChartVisualMode(
        map['sub_category_chart_style'],
        defaultSubCategoryChartStyle,
      ),
      updatedAt: parsedUpdatedAt,
    );
  }

  /// Converts this model into a SQLite-compatible column map.
  Map<String, Object?> toMap({DateTime? timestamp}) {
    final effectiveTimestamp = (timestamp ?? updatedAt ?? DateTime.now())
        .toUtc();
    return {
      'profile_key': profileKey,
      'main_chart_style': mainChartStyle.name,
      'default_period': defaultPeriod.name,
      'sub_trend_chart_style': subTrendChartStyle.name,
      'sub_category_chart_style': subCategoryChartStyle.name,
      'updated_at': effectiveTimestamp.toIso8601String(),
    };
  }

  AnalyticsCustomizationPreferences copyWith({
    String? profileKey,
    ChartVisualMode? mainChartStyle,
    AnalyticsPeriod? defaultPeriod,
    ChartVisualMode? subTrendChartStyle,
    ChartVisualMode? subCategoryChartStyle,
    DateTime? updatedAt,
  }) {
    return AnalyticsCustomizationPreferences(
      profileKey: profileKey ?? this.profileKey,
      mainChartStyle: mainChartStyle ?? this.mainChartStyle,
      defaultPeriod: defaultPeriod ?? this.defaultPeriod,
      subTrendChartStyle: subTrendChartStyle ?? this.subTrendChartStyle,
      subCategoryChartStyle:
          subCategoryChartStyle ?? this.subCategoryChartStyle,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyticsCustomizationPreferences &&
        other.profileKey == profileKey &&
        other.mainChartStyle == mainChartStyle &&
        other.defaultPeriod == defaultPeriod &&
        other.subTrendChartStyle == subTrendChartStyle &&
        other.subCategoryChartStyle == subCategoryChartStyle;
  }

  @override
  int get hashCode => Object.hash(
    profileKey,
    mainChartStyle,
    defaultPeriod,
    subTrendChartStyle,
    subCategoryChartStyle,
  );

  @override
  String toString() {
    return 'AnalyticsCustomizationPreferences('
        'profileKey: $profileKey, '
        'mainChartStyle: ${mainChartStyle.name}, '
        'defaultPeriod: ${defaultPeriod.name}, '
        'subTrendChartStyle: ${subTrendChartStyle.name}, '
        'subCategoryChartStyle: ${subCategoryChartStyle.name}, '
        'updatedAt: ${updatedAt?.toIso8601String()}'
        ')';
  }
}
