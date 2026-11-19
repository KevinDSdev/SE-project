import 'package:idb_shim/idb_browser.dart';

import 'analytics_customization_storage.dart';
import 'analytics_customization_web_db.dart';

AnalyticsCustomizationStorage createAnalyticsCustomizationStorage() {
  final factory = getIdbFactory();
  if (factory == null) {
    throw UnsupportedError(
      'IndexedDB is not available in this browser environment.',
    );
  }
  return AnalyticsCustomizationWebDb(idbFactory: factory);
}
