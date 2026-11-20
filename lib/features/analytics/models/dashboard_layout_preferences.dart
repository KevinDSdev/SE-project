import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Immutable model representing the persisted Dashboard Layout preferences
/// (ordered active Analytics Dashboard Card IDs).
///
/// Available Analytics Dashboard Cards are never stored separately; they are
/// deterministically derived from [allKnownCardIds] minus [activeCardIds].
class DashboardLayoutPreferences {
  static const String defaultProfileKey = 'default';

  static const List<String> defaultActiveCardIds = <String>[
    'active_income',
    'active_expenses',
    'active_savings',
    'active_trend',
  ];

  static const List<String> defaultAvailableCardIds = <String>[
    'avail_inc_analytics',
    'avail_exp_analytics',
    'avail_goal_analytics',
    'avail_inc_pred',
    'avail_exp_pred',
    'avail_anomaly',
  ];

  static const List<String> allKnownCardIds = <String>[
    ...defaultActiveCardIds,
    ...defaultAvailableCardIds,
  ];

  static final Set<String> _knownCardIdSet = Set<String>.unmodifiable(
    allKnownCardIds,
  );

  final String profileKey;
  final List<String> activeCardIds;
  final DateTime? updatedAt;

  DashboardLayoutPreferences({
    this.profileKey = defaultProfileKey,
    required List<String> activeCardIds,
    this.updatedAt,
  }) : activeCardIds = sanitizeCardIds(activeCardIds);

  const DashboardLayoutPreferences.defaults({
    this.profileKey = defaultProfileKey,
    this.updatedAt,
  }) : activeCardIds = defaultActiveCardIds;

  /// Filters [rawIds] to only known card IDs, removes duplicates, and preserves
  /// the first-seen order.
  static List<String> sanitizeCardIds(Iterable<Object?> rawIds) {
    final seen = <String>{};
    final result = <String>[];
    for (final raw in rawIds) {
      if (raw is! String) continue;
      final normalized = raw.trim();
      if (_knownCardIdSet.contains(normalized) && seen.add(normalized)) {
        result.add(normalized);
      }
    }
    return List<String>.unmodifiable(result);
  }

  /// Parses an ordered list of active card IDs from a JSON string (SQLite or
  /// IndexedDB) or a raw iterable, returning [fallback] only if the value is
  /// missing or malformed. An intentionally empty list (`'[]'` or `[]`) is
  /// preserved as an empty list.
  static List<String> parseActiveCardIds(
    Object? rawValue, {
    List<String> fallback = defaultActiveCardIds,
  }) {
    if (rawValue is String) {
      try {
        final decoded = jsonDecode(rawValue);
        if (decoded is List) {
          return sanitizeCardIds(decoded);
        }
      } catch (_) {
        return List<String>.unmodifiable(fallback);
      }
      return List<String>.unmodifiable(fallback);
    }

    if (rawValue is Iterable) {
      return sanitizeCardIds(rawValue);
    }

    return List<String>.unmodifiable(fallback);
  }

  /// Derives the ordered list of available card IDs from the complete known
  /// card catalog minus [activeCardIds].
  List<String> get availableCardIds {
    final activeSet = activeCardIds.toSet();
    return List<String>.unmodifiable(
      allKnownCardIds.where((id) => !activeSet.contains(id)),
    );
  }

  /// Safely constructs a [DashboardLayoutPreferences] instance from a SQLite
  /// row map or IndexedDB record map.
  factory DashboardLayoutPreferences.fromMap(Map<String, Object?> map) {
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

    return DashboardLayoutPreferences(
      profileKey: profileKey,
      activeCardIds: parseActiveCardIds(map['active_card_ids']),
      updatedAt: parsedUpdatedAt,
    );
  }

  /// Converts this model into a SQLite- and IndexedDB-compatible map with
  /// [activeCardIds] encoded as a JSON array string.
  Map<String, Object?> toMap({DateTime? timestamp}) {
    final effectiveTimestamp = (timestamp ?? updatedAt ?? DateTime.now())
        .toUtc();
    return {
      'profile_key': profileKey,
      'active_card_ids': jsonEncode(activeCardIds),
      'updated_at': effectiveTimestamp.toIso8601String(),
    };
  }

  DashboardLayoutPreferences copyWith({
    String? profileKey,
    List<String>? activeCardIds,
    DateTime? updatedAt,
  }) {
    return DashboardLayoutPreferences(
      profileKey: profileKey ?? this.profileKey,
      activeCardIds: activeCardIds ?? this.activeCardIds,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardLayoutPreferences &&
        other.profileKey == profileKey &&
        listEquals(other.activeCardIds, activeCardIds);
  }

  @override
  int get hashCode => Object.hash(profileKey, Object.hashAll(activeCardIds));

  @override
  String toString() {
    return 'DashboardLayoutPreferences('
        'profileKey: $profileKey, '
        'activeCardIds: $activeCardIds, '
        'updatedAt: ${updatedAt?.toIso8601String()}'
        ')';
  }
}
