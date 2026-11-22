import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/analytics_customization_repository.dart';
import '../data/dashboard_layout_repository.dart';
import '../data/report_export_repository.dart';
import '../models/dashboard_layout_preferences.dart';
import '../models/report_export_preferences.dart';
import '../services/analytics_period_helper.dart';
import '../services/export_requirements_validator.dart';
import '../../auth/providers/auth_provider.dart';

enum AnalyticsPeriod { weekly, monthly, yearly, custom }

enum AnalyticsScreenType {
  financial,
  income,
  expense,
  goalSavings,
  spendingAnomaly,
}

enum ChartVisualMode { bar, line, donut }

class CustomCategoryItem {
  final String id;
  final String name;
  final Color color;
  final bool isExpense;
  final bool isDefault;

  const CustomCategoryItem({
    required this.id,
    required this.name,
    required this.color,
    this.isExpense = false,
    this.isDefault = false,
  });

  CustomCategoryItem copyWith({
    String? id,
    String? name,
    Color? color,
    bool? isExpense,
    bool? isDefault,
  }) {
    return CustomCategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      isExpense: isExpense ?? this.isExpense,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class DashboardWidgetItem {
  final String id;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final bool isLarge;

  const DashboardWidgetItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.isLarge = false,
  });
}

// -------------------------------------------------------------
// Analytics Customization Repository Provider
// -------------------------------------------------------------
final analyticsCustomizationRepositoryProvider =
    Provider<AnalyticsCustomizationRepository>(
      (ref) => AnalyticsCustomizationRepository.instance,
    );

final dashboardLayoutRepositoryProvider = Provider<DashboardLayoutRepository>(
  (ref) => DashboardLayoutRepository.instance,
);

// -------------------------------------------------------------
// Saved Default Period & Independent Temporary Period Providers
// -------------------------------------------------------------

/// Single source of truth for the persisted Default Analytics Period.
/// Restored from SQLite / IndexedDB cache on startup.
class SavedDefaultPeriodNotifier extends Notifier<AnalyticsPeriod> {
  @override
  AnalyticsPeriod build() {
    final repo = ref.watch(analyticsCustomizationRepositoryProvider);
    return repo.defaultPeriod;
  }

  /// Persists an updated default analytics period to SQLite/IndexedDB
  /// and updates Riverpod state.
  Future<void> setDefaultPeriod(AnalyticsPeriod period) async {
    state = period;
    final repo = ref.read(analyticsCustomizationRepositoryProvider);
    if (repo.isInitialized) {
      await repo.updateDefaultPeriod(period);
    }
  }

  /// Synchronizes Riverpod state after an atomic repository save without
  /// triggering a duplicate database write.
  void syncState(AnalyticsPeriod period) {
    state = period;
  }
}

final savedDefaultPeriodProvider =
    NotifierProvider<SavedDefaultPeriodNotifier, AnalyticsPeriod>(
      SavedDefaultPeriodNotifier.new,
    );

/// In-memory temporary period overrides per analytics screen.
/// Exists only in application memory during the active session.
/// Never written to persistent storage (SQLite, IndexedDB, SharedPreferences).
class TemporaryPeriodOverridesNotifier
    extends Notifier<Map<AnalyticsScreenType, AnalyticsPeriod>> {
  @override
  Map<AnalyticsScreenType, AnalyticsPeriod> build() {
    // Listen to authentication changes: logging out or logging in clears all temporary overrides.
    ref.listen(authProvider, (previous, next) {
      if (previous?.user != next.user) {
        state = const <AnalyticsScreenType, AnalyticsPeriod>{};
      }
    });
    return const <AnalyticsScreenType, AnalyticsPeriod>{};
  }

  /// Sets the temporary period for a specific analytics screen in memory.
  void setScreenPeriod(AnalyticsScreenType screen, AnalyticsPeriod period) {
    state = {...state, screen: period};
  }

  /// Clears the temporary period override for a specific analytics screen.
  void clearScreenPeriod(AnalyticsScreenType screen) {
    if (!state.containsKey(screen)) return;
    final updated = Map<AnalyticsScreenType, AnalyticsPeriod>.from(state);
    updated.remove(screen);
    state = Map.unmodifiable(updated);
  }

  /// Clears all temporary period overrides, resetting every screen to the saved default.
  void clearAll() {
    state = const <AnalyticsScreenType, AnalyticsPeriod>{};
  }

  /// Whether a screen currently has an active temporary override.
  bool hasOverride(AnalyticsScreenType screen) => state.containsKey(screen);
}

