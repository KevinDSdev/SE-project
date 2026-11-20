import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../providers/analytics_provider.dart';

/// Immutable model representing the persisted Report Export configuration
/// (latest selected format, time period, account scope, and analytics
/// requirement module IDs).
class ReportExportPreferences {
  static const String defaultProfileKey = 'default';

  static const String defaultFormat = ExportPreferencesState.defaultFormat;
  static const String defaultPeriod = ExportPreferencesState.defaultPeriod;
  static const String defaultAccount = ExportPreferencesState.defaultAccount;
  static const List<String> defaultSelectedRequirements =
      ExportPreferencesState.defaultSelectedRequirements;

  static const List<String> supportedFormats = <String>[
    'PDF Report',
    'Excel (.XLSX)',
    'Raw Data',
  ];

  static const List<String> supportedPeriods = <String>[
    'October 2026',
    'September 2026',
    'Q3 2026 (Jul - Sep)',
    'Year-to-Date 2026',
    'Last 12 Months',
  ];

  static const List<String> supportedAccounts = <String>[
    'BOC',
    'Commercial Bank',
    'Hatton National Bank',
    'Cash Wallet',
    'All Accounts (Consolidated)',
  ];

  static const List<String> allRequirementIds = <String>[
    'trans_history',
    'inc_analysis',
    'exp_analysis',
    'goal_savings',
    'inc_pred',
    'exp_pred',
    'debt_invest',
  ];

  static final Set<String> _supportedFormatSet = Set<String>.unmodifiable(
    supportedFormats,
  );
  static final Set<String> _supportedPeriodSet = Set<String>.unmodifiable(
    supportedPeriods,
  );
  static final Set<String> _supportedAccountSet = Set<String>.unmodifiable(
    supportedAccounts,
  );
  static final Set<String> _knownRequirementIdSet = Set<String>.unmodifiable(
    allRequirementIds,
  );

  final String profileKey;
  final String reportFormat;
  final String periodLabel;
  final String accountScope;
  final List<String> selectedRequirements;
  final DateTime? updatedAt;

  ReportExportPreferences({
    String profileKey = defaultProfileKey,
    required String reportFormat,
    required String periodLabel,
    required String accountScope,
    required Iterable<Object?> selectedRequirements,
    this.updatedAt,
  }) : profileKey = sanitizeProfileKey(profileKey),
       reportFormat = sanitizeFormat(reportFormat),
       periodLabel = sanitizePeriod(periodLabel),
       accountScope = sanitizeAccount(accountScope),
       selectedRequirements = sanitizeRequirementIds(selectedRequirements);

  const ReportExportPreferences.defaults({
    this.profileKey = defaultProfileKey,
    this.updatedAt,
  }) : reportFormat = defaultFormat,
       periodLabel = defaultPeriod,
       accountScope = defaultAccount,
       selectedRequirements = defaultSelectedRequirements;

  static String sanitizeProfileKey(Object? rawValue) {
    if (rawValue is String && rawValue.trim().isNotEmpty) {
      return rawValue.trim();
    }
    return defaultProfileKey;
  }

  static String sanitizeFormat(
    Object? rawValue, {
    String fallback = defaultFormat,
  }) {
    if (rawValue is String) {
      final normalized = rawValue.trim();
      if (_supportedFormatSet.contains(normalized)) {
        return normalized;
      }
    }
    return fallback;
  }

  static String sanitizePeriod(
    Object? rawValue, {
    String fallback = defaultPeriod,
  }) {
    if (rawValue is String) {
      final normalized = rawValue.trim();
      if (_supportedPeriodSet.contains(normalized)) {
        return normalized;
      }
    }
    return fallback;
  }

  static String sanitizeAccount(
    Object? rawValue, {
    String fallback = defaultAccount,
  }) {
    if (rawValue is String) {
      final normalized = rawValue.trim();
      if (_supportedAccountSet.contains(normalized)) {
        return normalized;
      }
    }
    return fallback;
  }

