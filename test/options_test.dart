import 'package:flutter_test/flutter_test.dart';
import 'package:i18next/src/options.dart';

void main() {
  test('default values', () {
    final options = I18NextOptions.base;
    expect(options.namespaceSeparator, ':');
    expect(options.contextSeparator, '_');
    expect(options.pluralSeparator, '_');
    expect(options.keySeparator, '.');

    expect(options.interpolationPrefix, r'\{\{');
    expect(options.interpolationSuffix, r'\}\}');
    expect(options.interpolationSeparator, ',');

    expect(options.nestingPrefix, r'\$t\(');
    expect(options.nestingSuffix, r'\)');
    expect(options.nestingSeparator, ',');

    expect(options.pluralSuffix, 'plural');

    expect(options.formatter, I18NextOptions.defaultFormatter);
  });

  group('constructor', () {
    test('given no values', () {
      final options = I18NextOptions();
      expect(options.namespaceSeparator, isNull);
      expect(options.contextSeparator, isNull);
      expect(options.pluralSeparator, isNull);
      expect(options.keySeparator, isNull);
      expect(options.interpolationPrefix, isNull);
      expect(options.interpolationSuffix, isNull);
      expect(options.interpolationSeparator, isNull);
      expect(options.nestingPrefix, isNull);
      expect(options.nestingSuffix, isNull);
      expect(options.nestingSeparator, isNull);
      expect(options.pluralSuffix, isNull);
      expect(options.formatter, isNull);
    });
  });

  test('.defaultFormatter', () {
    const formatter = I18NextOptions.defaultFormatter;
    expect(formatter('My value', null, null), 'My value');
    expect(formatter(9876.1234, null, null), '9876.1234');

    const object = {'my': 'value'};
    expect(formatter(object, null, null), object.toString());

    final date = DateTime.now();
    expect(formatter(date, null, null), date.toString());
  });

  group('#apply', () {
    final base = I18NextOptions.base;
    final empty = I18NextOptions();
    final another = I18NextOptions(
      namespaceSeparator: '',
      contextSeparator: '',
      pluralSeparator: '',
      keySeparator: '',
      interpolationPrefix: '',
      interpolationSuffix: '',
      interpolationSeparator: '',
      nestingPrefix: '',
      nestingSuffix: '',
      nestingSeparator: '',
      pluralSuffix: '',
      formatter: (value, format, locale) => null,
    );

    test('inequality', () {
      expect(base == empty, isFalse);
      expect(empty == another, isFalse);
      expect(another == base, isFalse);
    });

    test('given equal', () {
      expect(base.apply(base), base);
      expect(empty.apply(empty), empty);
      expect(another.apply(another), another);
    });

    test('from empty given full', () {
      expect(empty.apply(base), base);
      expect(empty.apply(another), another);
    });

    test('from full given empty', () {
      expect(base.apply(empty), base);
      expect(another.apply(empty), another);
    });

    test('from full given full', () {
      expect(base.apply(another), another);
      expect(another.apply(base), base);
    });

    test('given null', () {
      expect(base.apply(null), equals(base));
      expect(empty.apply(null), empty);
      expect(another.apply(null), another);

      expect(identical(base.apply(null), base), isTrue);
    });

    test('creates a new copy', () {
      final result = base.apply(base);
      expect(result, equals(base));
      expect(identical(result, base), isFalse);
    });
  });
}
