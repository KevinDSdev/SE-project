import 'balances_storage.dart';
import 'balances_storage_io.dart'
    if (dart.library.js_interop) 'balances_storage_web.dart'
    as platform_storage;

BalancesStorage createDefaultBalancesStorage() {
  return platform_storage.createBalancesStorage();
}
