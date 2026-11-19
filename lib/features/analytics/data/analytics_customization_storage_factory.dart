import 'analytics_customization_storage.dart';
import 'analytics_customization_storage_io.dart'
    if (dart.library.js_interop) 'analytics_customization_storage_web.dart'
    as platform_storage;

AnalyticsCustomizationStorage createDefaultAnalyticsCustomizationStorage() {
  return platform_storage.createAnalyticsCustomizationStorage();
}
