import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesService {
  static const String _keyAccentColor = 'ecorp_accent_color';
  static const String _keyActiveWidgets = 'ecorp_active_widgets';
  static const String _keyMainChartStyle = 'ecorp_main_chart_style';
  static const String _keyDefaultPeriod = 'ecorp_default_period';
  static const String _keySubTrendStyle = 'ecorp_sub_trend_style';
  static const String _keySubCategoryStyle = 'ecorp_sub_category_style';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Accent Color
  static Future<void> saveAccentColor(int colorValue) async {
    await init();
    await _prefs?.setInt(_keyAccentColor, colorValue);
  }

  static int? getAccentColor() {
    return _prefs?.getInt(_keyAccentColor);
  }

  // Active Widgets
  static Future<void> saveActiveWidgets(List<String> widgetIds) async {
    await init();
    await _prefs?.setStringList(_keyActiveWidgets, widgetIds);
  }

  static List<String>? getActiveWidgets() {
    return _prefs?.getStringList(_keyActiveWidgets);
  }

  // Main Chart Style ('bar', 'line', 'donut')
  static Future<void> saveMainChartStyle(String style) async {
    await init();
    await _prefs?.setString(_keyMainChartStyle, style);
  }

  static String? getMainChartStyle() {
    return _prefs?.getString(_keyMainChartStyle);
  }

  // Default Period ('weekly', 'monthly', 'yearly', 'custom')
  static Future<void> saveDefaultPeriod(String period) async {
    await init();
    await _prefs?.setString(_keyDefaultPeriod, period);
  }

  static String? getDefaultPeriod() {
    return _prefs?.getString(_keyDefaultPeriod);
  }

  // Sub Trend Style ('bar', 'line', 'donut')
  static Future<void> saveSubTrendStyle(String style) async {
    await init();
    await _prefs?.setString(_keySubTrendStyle, style);
  }

  static String? getSubTrendStyle() {
    return _prefs?.getString(_keySubTrendStyle);
  }

  // Sub Category Style ('bar', 'line', 'donut')
  static Future<void> saveSubCategoryStyle(String style) async {
    await init();
    await _prefs?.setString(_keySubCategoryStyle, style);
  }

  static String? getSubCategoryStyle() {
    return _prefs?.getString(_keySubCategoryStyle);
  }

  // Clear for tests/reset
  static Future<void> clearAll() async {
    await init();
    await _prefs?.clear();
  }
}
