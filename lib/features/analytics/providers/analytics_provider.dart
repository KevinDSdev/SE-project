import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/analytics_customization_repository.dart';
import '../data/dashboard_layout_repository.dart';
import '../models/dashboard_layout_preferences.dart';

enum AnalyticsPeriod { weekly, monthly, yearly, custom }

enum ChartVisualMode { bar, line, donut }

class CustomCategoryItem {
  final String id;
  final String name;
  final Color color;
  final bool isExpense;

  const CustomCategoryItem({
    required this.id,
    required this.name,
    required this.color,
    this.isExpense = false,
  });

  CustomCategoryItem copyWith({
    String? id,
    String? name,
    Color? color,
    bool? isExpense,
  }) {
    return CustomCategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      isExpense: isExpense ?? this.isExpense,
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
// Selected Period Provider
// -------------------------------------------------------------
class SelectedPeriodNotifier extends Notifier<AnalyticsPeriod> {
  @override
  AnalyticsPeriod build() {
    return ref.read(analyticsCustomizationRepositoryProvider).defaultPeriod;
  }

  void setPeriod(AnalyticsPeriod period) {
    state = period;
    final repo = ref.read(analyticsCustomizationRepositoryProvider);
    if (repo.isInitialized) {
      unawaited(
        repo.updateDefaultPeriod(period).catchError((
          Object error,
          StackTrace _,
        ) {
          debugPrint('Failed to persist default analytics period: $error');
          return repo.currentPreferences;
        }),
      );
    }
  }

  /// Synchronizes Riverpod state after an atomic repository save without
  /// triggering a duplicate database write.
  void syncState(AnalyticsPeriod period) {
    state = period;
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
    ),
    CustomCategoryItem(
      id: 'inc_2',
      name: 'Kandy Annex Rent Inflow',
      color: Color(0xFF38BDF8),
    ),
    CustomCategoryItem(
      id: 'inc_3',
      name: 'Freelance',
      color: Color(0xFF9353D3),
    ),
  ];

  void add(String name, Color color) {
    state = [
      ...state,
      CustomCategoryItem(
        id: 'inc_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        color: color,
      ),
    ];
  }

  void update(String id, String newName, Color newColor) {
    state = state
        .map(
          (item) => item.id == id
              ? item.copyWith(name: newName, color: newColor)
              : item,
        )
        .toList();
  }

  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
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
    ),
    CustomCategoryItem(
      id: 'exp_2',
      name: 'Transport',
      color: Color(0xFF38BDF8),
      isExpense: true,
    ),
    CustomCategoryItem(
      id: 'exp_3',
      name: 'Utilities',
      color: Color(0xFFF59E0B),
      isExpense: true,
    ),
  ];

  void add(String name, Color color) {
    state = [
      ...state,
      CustomCategoryItem(
        id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        color: color,
        isExpense: true,
      ),
    ];
  }

  void update(String id, String newName, Color newColor) {
    state = state
        .map(
          (item) => item.id == id
              ? item.copyWith(name: newName, color: newColor)
              : item,
        )
        .toList();
  }

  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
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
class ExportPreferencesState {
  final String format; // 'PDF Report' | 'Excel (.XLSX)' | 'Raw Data'
  final String period; // 'October 2026'
  final String account; // 'BOC'
  final Set<String> selectedRequirements;

  const ExportPreferencesState({
    required this.format,
    required this.period,
    required this.account,
    required this.selectedRequirements,
  });

  ExportPreferencesState copyWith({
    String? format,
    String? period,
    String? account,
    Set<String>? selectedRequirements,
  }) {
    return ExportPreferencesState(
      format: format ?? this.format,
      period: period ?? this.period,
      account: account ?? this.account,
      selectedRequirements: selectedRequirements ?? this.selectedRequirements,
    );
  }
}

class ExportPreferencesNotifier extends Notifier<ExportPreferencesState> {
  @override
  ExportPreferencesState build() {
    return const ExportPreferencesState(
      format: 'PDF Report',
      period: 'October 2026',
      account: 'BOC',
      selectedRequirements: {
        'trans_history',
        'inc_analysis',
        'exp_analysis',
        'goal_savings',
      },
    );
  }

  void setFormat(String format) {
    state = state.copyWith(format: format);
  }

  void setPeriod(String period) {
    state = state.copyWith(period: period);
  }

  void setAccount(String account) {
    state = state.copyWith(account: account);
  }

  void toggleRequirement(String id) {
    final updated = Set<String>.from(state.selectedRequirements);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = state.copyWith(selectedRequirements: updated);
  }

  void selectAll(List<String> allIds) {
    if (state.selectedRequirements.length == allIds.length) {
      state = state.copyWith(selectedRequirements: {});
    } else {
      state = state.copyWith(selectedRequirements: allIds.toSet());
    }
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
