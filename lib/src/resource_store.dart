import 'package:flutter/widgets.dart';

import 'options.dart';

/// This store handles the access to a specific resource (e.g. String) or a
/// bundle (e.g. namespaces) depending on the levels transversed.
///
/// The access is done by [Locale], Namespace, and key in that order.
class ResourceStore {
  ResourceStore({Map<Locale, Map<String, Object>> data})
      : _data = data ?? {},
        super();

  final Map<Locale, Map<String, Object>> _data;

  /// Registers the [namespace] to the store for the given [locale].
  ///
  /// [locale], [namespace], and [data] cannot be null.
  void addNamespace(
    Locale locale,
    String namespace,
    Map<String, Object> data,
  ) {
    assert(locale != null);
    assert(namespace != null);
    assert(data != null);

    _data[locale] ??= {};
    _data[locale][namespace] = data;
  }

  /// Removes [namespace] given [locale] from the store.
  void removeNamespace(Locale locale, String namespace) {
    _data[locale]?.remove(namespace);
  }

  /// Unregisters the [locale] from the store and from the [cache].
  Future<void> removeLocale(Locale locale) async {
    _data.remove(locale);
  }

  /// Unregisters all locales from the store and from the [cache].
  Future<void> removeAll() async {
    _data.clear();
  }

  /// Whether [locale] and [namespace] are registered in this store.
  bool isNamespaceRegistered(Locale locale, String namespace) =>
      isLocaleRegistered(locale) && _data[locale][namespace] != null;

  /// Whether [locale] is registered in this store.
  bool isLocaleRegistered(Locale locale) => _data[locale] != null;

  /// Attempts to retrieve a value given [Locale] in [options], [namespace],
  /// and [key].
  ///
  /// - [key] cannot be null and it is split by [I18NextOptions.keySeparator]
  ///   when creating a navigation path.
  ///
  /// Returns null if not found.
  String retrieve(
    Locale locale,
    String namespace,
    String key,
    I18NextOptions options,
  ) {
    final path = <Object>[locale, namespace];
    if (key != null) path.addAll(key.split(options.keySeparator));

    final value = evaluate(path, _data);
    return value is String ? value : null;
  }

  /// Given a [path] list, this method navigates through [data] and returns
  /// the last path, or null otherwise.
  static Object evaluate(Iterable<Object> path, Map<Object, Object> data) {
    dynamic object = data;
    for (final current in path) {
      if (object is Map && object.containsKey(current)) {
        object = object[current];
      } else {
        object = null;
        break;
      }
    }
    return object;
  }
}
