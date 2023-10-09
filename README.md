# fast_expressions

Fast Expressions is an expression parser and evaluation library.

Version: 0.1.6

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

```

## About the implementation of parsers

Parsers are generated from PEG grammars.  
Software used to generate parsers [![Pub Package](https://img.shields.io/pub/v/peg.svg)](https://pub.dev/packages/peg)  
Below is the source code for one of the grammars.

```%{

typedef Expression = dynamic Function();

String _escape(int charCode) {
    switch (charCode) {
      case 0x22:
        return '"';
      case 0x2f:
        return '/';
      case 0x5c:
        return '\\';
      case 0x62:
        return '\b';
      case 0x66:
        return '\f';
      case 0x6e:
        return '\n';
      case 0x72:
        return '\r';
      case 0x74:
        return '\t';
      default:
        throw StateError('Unable to escape charCode: $charCode');
    }
  }

}%

%%
  final Map<String, dynamic> context;

  final dynamic Function(dynamic object, String member)? resolve;

  ExpressionParser({
    this.context = const {},
    this.resolve,
  });

  Expression _binary(Expression? left, ({String op, Expression expr}) next) {
    final op = next.op;
    final right = next.expr;
    final l = left!;
    switch (op) {
      case '+':
        return () => l() + right();
      case '-':
        return () => l() - right();
      case '/':
        return () => l() / right();
      case '*':
        return () => l() * right();
      case '%':
        return () => l() % right();
      case '~/':
        return () => l() ~/ right();
      case '<<':
        return () => l() << right();
      case '>>':
        return () => l() >> right();
      case '>>>':
        return () => l() >>> right();
      case '&':
        return () => l() & right();
      case '^':
        return () => l() ^ right();
      case '|':
        return () => l() | right();
      case '>':
        return () => l() > right();
      case '>=':
        return () => l() >= right();
      case '<':
        return () => l() < right();
      case '<=':
        return () => l() <= right();
      case '||':
        return () => l() as bool || right() as bool;
      case '&&':
        return () => l() as bool && right() as bool;
      case '??':
        return () => l() ?? right();
      case '==':
        return () => l() == right();
      case '!=':
        return () => l() != right();
      default:
        throw StateError('Unknown operator: $op');
    }
  }

  Expression _prefix(String? operator, Expression operand) {
    if (operator == null) {
      return operand;
    }

    switch (operator) {
      case '-':
        return () => -operand();
      case '!':
        return () => !(operand() as bool);
      case '~':
        return () => ~operand();
      default:
        throw StateError('Unknown operator: $operator');
    }
  }

  Expression _postfix(
      Expression object, List<({String kind, dynamic arguments})> selectors) {
    for (final selector in selectors) {
      final kind = selector.kind;
      final arguments = selector.arguments;
      switch (kind) {
        case '.':
          final member = arguments as String;
          final object2 = object;
          object = () {
            final object3 = object2();
            if (resolve case final resolve?) {
              return resolve(object3, member);
            } else {
              throw StateError(
                  "Unable to resolve member '$member' for $object3");
            }
          };
          break;
        case '[':
          final index = arguments as dynamic Function();
          final object2 = object;
          object = () {
            final object3 = object2();
            final index2 = index();
            return object3[index2];
          };
          break;
        case '(':
          final object2 = object;
          final arguments2 =
              arguments as List<({String name, Expression expr})>;
          object = () {
            final object3 = object2() as Function;
            final positionalArguments = <dynamic>[];
            final namedArguments = <Symbol, dynamic>{};
            for (final element in arguments2) {
              final name = element.name;
              final expr = element.expr;
              if (name.isEmpty) {
                positionalArguments.add(expr());
              } else {
                if (namedArguments.containsKey(name)) {
                  throw StateError('Duplicate named argument: $name');
                }

                final key = Symbol(name);
                namedArguments[key] = expr();
              }
            }

            return Function.apply(object3, positionalArguments, namedArguments);
          };
          break;
        default:
          throw StateError('Unknown selector: $kind');
      }
    }

    return object;
  }
%%

Start = Spaces v:Expression Eof ;

Expression = Conditional ;

Expression
Conditional =
    e1:IfNull Question e2:Expression Colon e3:Expression { $$ = () => e1() as bool ? e2() : e3(); }
  / IfNull ;

Expression
IfNull = h:LogicalOr t:(op:IfNullOp expr:LogicalOr)* { $$ = t.isEmpty ? h : t.fold(h, _binary); } ;

IfNullOp = v:'??' Spaces ;

Expression
LogicalOr = h:LogicalAnd t:(op:LogicalOrOp expr:LogicalAnd)* { $$ = t.isEmpty ? h : t.fold(h, _binary); } ;

LogicalOrOp = v:'||' Spaces ;

Expression
LogicalAnd = h:Equality t:(op:LogicalAndOp expr:Equality)* { $$ = t.isEmpty ? h : t.fold(h, _binary); } ;

LogicalAndOp = v:'&&' Spaces ;

Expression
Equality = h:Relational t:(op:EqualityOp expr:Relational)* { $$ = t.isEmpty ? h : t.fold(h, _binary); } ;

EqualityOp = v:('==' / '!=') Spaces ;

Expression
Relational = h:BitwiseOr t:(op:RelationalOp expr:BitwiseOr)* { $$ = t.isEmpty ? h : t.fold(h, _binary); } ;

