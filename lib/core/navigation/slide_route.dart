import 'package:cupertino_ui/cupertino_ui.dart';

Route<T> slideRoute<T>(Widget page) {
  return CupertinoPageRoute<T>(
    builder: (context) => page,
  );
}
