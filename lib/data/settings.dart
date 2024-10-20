import 'package:shared_preferences/shared_preferences.dart';

// Source:
//
// https://gist.github.com/Metal-666/823a13392c6edbb3736e6452a1a0735d
//
// Usage:
//
// Add your settings to the Settings enum below (like setting1 and setting2).
//
// Call 'await Settings.init();' during the app startup (before accessing any of the settings).
//
// Use 'Settings.<setting_name>.value' or 'Settings.<setting_name>.valueOrDefault' to get a value.
// Call 'await Settings.<setting_name>.save(newValue);' to set a new value.

enum Settings<T extends Object?> {
  // Only use types, supported by Shared Preferences (both nullable and non-nullable are fine).
  // If the type is not nullable, provide a default value.
  serverAddress<String?>();

  static late SharedPreferences _sharedPreferences;

  final T? defaultValue;

  const Settings({this.defaultValue});

  /// Retrieves the value of this setting.
  ///
  /// If the setting is not nullable and was not assigned a value, returns [defaultValue].
  /// If [defaultValue] is also null, throws [NoDefaultValueException].
  T get value {
    final Object? value = _sharedPreferences.get(name);

    // Verify that the setting is either marked as nullable, or has a default value.
    if (null is! T && value == null) {
      // Throw an exception if no default value was provided.
      if (defaultValue == null) {
        throw NoDefaultValueException(name);
      }

      return defaultValue as T;
    }

    return value as T;
  }

  /// Retrieves the value of this setting or [defaultValue] if it is null (even if the setting is nullable).
  T? get valueOrDefault => value ?? defaultValue;

  /// Writes provided [value] to this setting.
  ///
  /// If [value] is null, clears the setting.
  /// If SharedPreferences doesn't support [T], throws [UnsupportedSettingTypeException].
  Future<void> save(final T? value) async {
    if (value == null) {
      await _sharedPreferences.remove(name);
    } else {
      if (value is String) {
        await _sharedPreferences.setString(name, value);

        return;
      }
      if (value is bool) {
        await _sharedPreferences.setBool(name, value);

        return;
      }
      if (value is double) {
        await _sharedPreferences.setDouble(name, value);

        return;
      }
      if (value is int) {
        await _sharedPreferences.setInt(name, value);

        return;
      }
      if (value is List<String>) {
        await _sharedPreferences.setStringList(name, value);

        return;
      }

      // Todo: if the type is unsupported, save it as json?
      // This will probably work...
      /*
      await _sharedPreferences.setString(key, jsonEncode(value));
      */
      // But then there also needs to be a way to retrieve the value (calling the value getter will most likely throw an exception)...

      throw UnsupportedSettingTypeException(name);
    }
  }

  /// Call me during the app startup.
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    // ↓ Uncomment to clear all settings ↓
    /*
    await reset();
    */

    // ↓ Uncomment to clear all settings except setting1 ↓
    /*
    await reset([setting1]);
    */

    // ↓ Initialize settings if needed ↓
    /*
    if (setting1.value == null) {
      await setting1.save('abc');
    }
    */
  }

  /// Call me to clear all settings.
  static Future<void> reset([final List<Settings> except = const []]) async {
    for (final setting in values) {
      if (except.contains(setting)) {
        continue;
      }

      await setting.save(null);
    }
  }
}

abstract class SettingException implements Exception {
  final String _settingName;

  const SettingException(this._settingName);

  String get message;

  @override
  String toString() => message;
}

class NoDefaultValueException extends SettingException {
  const NoDefaultValueException(super.settingName);

  @override
  String get message =>
      'Attempted to get a non-nullable setting "$_settingName" which was not assigned and doesn\'t have a default value.';
}

class UnsupportedSettingTypeException extends SettingException {
  const UnsupportedSettingTypeException(super.settingName);

  @override
  String get message =>
      'Attempted to save setting $_settingName of unsupported type. Try adding a "_sharedPreferences.set*(key, value)" call for your type in the "save" method in Settings enum.';
}