final temporaryPeriodOverridesProvider =
    NotifierProvider<
      TemporaryPeriodOverridesNotifier,
      Map<AnalyticsScreenType, AnalyticsPeriod>
    >(TemporaryPeriodOverridesNotifier.new);

/// Screen-specific period provider family.
/// Returns the screen's active temporary override if present; otherwise falls back to the saved default period.
class AnalyticsScreenPeriodNotifier extends Notifier<AnalyticsPeriod> {
  final AnalyticsScreenType screenType;
  AnalyticsScreenPeriodNotifier(this.screenType);

  @override
  AnalyticsPeriod build() {
    final savedDefault = ref.watch(savedDefaultPeriodProvider);
    final overrides = ref.watch(temporaryPeriodOverridesProvider);
    return overrides[screenType] ?? savedDefault;
  }

  /// Sets the temporary period selection for this screen in memory only.
  /// Never writes to persistent storage.
  void setPeriod(AnalyticsPeriod period) {
    ref
        .read(temporaryPeriodOverridesProvider.notifier)
        .setScreenPeriod(screenType, period);
  }

  /// Clears this screen's temporary override, returning it to the saved default.
  void resetToDefault() {
    ref
        .read(temporaryPeriodOverridesProvider.notifier)
        .clearScreenPeriod(screenType);
  }
}

final analyticsScreenPeriodProvider =
    NotifierProvider.family<
      AnalyticsScreenPeriodNotifier,
      AnalyticsPeriod,
      AnalyticsScreenType
    >(AnalyticsScreenPeriodNotifier.new);

/// Backwards-compatible provider mapped to the Main Financial Analytics screen.
/// Preserves legacy consumers while delegating to the new screen-specific architecture.
class SelectedPeriodNotifier extends Notifier<AnalyticsPeriod> {
  @override
  AnalyticsPeriod build() {
    return ref.watch(
      analyticsScreenPeriodProvider(AnalyticsScreenType.financial),
    );
  }

  /// Sets the temporary period for the Main Financial Analytics screen in memory.
  void setPeriod(AnalyticsPeriod period) {
    ref
        .read(
          analyticsScreenPeriodProvider(AnalyticsScreenType.financial).notifier,
        )
        .setPeriod(period);
  }

  /// Synchronizes the saved default period (e.g. from Analytics Customization).
  void syncState(AnalyticsPeriod period) {
    ref.read(savedDefaultPeriodProvider.notifier).syncState(period);
  }

  /// Sets and persists a new default period in SQLite / IndexedDB.
  Future<void> setDefaultPeriod(AnalyticsPeriod period) async {
    await ref
        .read(savedDefaultPeriodProvider.notifier)
        .setDefaultPeriod(period);
  }
}

final selectedPeriodProvider =
    NotifierProvider<SelectedPeriodNotifier, AnalyticsPeriod>(
      SelectedPeriodNotifier.new,
    );

// -------------------------------------------------------------
// Chart Style Providers
// -------------------------------------------------------------
class MainChartStyleNotifier extends Notifier<ChartVisualMode> {
  @override
  ChartVisualMode build() {
    return ref.read(analyticsCustomizationRepositoryProvider).mainChartStyle;
  }

  void setStyle(ChartVisualMode mode) {
    state = mode;
    final repo = ref.read(analyticsCustomizationRepositoryProvider);
    if (repo.isInitialized) {
      unawaited(
        repo.updateMainChartStyle(mode).catchError((
          Object error,
          StackTrace _,
        ) {
          debugPrint('Failed to persist main chart style: $error');
          return repo.currentPreferences;
        }),
      );
    }
  }

  /// Synchronizes Riverpod state after an atomic repository save without
  /// triggering a duplicate database write.
  void syncState(ChartVisualMode mode) {
    state = mode;
  }
}

final mainChartStyleProvider =
    NotifierProvider<MainChartStyleNotifier, ChartVisualMode>(
      MainChartStyleNotifier.new,
    );

