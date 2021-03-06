import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:i18next/i18next.dart';

void main() {
  const locale = Locale('any');
  const data = <String, Object>{'a': '0', 'b': '1'};

  I18NextOptions options;
  ResourceStore store;

  setUp(() {
    options = I18NextOptions.base;
    store = ResourceStore();
  });

  group('#retrieve', () {
    const validNamespace = 'ns';

    setUp(() {
      store = ResourceStore(data: {
        locale: {
          validNamespace: {
            'key': 'This is a simple key',
            'my': {
              'key': 'This is a nested key',
              'nested': {
                'key': 'This is a more nested key',
              }
            }
          }
        }
      });
    });

    test('with null locale', () {
      expect(store.retrieve(null, validNamespace, 'key', options), isNull);
    });

    test('with unmatching locale', () {
      const anotherLocale = Locale('pt');
      expect(
        store.retrieve(anotherLocale, validNamespace, 'key', options),
        isNull,
      );
    });

    group('with matching locale', () {
      test('with null namespace', () {
        expect(store.retrieve(locale, null, 'key', options), isNull);
      });

      test('with unmatching namespace', () {
        expect(store.retrieve(locale, '', 'key', options), isNull);
      });

      group('with matching namespace', () {
        const namespace = validNamespace;

        test('given null key', () {
          expect(store.retrieve(locale, namespace, null, options), isNull);
        });

        test('given a non matching key', () {
          expect(
            store.retrieve(locale, namespace, 'another.key', options),
            isNull,
          );
        });

        test('given a partially matching key', () {
          expect(store.retrieve(locale, namespace, 'my', options), isNull);
          expect(
            store.retrieve(locale, namespace, 'my.nested', options),
            isNull,
          );
        });

        test('given a matching key', () {
          expect(
            store.retrieve(locale, namespace, 'key', options),
            'This is a simple key',
          );
          expect(
            store.retrieve(locale, namespace, 'my.key', options),
            'This is a nested key',
          );
          expect(
            store.retrieve(locale, namespace, 'my.nested.key', options),
            'This is a more nested key',
          );
        });

        test('given an over matching key', () {
          expect(
            store.retrieve(locale, namespace, 'my.nested.key.value', options),
            isNull,
          );
        });
      });
    });

    test('given a keySeparator', () {
      final newOptions = options.apply(I18NextOptions(
        keySeparator: '+++',
      ));
      expect(
        store.retrieve(
          locale,
          validNamespace,
          'my+++nested+++key',
          newOptions,
        ),
        'This is a more nested key',
      );

      expect(
        store.retrieve(
          locale,
          validNamespace,
          'my.nested/key',
          newOptions,
        ),
        isNull,
      );
    });
  });

  group('#addNamespace', () {
    test('given null locale', () {
      expect(() => store.addNamespace(null, '', {}), throwsAssertionError);
    });

    test('given null namespace', () {
      expect(() => store.addNamespace(locale, null, {}), throwsAssertionError);
    });

    test('given null data', () {
      expect(() => store.addNamespace(locale, '', null), throwsAssertionError);
    });
  });

  group('given an unregistered locale', () {
    test('#isLocaleRegistered', () {
      expect(store.isLocaleRegistered(locale), isFalse);
    });

    test('#addNamespace', () {
      const namespace = 'ns';
      expect(store.isNamespaceRegistered(locale, namespace), isFalse);

      store.addNamespace(locale, namespace, data);
      expect(store.isNamespaceRegistered(locale, namespace), isTrue);
    });

    test('#removeNamespace', () {
      expect(() => store.removeNamespace(locale, 'ns'), returnsNormally);
    });

    test('#removeLocale', () {
      expect(() => store.removeLocale(locale), returnsNormally);
      expect(store.isLocaleRegistered(locale), isFalse);
    });

    test('#removeAll', () {
      expect(() => store.removeAll(), returnsNormally);
      expect(store.isLocaleRegistered(locale), isFalse);
    });
  });

  group('given a registered locale and namespace', () {
    const registeredNamespace = 'ns1';

    setUp(() {
      store.addNamespace(locale, registeredNamespace, data);
    });

    test('#removeLocale', () {
      store.removeLocale(locale);
      expect(store.isLocaleRegistered(locale), isFalse);
    });

    test('#removeAll', () {
      store.removeAll();
      expect(store.isLocaleRegistered(locale), isFalse);
    });

    test('#isNamespaceRegistered', () {
      expect(store.isNamespaceRegistered(locale, 'ns1'), isTrue);
    });

    test('#isLocaleRegistered', () {
      expect(store.isLocaleRegistered(locale), isTrue);
    });

    group('given an unregistered namespace', () {
      const newNamespace = 'ns2';

      test('#addNamespace', () {
        expect(store.isNamespaceRegistered(locale, newNamespace), isFalse);

        store.addNamespace(locale, newNamespace, data);
        expect(store.isNamespaceRegistered(locale, newNamespace), isTrue);
        expect(
          store.isNamespaceRegistered(locale, registeredNamespace),
          isTrue,
        );
      });

      test('#removeNamespace', () {
        expect(store.isNamespaceRegistered(locale, newNamespace), isFalse);

        store.removeNamespace(locale, newNamespace);
        expect(store.isNamespaceRegistered(locale, newNamespace), isFalse);
        expect(
          store.isNamespaceRegistered(locale, registeredNamespace),
          isTrue,
        );
      });
    });

    group('given a registered namespace', () {
      test('#addNamespace', () {
        const anotherData = {'a': '00', 'b': '11'};
        store.addNamespace(locale, registeredNamespace, anotherData);
        expect(
            store.isNamespaceRegistered(locale, registeredNamespace), isTrue);
        expect(
          store.retrieve(locale, registeredNamespace, 'a', options),
          equals('00'),
        );
        expect(
          store.retrieve(locale, registeredNamespace, 'b', options),
          equals('11'),
        );
      });

      test('#removeNamespace', () {
        expect(
          store.isNamespaceRegistered(locale, registeredNamespace),
          isTrue,
        );

        store.removeNamespace(locale, registeredNamespace);
        expect(
          store.isNamespaceRegistered(locale, registeredNamespace),
          isFalse,
        );
      });
    });
  });

  group('.evaluate', () {
    const locale = Locale('any');

    final level2 = <Object, Object>{
      'key': 'Second level leaf',
    };
    final level1 = <Object, Object>{
      'key': 'First level leaf',
      'nested': level2,
    };
    final data = <Object, Object>{
      'key': 'Zero level leaf',
      locale: level1,
    };

    const evaluate = ResourceStore.evaluate;

    test('given null path', () {
      expect(() => evaluate(null, data), throwsNoSuchMethodError);
    });

    test('given empty path', () {
      expect(evaluate([], data), data);
    });

    test('given a non matching path', () {
      expect(evaluate(['somewhere'], data), isNull);
      expect(evaluate([null], data), isNull);
    });

    test('given leaf matching path', () {
      expect(evaluate(['key'], data), 'Zero level leaf');
      expect(evaluate([locale, 'key'], data), 'First level leaf');
      expect(evaluate([locale, 'nested', 'key'], data), 'Second level leaf');
    });

    test('given under matching path', () {
      expect(evaluate([locale], data), level1);
      expect(evaluate([locale, 'nested'], data), level2);
    });

    test('given partially matching path', () {
      expect(evaluate([locale, 'another'], data), isNull);
      expect(evaluate([locale, 'nested', 'another'], data), isNull);
    });

    test('given over matching path', () {
      expect(evaluate(['key', 'another'], data), isNull);
      expect(evaluate([locale, 'key', 'another'], data), isNull);
      expect(evaluate([locale, 'nested', 'key', 'another'], data), isNull);
    });
  });
}
