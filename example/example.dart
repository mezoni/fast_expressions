import 'dart:math';

import 'package:fast_expressions/fast_expressions.dart';

void main(List<String> args) {
  {
    const e = '1.isEven ? "Yes, 1 is even" : "No, 1 is odd"';
    final r = parseExpression(
      e,
      resolve: _resolve,
    );
    print(r());
  }

  {
    const e = '1 + 2 * 3';
    final r = parseExpression(e);
    print(r());
  }

  {
    const e = '1 + 2 * x';
    final r = parseExpression(
      e,
      context: {
        'x': 3,
      },
    );
    print(r());
  }

  {
    const e = '1 + 2 * x[y]';
    final r = parseExpression(
      e,
      context: {
        'x': [1, 2, 3],
        'y': 2,
      },
    );
    print(r());
  }

  {
    const e = '1 + 2 * add(1, 2)';
    final r = parseExpression(
      e,
      context: {
        'add': (num x, num y) => x + y,
      },
    );
    print(r());
  }

  {
    const e = '1 + 2 * sub(x: 7, y: 4)';
    final r = parseExpression(
      e,
      context: {
        'sub': ({required num x, required num y}) => x - y,
      },
    );
    print(r());
  }

  {
    const e = '1 + 2 * foo.add(1, 2)';
    final r = parseExpression(
      e,
      context: {
        'foo': Foo(),
      },
      resolve: _resolve,
    );
    print(r());
  }

  {
    const e = '1 + 2 * foo.list()[foo.add(1, 1)]';
    final r = parseExpression(
      e,
      context: {
        'foo': Foo(),
      },
      resolve: _resolve,
    );
    print(r());
  }

  {
    const e = '''
"Hello, " + friends[random()].name
''';
    final friends = [
      Person('Jack'),
      Person('Jerry'),
      Person('John'),
    ];
    final r = parseExpression(
      e,
      context: {
        'friends': friends,
        'random': () => Random().nextInt(friends.length - 1),
      },
      resolve: _resolve,
    );
    print(r());
  }
}

dynamic _resolve(dynamic object, String member) {
  Never error() {
    throw StateError("Invalid member '$member', object is $object");
  }

  if (object is Foo) {
    switch (member) {
      case 'add':
        return object.add;
      case 'list':
        return object.list;
    }
  }

  if (object is Person) {
    switch (member) {
      case 'name':
        return object.name;
    }
  }

  if (object is int) {
    switch (member) {
      case 'isEven':
        return object.isEven;
    }
  }

  error();
}

class Foo {
  num add(num x, num y) => x + y;

  List<num> list() => [1, 2, 3];
}

class Person {
  final String name;

  Person(this.name);
}