class SubTrendChartStyleNotifier extends Notifier<ChartVisualMode> {
  @override
  ChartVisualMode build() {
    return ref
        .read(analyticsCustomizationRepositoryProvider)
        .subTrendChartStyle;
  }

  void setStyle(ChartVisualMode mode) {
    state = mode;
    final repo = ref.read(analyticsCustomizationRepositoryProvider);
    if (repo.isInitialized) {
      unawaited(
        repo.updateSubTrendChartStyle(mode).catchError((
          Object error,
          StackTrace _,
        ) {
          debugPrint('Failed to persist sub-trend chart style: $error');
          return repo.currentPreferences;
        }),
      );
    }
  }

  /// Synchronizes Riverpod state after an atomic repository save without
  /// triggering a duplicate database write.
  void syncState(ChartVisualMode mode) {
    state = mode;
  }
}

final subTrendChartStyleProvider =
    NotifierProvider<SubTrendChartStyleNotifier, ChartVisualMode>(
      SubTrendChartStyleNotifier.new,
    );

class SubCategoryChartStyleNotifier extends Notifier<ChartVisualMode> {
  @override
  ChartVisualMode build() {
    return ref
        .read(analyticsCustomizationRepositoryProvider)
        .subCategoryChartStyle;
  }

  void setStyle(ChartVisualMode mode) {
    state = mode;
    final repo = ref.read(analyticsCustomizationRepositoryProvider);
    if (repo.isInitialized) {
      unawaited(
        repo.updateSubCategoryChartStyle(mode).catchError((
          Object error,
          StackTrace _,
        ) {
          debugPrint('Failed to persist sub-category chart style: $error');
          return repo.currentPreferences;
        }),
      );
    }
  }

  /// Synchronizes Riverpod state after an atomic repository save without
  /// triggering a duplicate database write.
  void syncState(ChartVisualMode mode) {
    state = mode;
  }
}

final subCategoryChartStyleProvider =
    NotifierProvider<SubCategoryChartStyleNotifier, ChartVisualMode>(
      SubCategoryChartStyleNotifier.new,
    );

// -------------------------------------------------------------
// Income Sources & Expense Categories Provider
// -------------------------------------------------------------
class IncomeMethodsNotifier extends Notifier<List<CustomCategoryItem>> {
  @override
  List<CustomCategoryItem> build() => const [
    CustomCategoryItem(
      id: 'inc_1',
      name: 'Primary Salary',
      color: Color(0xFF98E836),
      isDefault: true,
    ),
    CustomCategoryItem(
      id: 'inc_2',
      name: 'Kandy Annex Rent Inflow',
      color: Color(0xFF38BDF8),
      isDefault: true,
    ),
    CustomCategoryItem(
      id: 'inc_3',
      name: 'Freelance',
      color: Color(0xFF9353D3),
      isDefault: true,
    ),
  ];

  /// Appends a category supplied externally (e.g. from the Budget module or test suites).
  /// Note: Category creation UI is exclusively owned by the Budget module.
  void add(String name, Color color, {bool isDefault = false}) {
    state = [
      ...state,
      CustomCategoryItem(
        id: 'inc_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        color: color,
        isDefault: isDefault,
      ),
    ];
  }

  /// Updates an existing user-created category's name and color.
  /// Preserves the original category ID. Built-in categories are protected from mutation.
  void update(String id, String newName, Color newColor) {
    state = state
        .map(
          (item) => (item.id == id && !item.isDefault)
              ? item.copyWith(name: newName, color: newColor)
              : item,
        )
        .toList();
  }

  /// Deletes a user-created category.
  /// Built-in categories are protected from deletion.
  void remove(String id) {
    state = state.where((item) => item.id != id || item.isDefault).toList();
  }
}

final incomeMethodsProvider =
    NotifierProvider<IncomeMethodsNotifier, List<CustomCategoryItem>>(
      IncomeMethodsNotifier.new,
    );

class ExpenseCategoriesNotifier extends Notifier<List<CustomCategoryItem>> {
  @override
  List<CustomCategoryItem> build() => const [
    CustomCategoryItem(
      id: 'exp_1',
      name: 'Food & Groceries',
      color: Color(0xFFF43F5E),
      isExpense: true,
      isDefault: true,
    ),
    CustomCategoryItem(
      id: 'exp_2',
      name: 'Transport',
      color: Color(0xFF38BDF8),
      isExpense: true,
      isDefault: true,
    ),
    CustomCategoryItem(
      id: 'exp_3',
      name: 'Utilities',
      color: Color(0xFFF59E0B),
      isExpense: true,
      isDefault: true,
    ),
  ];

