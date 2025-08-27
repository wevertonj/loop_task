import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:loop_task/data/exceptions/exceptions.dart';
import 'package:loop_task/utils/constants/app_text.dart';

class LocalStorage {
  AsyncResult<String> save(String key, String value) async {
    try {
      final shared = await SharedPreferences.getInstance();
      shared.setString(key, value);

      return Success(value);
    } catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }

  AsyncResult<String> get(String key) async {
    try {
      final shared = await SharedPreferences.getInstance();
      final value = shared.getString(key);

      return value != null
          ? Success(value)
          : Failure(
              LocalStorageNotFoundException(
                AppText.keyNotFound,
                StackTrace.current,
              ),
            );
    } catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }

  AsyncResult<Unit> delete(String key) async {
    try {
      final shared = await SharedPreferences.getInstance();
      shared.remove(key);

      return Success(unit);
    } catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }
}