RelationalOp = v:('>=' / '>' / '<=' / '<') Spaces ;

Expression
BitwiseOr = h:BitwiseXor t:(op:BitwiseOrOp expr:BitwiseXor)* { $$ = t.isEmpty ? h : t.fold(h, _binary); } ;

BitwiseOrOp = v:'|' Spaces ;

Expression
BitwiseXor = h:BitwiseAnd t:(op:BitwiseXorOp expr:BitwiseAnd)* { $$ = t.isEmpty ? h : t.fold(h, _binary); } ;

BitwiseXorOp = v:'^' Spaces ;

Expression
BitwiseAnd = h:Shift t:(op:BitwiseAndOp expr:Shift)* { $$ = t.isEmpty ? h : t.fold(h, _binary); } ;

BitwiseAndOp = v:'&' Spaces ;

Expression
Shift = h:Additive t:(op:ShiftOp expr:Additive)* { $$ = t.isEmpty ? h : t.fold(h, _binary); } ;

ShiftOp = v:('<<' / '>>>' / '>>') Spaces ;

Expression
Additive = h:Multiplicative t:(op:AdditiveOp expr:Multiplicative)* { $$ = t.isEmpty ? h : t.fold(h, _binary); } ;

AdditiveOp = v:('-' / '+') Spaces ;

Expression
Multiplicative = h:UnaryPrefix t:(op:MultiplicativeOp expr:UnaryPrefix)* { $$ = t.isEmpty ? h : t.fold(h, _binary); } ;

MultiplicativeOp = v:('/' / '*' / '%' / '~/') Spaces ;

Expression
UnaryPrefix = op:UnaryPrefixOp? expr:UnaryPostfix { $$ = _prefix(op, expr); } ;

UnaryPrefixOp = v:('-' / '!' / '~') Spaces ;

Expression
UnaryPostfix = object:Primary selectors:Selector* { $$ = _postfix(object, selectors); } ;

({String kind, dynamic arguments})
Selector =
    kind:Dot arguments:IdentifierRaw
  / kind:OpenBracket arguments:Expression CloseBracket
  / kind:OpenParenthesis arguments:Arguments CloseParenthesis ;

Arguments = @sepBy((NamedArgument / PositionalArgument), Comma) ;

NamedArgument = name:IdentifierRaw Colon expr:Expression ;

PositionalArgument = name:'' expr:Expression ;

Primary =
    Number
  / Boolean
  / String
  / Null
  / Identifier
  / OpenParenthesis v:Expression CloseParenthesis ;

Expression
Null = 'null' Spaces { $$ = () => null; } ;

Expression
Boolean =
    'true' Spaces { $$ = () => true; }
  / 'false' Spaces { $$ = () => false; } ;

Fraction = @errorHandler([0-9]+, {
    error = const ErrorExpectedTags(['fractional part']);
  }) ;

Exponent = @errorHandler([-+]? [0-9]+, {
    error = const ErrorExpectedTags(['exponent part']);
  }) ;

Expression
NumberRaw = v:$(
  [-]?
  ([0] / [1-9][0-9]*)
  ([.] Fraction)?
  ([eE] Exponent)?
  ) {
    final n = num.parse(v);
    $$ = () => n;
  } ;

Expression
Number = v:@errorHandler(NumberRaw, {
    if (state.failPos != state.pos) {
      error = ErrorMessage(state.pos - state.failPos, 'Malformed number');
    } else {
      rollbackErrors = true;
      error = ErrorExpectedTags(['number']);
    }
  }) Spaces ;

@inline
String
EscapeChar = c:["/bfnrt\\] { $$ = _escape(c); } ;

@inline
String
EscapeHex = 'u' v:HexNumber { $$ = String.fromCharCode(v); } ;

HexNumber = @errorHandler(HexNumberRaw, {
    error = ErrorMessage(state.pos - state.failPos, 'Expected 4 digit hex number');
    rollbackErrors = true;
  }) ;

int
HexNumberRaw = v:$([0-9A-Za-z]{4}) { $$ = int.parse(v, radix: 16); } ;

String
StringChars =
    $[\u{20}-\u{21}\u{23}-\u{5b}\u{5d}-\u{10ffff}]+
  / '\\' v:(EscapeChar / EscapeHex) ;

String
StringRaw = '"' v:StringChars* DoubleQuote { $$ = v.join(); } ;

Expression
String = v:StringRaw { $$ = () => v; } ;

String
IdentifierRaw = v:@errorHandler($([a-zA-Z_$] [a-zA-Z_$0-9]*), {
    if (state.failPos == state.pos) {
      error = const ErrorExpectedTags(['identifier']);
    }
  }) Spaces ;

Expression
Identifier = v:IdentifierRaw {
    $$ = () {
      if (!context.containsKey(v)) {
        throw StateError("Variable '$v' not found");
      }
      return context[v];
    };
  } ;

Eof = !. ;

CloseBracket = v:']' Spaces ;

CloseParenthesis = v:')' Spaces ;

Colon = v:':' Spaces ;

Comma = v:',' Spaces ;

Dot = v:'.' Spaces ;

DoubleQuote = v:'"' Spaces ;

OpenBracket = v:'[' Spaces ;

OpenParenthesis = v:'(' Spaces ;

Question = v:'?' Spaces ;

Spaces = [ \n\r\t]* ;

```