  /// Appends a category supplied externally (e.g. from the Budget module or test suites).
  /// Note: Category creation UI is exclusively owned by the Budget module.
  void add(String name, Color color, {bool isDefault = false}) {
    state = [
      ...state,
      CustomCategoryItem(
        id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        color: color,
        isExpense: true,
        isDefault: isDefault,
      ),
    ];
  }

  /// Updates an existing user-created category's name and color.
  /// Preserves the original category ID. Built-in categories are protected from mutation.
  void update(String id, String newName, Color newColor) {
    state = state
        .map(
          (item) => (item.id == id && !item.isDefault)
              ? item.copyWith(name: newName, color: newColor)
              : item,
        )
        .toList();
  }

  /// Deletes a user-created category.
  /// Built-in categories are protected from deletion.
  void remove(String id) {
    state = state.where((item) => item.id != id || item.isDefault).toList();
  }
}

final expenseCategoriesProvider =
    NotifierProvider<ExpenseCategoriesNotifier, List<CustomCategoryItem>>(
      ExpenseCategoriesNotifier.new,
    );

class ApplySubDashboardsLayoutNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
  void setVal(bool val) => state = val;
}

final applySubDashboardsLayoutProvider =
    NotifierProvider<ApplySubDashboardsLayoutNotifier, bool>(
      ApplySubDashboardsLayoutNotifier.new,
    );

// -------------------------------------------------------------
// Dashboard Widgets Layout Provider
// -------------------------------------------------------------
class DashboardWidgetsState {
  final List<DashboardWidgetItem> activeWidgets;
  final List<DashboardWidgetItem> availableWidgets;

  const DashboardWidgetsState({
    required this.activeWidgets,
    required this.availableWidgets,
  });

  DashboardWidgetsState copyWith({
    List<DashboardWidgetItem>? activeWidgets,
    List<DashboardWidgetItem>? availableWidgets,
  }) {
    return DashboardWidgetsState(
      activeWidgets: activeWidgets ?? this.activeWidgets,
      availableWidgets: availableWidgets ?? this.availableWidgets,
    );
  }
}

class DashboardWidgetsNotifier extends Notifier<DashboardWidgetsState> {
  static const List<DashboardWidgetItem> _defaultActive = [
    DashboardWidgetItem(
      id: 'active_income',
      title: 'Income',
      subtitle: 'LKR 216,500',
      color: Color(0xFF98E836),
      icon: Icons.account_balance_wallet_rounded,
    ),
    DashboardWidgetItem(
      id: 'active_expenses',
      title: 'Expenses',
      subtitle: 'LKR 10,615',
      color: Color(0xFFF43F5E),
      icon: Icons.trending_down_rounded,
    ),
    DashboardWidgetItem(
      id: 'active_savings',
      title: 'Savings',
      subtitle: 'LKR 10,615',
      color: Color(0xFF38BDF8),
      icon: Icons.savings_rounded,
    ),
    DashboardWidgetItem(
      id: 'active_trend',
      title: 'Income vs Expenses Trend',
      subtitle: 'May - Oct',
      color: Color(0xFF161922),
      icon: Icons.auto_graph_rounded,
      isLarge: true,
    ),
  ];

  static const List<DashboardWidgetItem> _defaultAvailable = [
    DashboardWidgetItem(
      id: 'avail_inc_analytics',
      title: 'Income Analytics',
      subtitle: 'Detailed revenue & streams',
      color: Color(0xFF98E836),
      icon: Icons.pie_chart_outline_rounded,
    ),
    DashboardWidgetItem(
      id: 'avail_exp_analytics',
      title: 'Expenses Analytics',
      subtitle: 'Category spend & budget tracker',
      color: Color(0xFFF43F5E),
      icon: Icons.analytics_outlined,
    ),
    DashboardWidgetItem(
      id: 'avail_goal_analytics',
      title: 'Goal Savings Analytics',
      subtitle: 'Milestone progress & cushion',
      color: Color(0xFF38BDF8),
      icon: Icons.track_changes_rounded,
    ),
    DashboardWidgetItem(
      id: 'avail_inc_pred',
      title: 'Income Prediction Analytics',
      subtitle: 'Inflow forecast & trend',
      color: Color(0xFF98E836),
      icon: Icons.manage_search_rounded,
    ),
    DashboardWidgetItem(
      id: 'avail_exp_pred',
      title: 'Expenses Prediction Analytics',
      subtitle: 'Outflow probability & spike est.',
      color: Color(0xFFF43F5E),
      icon: Icons.query_stats_rounded,
    ),
    DashboardWidgetItem(
      id: 'avail_anomaly',
      title: 'Anomaly Detection Analytics',
      subtitle: 'Unusual spike alerts',
      color: Color(0xFFF59E0B),
      icon: Icons.warning_amber_rounded,
    ),
  ];

