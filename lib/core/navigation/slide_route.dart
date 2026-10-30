import 'package:flutter/cupertino.dart';

Route<T> slideRoute<T>(Widget page) {
  return CupertinoPageRoute<T>(
    builder: (context) => page,
  );
}