  /// Filters [rawIds] to only known requirement IDs, removes duplicates, and
  /// preserves the first-seen order.
  static List<String> sanitizeRequirementIds(Iterable<Object?> rawIds) {
    final seen = <String>{};
    final result = <String>[];
    for (final raw in rawIds) {
      if (raw is! String) continue;
      final normalized = raw.trim();
      if (_knownRequirementIdSet.contains(normalized) && seen.add(normalized)) {
        result.add(normalized);
      }
    }
    return List<String>.unmodifiable(result);
  }

  /// Parses an ordered list of selected requirement IDs from a JSON array
  /// string (SQLite or IndexedDB) or raw iterable. Returns [fallback] only if
  /// the value is missing or malformed; an intentionally empty list (`'[]'` or
  /// `[]`) is preserved as empty.
  static List<String> parseSelectedRequirements(
    Object? rawValue, {
    List<String> fallback = defaultSelectedRequirements,
  }) {
    if (rawValue is String) {
      try {
        final decoded = jsonDecode(rawValue);
        if (decoded is List) {
          return sanitizeRequirementIds(decoded);
        }
      } catch (_) {
        return List<String>.unmodifiable(fallback);
      }
      return List<String>.unmodifiable(fallback);
    }

    if (rawValue is Iterable) {
      return sanitizeRequirementIds(rawValue);
    }

    return List<String>.unmodifiable(fallback);
  }

  /// Safely constructs a [ReportExportPreferences] instance from a SQLite row
  /// map or IndexedDB record map.
  factory ReportExportPreferences.fromMap(Map<String, Object?> map) {
    final rawUpdatedAt = map['updated_at'];
    DateTime? parsedUpdatedAt;
    if (rawUpdatedAt is String && rawUpdatedAt.trim().isNotEmpty) {
      parsedUpdatedAt = DateTime.tryParse(rawUpdatedAt.trim())?.toUtc();
    }

    return ReportExportPreferences(
      profileKey: sanitizeProfileKey(map['profile_key']),
      reportFormat: sanitizeFormat(map['report_format']),
      periodLabel: sanitizePeriod(map['period_label']),
      accountScope: sanitizeAccount(map['account_scope']),
      selectedRequirements: parseSelectedRequirements(
        map['selected_requirements'],
      ),
      updatedAt: parsedUpdatedAt,
    );
  }

  /// Converts this model into a SQLite- and IndexedDB-compatible map with
  /// [selectedRequirements] encoded as a JSON array string and [updatedAt]
  /// encoded as a UTC ISO-8601 timestamp.
  Map<String, Object?> toMap({DateTime? timestamp}) {
    final effectiveTimestamp = (timestamp ?? updatedAt ?? DateTime.now())
        .toUtc();
    return {
      'profile_key': profileKey,
      'report_format': reportFormat,
      'period_label': periodLabel,
      'account_scope': accountScope,
      'selected_requirements': jsonEncode(selectedRequirements),
      'updated_at': effectiveTimestamp.toIso8601String(),
    };
  }

  ReportExportPreferences copyWith({
    String? profileKey,
    String? reportFormat,
    String? periodLabel,
    String? accountScope,
    Iterable<Object?>? selectedRequirements,
    DateTime? updatedAt,
  }) {
    return ReportExportPreferences(
      profileKey: profileKey ?? this.profileKey,
      reportFormat: reportFormat ?? this.reportFormat,
      periodLabel: periodLabel ?? this.periodLabel,
      accountScope: accountScope ?? this.accountScope,
      selectedRequirements: selectedRequirements ?? this.selectedRequirements,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportExportPreferences &&
        other.profileKey == profileKey &&
        other.reportFormat == reportFormat &&
        other.periodLabel == periodLabel &&
        other.accountScope == accountScope &&
        listEquals(other.selectedRequirements, selectedRequirements);
  }

  @override
  int get hashCode => Object.hash(
    profileKey,
    reportFormat,
    periodLabel,
    accountScope,
    Object.hashAll(selectedRequirements),
  );

  @override
  String toString() {
    return 'ReportExportPreferences('
        'profileKey: $profileKey, '
        'reportFormat: $reportFormat, '
        'periodLabel: $periodLabel, '
        'accountScope: $accountScope, '
        'selectedRequirements: $selectedRequirements, '
        'updatedAt: ${updatedAt?.toIso8601String()}'
        ')';
  }
}