  static const List<DashboardWidgetItem> _allCards = [
    ..._defaultActive,
    ..._defaultAvailable,
  ];

  static final Map<String, DashboardWidgetItem> _cardsById = {
    for (final item in _allCards) item.id: item,
  };

  /// Builds a [DashboardWidgetsState] from an ordered list of active card IDs,
  /// ignoring unknown/duplicate IDs and deriving available cards from the full
  /// known catalog.
  static DashboardWidgetsState stateFromActiveIds(List<String> activeIds) {
    final sanitizedIds = DashboardLayoutPreferences.sanitizeCardIds(activeIds);
    final active = <DashboardWidgetItem>[
      for (final id in sanitizedIds)
        if (_cardsById.containsKey(id)) _cardsById[id]!,
    ];
    final activeIdSet = active.map((c) => c.id).toSet();
    final available = _allCards
        .where((c) => !activeIdSet.contains(c.id))
        .toList();
    return DashboardWidgetsState(
      activeWidgets: active,
      availableWidgets: available,
    );
  }

  @override
  DashboardWidgetsState build() {
    final repo = ref.read(dashboardLayoutRepositoryProvider);
    return stateFromActiveIds(repo.activeCardIds);
  }

  void removeActive(String id) {
    final active = [...state.activeWidgets];
    final index = active.indexWhere((w) => w.id == id);
    if (index == -1) return;

    final item = active.removeAt(index);
    final available = [...state.availableWidgets, item];
    state = state.copyWith(activeWidgets: active, availableWidgets: available);
  }

  void addAvailable(String id) {
    final available = [...state.availableWidgets];
    final index = available.indexWhere((w) => w.id == id);
    if (index == -1) return;

    final item = available.removeAt(index);
    final active = [...state.activeWidgets, item];
    state = state.copyWith(activeWidgets: active, availableWidgets: available);
  }

  /// Synchronizes Riverpod state after a repository save without triggering a
  /// duplicate database write.
  void syncState(List<String> activeCardIds) {
    state = stateFromActiveIds(activeCardIds);
  }

  Future<void> savePreferences() async {
    final activeIds = state.activeWidgets.map((w) => w.id).toList();
    final saved = await ref
        .read(dashboardLayoutRepositoryProvider)
        .saveActiveCardIds(activeIds);
    state = stateFromActiveIds(saved.activeCardIds);
  }

  Future<void> applyState(
    List<DashboardWidgetItem> active,
    List<DashboardWidgetItem> available,
  ) async {
    final activeIds = active.map((w) => w.id).toList();
    final saved = await ref
        .read(dashboardLayoutRepositoryProvider)
        .saveActiveCardIds(activeIds);
    state = stateFromActiveIds(saved.activeCardIds);
  }

  DashboardWidgetsState get defaultState => const DashboardWidgetsState(
    activeWidgets: _defaultActive,
    availableWidgets: _defaultAvailable,
  );

  Future<void> reset() async {
    final saved = await ref
        .read(dashboardLayoutRepositoryProvider)
        .resetToDefaults();
    state = stateFromActiveIds(saved.activeCardIds);
  }
}

final dashboardWidgetsProvider =
    NotifierProvider<DashboardWidgetsNotifier, DashboardWidgetsState>(
      DashboardWidgetsNotifier.new,
    );

// -------------------------------------------------------------
// Report Export Provider
// -------------------------------------------------------------
final reportExportRepositoryProvider = Provider<ReportExportRepository>(
  (ref) => ReportExportRepository.instance,
);

