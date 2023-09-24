import 'package:fast_expressions/fast_expressions.dart';
import 'package:test/test.dart';

void main() {
  _testBinary();
  _testUnary();
}

dynamic _parse(String source) {
  final f = parseExpression(source);
  return f();
}

void _testBinary() {
  test('Binary operators', () {
    {
      const data = {
        '2*3': 6,
        '6/2': 3,
        '5%2': 1,
        '5~/2': 2,
        '1+2': 3,
        '1-2': -1,
        '1<<1': 2,
        '4>>1': 2,
        '4>>>1': 2,
        '3 & 7': 3,
        '1 | 2': 3,
        '7 ^ 2': 5,
        '3 >= 2': true,
        '3 > 2': true,
        '2 <= 3': true,
        '2 < 3': true,
        'true && false': false,
        'true || false': true,
        'null ?? 3': 3,
        '2 == 2': true,
        '2 != 2': false,
        '2 == 2 ? 4 : 5': 4,
      };
      for (final entry in data.entries) {
        final r = _parse(entry.key);
        expect(r, entry.value, reason: 'source: ${entry.key}');
      }
    }
  });
}

void _testUnary() {
  test('Unary operators', () {
    {
      const data = {
        '-3': -3,
        '!true': false,
        '~40': -41,
      };
      for (final entry in data.entries) {
        final r = _parse(entry.key);
        expect(r, entry.value, reason: 'source: ${entry.key}');
      }
    }
  });
}
