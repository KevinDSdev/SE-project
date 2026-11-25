import 'package:idb_shim/idb_browser.dart';

import 'balances_storage.dart';
import 'balances_web_db.dart';

BalancesStorage createBalancesStorage() =>
    BalancesWebDb(idbFactory: idbFactoryBrowser);
