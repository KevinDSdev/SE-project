import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../services/export_requirements_validator.dart';

/// Immutable model representing the persisted Report Export configuration
/// (latest selected format, time period, account scope, optional custom date
/// range, and analytics requirement module IDs).
class ReportExportPreferences {
  static const String defaultProfileKey = 'default';

  static const String defaultFormat = 'PDF Report';
  static const String defaultPeriod = 'Monthly';
  static const String defaultAccount = 'BOC';
  static const List<String> defaultSelectedRequirements = <String>[
    'trans_history',
    'inc_analysis',
    'exp_analysis',
    'goal_savings',
  ];

  static const List<String> supportedFormats = <String>[
    'PDF Report',
    'Excel (.XLSX)',
    'Raw Data',
  ];

  static const List<String> supportedPeriods = <String>[
    'Weekly',
    'Monthly',
    'Yearly',
    'Custom',
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
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? updatedAt;

  /// Returns true if at least one valid analytics requirement module is selected.
  bool get hasValidRequirements =>
      ExportRequirementsValidator.hasValidRequirements(selectedRequirements);

  ReportExportPreferences({
    String profileKey = defaultProfileKey,
    required String reportFormat,
    required String periodLabel,
    required String accountScope,
    required Iterable<Object?> selectedRequirements,
    Object? startDate,
    Object? endDate,
    this.updatedAt,
  }) : profileKey = sanitizeProfileKey(profileKey),
       reportFormat = sanitizeFormat(reportFormat),
       periodLabel = sanitizePeriod(periodLabel),
       accountScope = sanitizeAccount(accountScope),
       selectedRequirements = sanitizeRequirementIds(selectedRequirements),
       startDate = validateAndSanitizeDateRange(startDate, endDate).$1,
       endDate = validateAndSanitizeDateRange(startDate, endDate).$2;

  const ReportExportPreferences.defaults({
    this.profileKey = defaultProfileKey,
    this.startDate,
    this.endDate,
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

  /// Checks if [val] is a valid period label (one of the four supported
  /// options, a dynamic week date range, a dynamic month, a 4-digit year,
  /// or a preserved historical label).
  static bool isValidPeriodLabel(String val) {
    if (_supportedPeriodSet.contains(val)) return true;
    if (val == 'Custom Range') return true;
    if (RegExp(r'^\d{4}$').hasMatch(val)) return true;
    final monthRegex = RegExp(
      r'^(January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{4}$',
      caseSensitive: false,
    );
    if (monthRegex.hasMatch(val)) return true;
    if ((val.contains('–') || val.contains('-')) &&
        RegExp(r'\d').hasMatch(val)) {
      return true;
    }
    // Also preserve historical choices if loaded from existing database
    if (val == 'October 2026' ||
        val == 'September 2026' ||
        val == 'Q3 2026 (Jul - Sep)' ||
        val == 'Year-to-Date 2026' ||
        val == 'Last 12 Months') {
      return true;
    }
    return false;
  }

  static String sanitizePeriod(
    Object? rawValue, {
    String fallback = defaultPeriod,
  }) {
    if (rawValue is String) {
      final normalized = rawValue.trim();
      if (isValidPeriodLabel(normalized)) {
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

  /// Sanitizes an individual date value to UTC DateTime.
  static DateTime? sanitizeCustomDate(Object? rawValue) {
    if (rawValue is DateTime) {
      return rawValue.toUtc();
    }
    if (rawValue is String && rawValue.trim().isNotEmpty) {
      return DateTime.tryParse(rawValue.trim())?.toUtc();
    }
    return null;
  }

  /// Validates and sanitizes a custom date range. If [rawStart] is strictly after
  /// [rawEnd], the range is automatically inverted/swapped so `start <= end` holds.
  static (DateTime?, DateTime?) validateAndSanitizeDateRange(
    Object? rawStart,
    Object? rawEnd,
  ) {
    final start = sanitizeCustomDate(rawStart);
    final end = sanitizeCustomDate(rawEnd);
    if (start != null && end != null && start.isAfter(end)) {
      return (end, start);
    }
    return (start, end);
  }

  /// Safely constructs a [ReportExportPreferences] instance from a SQLite row
  /// map or IndexedDB record map.
  factory ReportExportPreferences.fromMap(Map<String, Object?> map) {
    final rawUpdatedAt = map['updated_at'];
    DateTime? parsedUpdatedAt;
    if (rawUpdatedAt is String && rawUpdatedAt.trim().isNotEmpty) {
      parsedUpdatedAt = DateTime.tryParse(rawUpdatedAt.trim())?.toUtc();
    }

    final (sanitizedStart, sanitizedEnd) = validateAndSanitizeDateRange(
      map['start_date'],
      map['end_date'],
    );

    return ReportExportPreferences(
      profileKey: sanitizeProfileKey(map['profile_key']),
      reportFormat: sanitizeFormat(map['report_format']),
      periodLabel: sanitizePeriod(map['period_label']),
      accountScope: sanitizeAccount(map['account_scope']),
      selectedRequirements: parseSelectedRequirements(
        map['selected_requirements'],
      ),
      startDate: sanitizedStart,
      endDate: sanitizedEnd,
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
      'start_date': startDate?.toUtc().toIso8601String(),
      'end_date': endDate?.toUtc().toIso8601String(),
      'updated_at': effectiveTimestamp.toIso8601String(),
    };
  }

  ReportExportPreferences copyWith({
    String? profileKey,
    String? reportFormat,
    String? periodLabel,
    String? accountScope,
    Iterable<Object?>? selectedRequirements,
    Object? startDate = _sentinel,
    Object? endDate = _sentinel,
    DateTime? updatedAt,
  }) {
    return ReportExportPreferences(
      profileKey: profileKey ?? this.profileKey,
      reportFormat: reportFormat ?? this.reportFormat,
      periodLabel: periodLabel ?? this.periodLabel,
      accountScope: accountScope ?? this.accountScope,
      selectedRequirements: selectedRequirements ?? this.selectedRequirements,
      startDate: identical(startDate, _sentinel) ? this.startDate : startDate,
      endDate: identical(endDate, _sentinel) ? this.endDate : endDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static const Object _sentinel = Object();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportExportPreferences &&
        other.profileKey == profileKey &&
        other.reportFormat == reportFormat &&
        other.periodLabel == periodLabel &&
        other.accountScope == accountScope &&
        listEquals(other.selectedRequirements, selectedRequirements) &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(
    profileKey,
    reportFormat,
    periodLabel,
    accountScope,
    Object.hashAll(selectedRequirements),
    startDate,
    endDate,
  );

  @override
  String toString() {
    return 'ReportExportPreferences('
        'profileKey: $profileKey, '
        'reportFormat: $reportFormat, '
        'periodLabel: $periodLabel, '
        'accountScope: $accountScope, '
        'selectedRequirements: $selectedRequirements, '
        'startDate: ${startDate?.toIso8601String()}, '
        'endDate: ${endDate?.toIso8601String()}, '
        'updatedAt: ${updatedAt?.toIso8601String()}'
        ')';
  }
}