class ExportPreferencesState {
  static const String defaultFormat = ReportExportPreferences.defaultFormat;
  static const String defaultPeriod = ReportExportPreferences.defaultPeriod;
  static const String defaultAccount = ReportExportPreferences.defaultAccount;
  static const List<String> defaultSelectedRequirements =
      ReportExportPreferences.defaultSelectedRequirements;

  final String format; // 'PDF Report' | 'Excel (.XLSX)' | 'Raw Data'
  final String period; // e.g. 'November 2026', 'Nov 16 – Nov 22, 2026', '2026', 'Custom Range'
  final String periodType; // 'Weekly' | 'Monthly' | 'Yearly' | 'Custom'
  final String account; // 'BOC'
  final Set<String> selectedRequirements;
  final DateTime? startDate;
  final DateTime? endDate;

  /// Returns true if at least one valid analytics requirement module is selected.
  bool get hasValidRequirements =>
      ExportRequirementsValidator.hasValidRequirements(selectedRequirements);

  const ExportPreferencesState({
    required this.format,
    required this.period,
    this.periodType = 'Monthly',
    required this.account,
    required this.selectedRequirements,
    this.startDate,
    this.endDate,
  });

  ExportPreferencesState copyWith({
    String? format,
    String? period,
    String? periodType,
    String? account,
    Set<String>? selectedRequirements,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ExportPreferencesState(
      format: format ?? this.format,
      period: period ?? this.period,
      periodType: periodType ?? this.periodType,
      account: account ?? this.account,
      selectedRequirements: selectedRequirements ?? this.selectedRequirements,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class ExportPreferencesNotifier extends Notifier<ExportPreferencesState> {
  static ExportPreferencesState _stateFromPreferences(
    ReportExportPreferences prefs,
  ) {
    final rollover = AnalyticsPeriodHelper.resolveExportPeriodRollover(
      periodType: null,
      periodLabel: prefs.periodLabel,
      startDate: prefs.startDate,
      endDate: prefs.endDate,
    );
    return ExportPreferencesState(
      format: prefs.reportFormat,
      period: rollover.periodLabel,
      periodType: rollover.periodType,
      account: prefs.accountScope,
      selectedRequirements: prefs.selectedRequirements.toSet(),
      startDate: rollover.startDate,
      endDate: rollover.endDate,
    );
  }

  @override
  ExportPreferencesState build() {
    final persisted = ref
        .read(reportExportRepositoryProvider)
        .currentPreferences;
    return _stateFromPreferences(persisted);
  }

  Future<void> _persist(ReportExportPreferences nextPreferences) async {
    final saved = await ref
        .read(reportExportRepositoryProvider)
        .savePreferences(nextPreferences);
    state = _stateFromPreferences(saved);
  }

  Future<void> setFormat(String format) {
    return _persist(
      ReportExportPreferences(
        reportFormat: format,
        periodLabel: state.period,
        accountScope: state.account,
        selectedRequirements: state.selectedRequirements,
        startDate: state.startDate,
        endDate: state.endDate,
      ),
    );
  }

  /// Sets the active period category ('Weekly', 'Monthly', 'Yearly', 'Custom')
  /// and automatically selects the current period within that category.
  Future<void> setPeriodType(String type) {
    final rollover = AnalyticsPeriodHelper.resolveExportPeriodRollover(
      periodType: type,
      periodLabel: state.periodType == type ? state.period : null,
      startDate: state.startDate,
      endDate: state.endDate,
    );
    return _persist(
      ReportExportPreferences(
        reportFormat: state.format,
        periodLabel: rollover.periodLabel,
        accountScope: state.account,
        selectedRequirements: state.selectedRequirements,
        startDate: rollover.startDate,
        endDate: rollover.endDate,
      ),
    );
  }

  Future<void> setPeriod(String period, [DateTime? start, DateTime? end]) {
    final isCustom = period == 'Custom Range' || period == 'Custom';
    final rollover = AnalyticsPeriodHelper.resolveExportPeriodRollover(
      periodType: isCustom ? 'Custom' : null,
      periodLabel: isCustom ? 'Custom Range' : period,
      startDate: start ?? (isCustom ? state.startDate : null),
      endDate: end ?? (isCustom ? state.endDate : null),
    );
    return _persist(
      ReportExportPreferences(
        reportFormat: state.format,
        periodLabel: rollover.periodLabel,
        accountScope: state.account,
        selectedRequirements: state.selectedRequirements,
        startDate: rollover.startDate,
        endDate: rollover.endDate,
      ),
    );
  }

  /// Automatically refreshes rollover on screen open or app resume.
  Future<void> refreshPeriodRollover() {
    final rollover = AnalyticsPeriodHelper.resolveExportPeriodRollover(
      periodType: state.periodType,
      periodLabel: state.period,
      startDate: state.startDate,
      endDate: state.endDate,
    );
    if (rollover.periodLabel != state.period ||
        rollover.periodType != state.periodType ||
        rollover.startDate != state.startDate ||
        rollover.endDate != state.endDate) {
      return _persist(
        ReportExportPreferences(
          reportFormat: state.format,
          periodLabel: rollover.periodLabel,
          accountScope: state.account,
          selectedRequirements: state.selectedRequirements,
          startDate: rollover.startDate,
          endDate: rollover.endDate,
        ),
      );
    }
    return Future.value();
  }

  Future<void> setCustomDateRange(DateTime? start, DateTime? end) {
    return setPeriod('Custom Range', start, end);
  }

  Future<void> setAccount(String account) {
    return _persist(
      ReportExportPreferences(
        reportFormat: state.format,
        periodLabel: state.period,
        accountScope: account,
        selectedRequirements: state.selectedRequirements,
        startDate: state.startDate,
        endDate: state.endDate,
      ),
    );
  }

  Future<void> toggleRequirement(String id) {
    final updated = Set<String>.from(state.selectedRequirements);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    return _persist(
      ReportExportPreferences(
        reportFormat: state.format,
        periodLabel: state.period,
        accountScope: state.account,
        selectedRequirements: updated,
        startDate: state.startDate,
        endDate: state.endDate,
      ),
    );
  }

  Future<void> selectAll(List<String> allIds) {
    final nextSelected = state.selectedRequirements.length == allIds.length
        ? const <String>[]
        : allIds;
    return _persist(
      ReportExportPreferences(
        reportFormat: state.format,
        periodLabel: state.period,
        accountScope: state.account,
        selectedRequirements: nextSelected,
        startDate: state.startDate,
        endDate: state.endDate,
      ),
    );
  }
}

final exportPreferencesProvider =
    NotifierProvider<ExportPreferencesNotifier, ExportPreferencesState>(
      ExportPreferencesNotifier.new,
    );

// -------------------------------------------------------------
// Flagged Anomalies Provider
// -------------------------------------------------------------
class FlaggedTransactionItem {
  final String id;
  final String title;
  final String category;
  final double amount;
  final double baseline;
  final String date;
  final bool isDismissed;

  const FlaggedTransactionItem({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.baseline,
    required this.date,
    this.isDismissed = false,
  });

  FlaggedTransactionItem copyWith({bool? isDismissed}) {
    return FlaggedTransactionItem(
      id: id,
      title: title,
      category: category,
      amount: amount,
      baseline: baseline,
      date: date,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }
}

class FlaggedTransactionsNotifier
    extends Notifier<List<FlaggedTransactionItem>> {
  @override
  List<FlaggedTransactionItem> build() => const [
    FlaggedTransactionItem(
      id: 'anom_1',
      title: 'CEB Electricity Bill',
      category: 'Utilities (CEB)',
      amount: 13000,
      baseline: 8000,
      date: '18 Oct 2026',
    ),
    FlaggedTransactionItem(
      id: 'anom_2',
      title: 'Pizza Hut',
      category: 'Dining & Takeout',
      amount: 17000,
      baseline: 5000,
      date: '22 Oct 2026',
    ),
  ];

  void dismissAll() {
    state = state.map((item) => item.copyWith(isDismissed: true)).toList();
  }

  void restoreAll() {
    state = state.map((item) => item.copyWith(isDismissed: false)).toList();
  }

  void dismissItem(String id) {
    state = state
        .map((item) => item.id == id ? item.copyWith(isDismissed: true) : item)
        .toList();
  }
}

final flaggedTransactionsProvider =
    NotifierProvider<FlaggedTransactionsNotifier, List<FlaggedTransactionItem>>(
      FlaggedTransactionsNotifier.new,
    );
