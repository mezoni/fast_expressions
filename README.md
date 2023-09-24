# fast_expressions

Fast Expressions is an expression parser and evaluation library.

Version: 0.1.2

[![Pub Package](https://img.shields.io/pub/v/fast_expressions.svg)](https://pub.dev/packages/fast_expressions)
[![GitHub Issues](https://img.shields.io/github/issues/mezoni/fast_expressions.svg)](https://github.com/mezoni/fast_expressions/issues)
[![GitHub Forks](https://img.shields.io/github/forks/mezoni/fast_expressions.svg)](https://github.com/mezoni/fast_expressions/forks)
[![GitHub Stars](https://img.shields.io/github/stars/mezoni/fast_expressions.svg)](https://github.com/mezoni/fast_expressions/stargazers)
[![GitHub License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://raw.githubusercontent.com/mezoni/fast_expressions/main/LICENSE)

## About this software

Fast Expressions is an expression parser and evaluation library.  
High performance when parsing parser expressions is achieved by using a very fast parser.  
Parsed expressions are wrapped into function calls.  
High performance when evaluating expressions is achieved by not using any classes and using expression function execution  directly.

## Example

```dart
import 'dart:math';

import 'package:fast_expressions/fast_expressions.dart';

void main(List<String> args) {
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

  {
    const e = '1 + 2 * foo.list()[foo.add(1, 1)]';
    final sw = Stopwatch();
    sw.start();
    const count = 10000;
    for (var i = 0; i < count; i++) {
      final r = parseExpression(
        e,
        context: {
          'foo': Foo(),
        },
        resolve: _resolve,
      );
      r();
    }

    sw.stop();
    print(
        'Expression "$e" parsed and and evaluated $count times in ${sw.elapsed}');
  }

  {
    const e = '1 + 2 * 3';
    final sw = Stopwatch();
    sw.start();
    const count = 100000;
    for (var i = 0; i < count; i++) {
      final r = parseExpression(
        e,
        context: {
          'foo': Foo(),
        },
        resolve: _resolve,
      );
      r();
    }

    sw.stop();
    print(
        'Expression "$e" parsed and and evaluated $count times in ${sw.elapsed}');
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

```
