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

class ExpressionParser {
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

  /// CloseBracket =
  ///   v:']' Spaces
  ///   ;
  void fastParseCloseBracket(State<String> state) {
    // v:']' Spaces
    final $0 = state.pos;
    const $1 = ']';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 93;
    if (state.ok) {
      state.pos++;
    } else {
      state.fail(const ErrorExpectedTags([$1]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
    }
    if (!state.ok) {
      state.pos = $0;
    }
  }

  /// CloseParenthesis =
  ///   v:')' Spaces
  ///   ;
  void fastParseCloseParenthesis(State<String> state) {
    // v:')' Spaces
    final $0 = state.pos;
    const $1 = ')';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 41;
    if (state.ok) {
      state.pos++;
    } else {
      state.fail(const ErrorExpectedTags([$1]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
    }
    if (!state.ok) {
      state.pos = $0;
    }
  }

  /// Colon =
  ///   v:':' Spaces
  ///   ;
  void fastParseColon(State<String> state) {
    // v:':' Spaces
    final $0 = state.pos;
    const $1 = ':';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 58;
    if (state.ok) {
      state.pos++;
    } else {
      state.fail(const ErrorExpectedTags([$1]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
    }
    if (!state.ok) {
      state.pos = $0;
    }
  }

  /// Comma =
  ///   v:',' Spaces
  ///   ;
  void fastParseComma(State<String> state) {
    // v:',' Spaces
    final $0 = state.pos;
    const $1 = ',';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 44;
    if (state.ok) {
      state.pos++;
    } else {
      state.fail(const ErrorExpectedTags([$1]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
    }
    if (!state.ok) {
      state.pos = $0;
    }
  }

  /// DoubleQuote =
  ///   v:'"' Spaces
  ///   ;
  void fastParseDoubleQuote(State<String> state) {
    // v:'"' Spaces
    final $0 = state.pos;
    const $1 = '"';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 34;
    if (state.ok) {
      state.pos++;
    } else {
      state.fail(const ErrorExpectedTags([$1]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
    }
    if (!state.ok) {
      state.pos = $0;
    }
  }

  /// Eof =
  ///   !.
  ///   ;
  void fastParseEof(State<String> state) {
    // !.
    final $1 = state.pos;
    final $4 = state.input;
    if (state.pos < $4.length) {
      final $3 = $4.runeAt(state.pos);
      state.pos += $3 > 0xffff ? 2 : 1;
      state.ok = true;
    } else {
      state.fail(const ErrorUnexpectedEndOfInput());
    }
    state.ok = !state.ok;
    if (!state.ok) {
      final length = $1 - state.pos;
      state.fail(switch (length) {
        0 => const ErrorUnexpectedInput(0),
        1 => const ErrorUnexpectedInput(1),
        2 => const ErrorUnexpectedInput(2),
        _ => ErrorUnexpectedInput(length)
      });
    }
    state.pos = $1;
  }

  /// Exponent =
  ///   @errorHandler([-+]? [0-9]+)
  ///   ;
  void fastParseExponent(State<String> state) {
    // @errorHandler([-+]? [0-9]+)
    final $1 = state.failPos;
    final $2 = state.errorCount;
    // [-+]? [0-9]+
    final $3 = state.pos;
    state.ok = state.pos < state.input.length;
    if (state.ok) {
      final $4 = state.input.codeUnitAt(state.pos);
      state.ok = $4 == 43 || $4 == 45;
      if (state.ok) {
        state.pos++;
      } else {
        state.fail(const ErrorUnexpectedCharacter());
      }
    } else {
      state.fail(const ErrorUnexpectedEndOfInput());
    }
    state.ok = true;
    if (state.ok) {
      final $7 = state.pos;
      final $6 = state.input;
      while (state.pos < $6.length) {
        final $5 = $6.codeUnitAt(state.pos);
        state.ok = $5 >= 48 && $5 <= 57;
        if (!state.ok) {
          break;
        }
        state.pos++;
      }
      state.fail(const ErrorUnexpectedCharacter());
      state.ok = state.pos > $7;
    }
    if (!state.ok) {
      state.pos = $3;
    }
    if (!state.ok && state._canHandleError($1, $2)) {
      ParseError? error;
      // ignore: prefer_final_locals
      var rollbackErrors = false;
      error = const ErrorExpectedTags(['exponent part']);
      if (rollbackErrors == true) {
        state._rollbackErrors($1, $2);
        // ignore: unnecessary_null_comparison, prefer_conditional_assignment
        if (error == null) {
          error = const ErrorUnknownError();
        }
      }
      // ignore: unnecessary_null_comparison
      if (error != null) {
        state.failAt(state.failPos, error);
      }
    }
  }

  /// Fraction =
  ///   @errorHandler([0-9]+)
  ///   ;
  void fastParseFraction(State<String> state) {
    // @errorHandler([0-9]+)
    final $1 = state.failPos;
    final $2 = state.errorCount;
    // [0-9]+
    final $6 = state.pos;
    final $5 = state.input;
    while (state.pos < $5.length) {
      final $4 = $5.codeUnitAt(state.pos);
      state.ok = $4 >= 48 && $4 <= 57;
      if (!state.ok) {
        break;
      }
      state.pos++;
    }
    state.fail(const ErrorUnexpectedCharacter());
    state.ok = state.pos > $6;
    if (!state.ok && state._canHandleError($1, $2)) {
      ParseError? error;
      // ignore: prefer_final_locals
      var rollbackErrors = false;
      error = const ErrorExpectedTags(['fractional part']);
      if (rollbackErrors == true) {
        state._rollbackErrors($1, $2);
        // ignore: unnecessary_null_comparison, prefer_conditional_assignment
        if (error == null) {
          error = const ErrorUnknownError();
        }
      }
      // ignore: unnecessary_null_comparison
      if (error != null) {
        state.failAt(state.failPos, error);
      }
    }
  }

  /// OpenParenthesis =
  ///   v:'(' Spaces
  ///   ;
  void fastParseOpenParenthesis(State<String> state) {
    // v:'(' Spaces
    final $0 = state.pos;
    const $1 = '(';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 40;
    if (state.ok) {
      state.pos++;
    } else {
      state.fail(const ErrorExpectedTags([$1]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
    }
    if (!state.ok) {
      state.pos = $0;
    }
  }

  /// Question =
  ///   v:'?' Spaces
  ///   ;
  void fastParseQuestion(State<String> state) {
    // v:'?' Spaces
    final $0 = state.pos;
    const $1 = '?';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 63;
    if (state.ok) {
      state.pos++;
    } else {
      state.fail(const ErrorExpectedTags([$1]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
    }
    if (!state.ok) {
      state.pos = $0;
    }
  }

  /// Spaces =
  ///   [ \n\r\t]*
  ///   ;
  void fastParseSpaces(State<String> state) {
    // [ \n\r\t]*
    final $2 = state.input;
    while (state.pos < $2.length) {
      final $1 = $2.codeUnitAt(state.pos);
      state.ok = $1 == 13 || $1 >= 9 && $1 <= 10 || $1 == 32;
      if (!state.ok) {
        break;
      }
      state.pos++;
    }
    state.fail(const ErrorUnexpectedCharacter());
    state.ok = true;
  }

  /// Expression
  /// Additive =
  ///   h:Multiplicative t:(op:AdditiveOp expr:Multiplicative)* {}
  ///   ;
  Expression? parseAdditive(State<String> state) {
    Expression? $0;
    // h:Multiplicative t:(op:AdditiveOp expr:Multiplicative)* {}
    final $1 = state.pos;
    Expression? $2;
    // Multiplicative
    $2 = parseMultiplicative(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $3;
      final $4 = <({String op, Expression expr})>[];
      while (true) {
        ({String op, Expression expr})? $5;
        // op:AdditiveOp expr:Multiplicative
        final $6 = state.pos;
        String? $7;
        // AdditiveOp
        $7 = parseAdditiveOp(state);
        if (state.ok) {
          Expression? $8;
          // Multiplicative
          $8 = parseMultiplicative(state);
          if (state.ok) {
            $5 = (op: $7!, expr: $8!);
          }
        }
        if (!state.ok) {
          state.pos = $6;
        }
        if (!state.ok) {
          state.ok = true;
          break;
        }
        $4.add($5!);
      }
      if (state.ok) {
        $3 = $4;
      }
      if (state.ok) {
        Expression? $$;
        final h = $2!;
        final t = $3!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// AdditiveOp =
  ///   v:('-' / '+') Spaces
  ///   ;
  String? parseAdditiveOp(State<String> state) {
    String? $0;
    // v:('-' / '+') Spaces
    final $1 = state.pos;
    String? $2;
    final $7 = state.pos;
    state.ok = false;
    final $4 = state.input;
    if (state.pos < $4.length) {
      final $3 = $4.runeAt(state.pos);
      state.pos += $3 > 0xffff ? 2 : 1;
      switch ($3) {
        case 45:
          state.ok = true;
          $2 = '-';
          break;
        case 43:
          state.ok = true;
          $2 = '+';
          break;
      }
    }
    if (!state.ok) {
      state.pos = $7;
      state.fail(const ErrorExpectedTags(['-', '+']));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Arguments =
  ///   @sepBy((NamedArgument / PositionalArgument), Comma)
  ///   ;
  List<({String name, Expression expr})>? parseArguments(State<String> state) {
    List<({String name, Expression expr})>? $0;
    // @sepBy((NamedArgument / PositionalArgument), Comma)
    final $2 = <({String name, Expression expr})>[];
    var $4 = state.pos;
    while (true) {
      ({String name, Expression expr})? $3;
      // (NamedArgument / PositionalArgument)
      // NamedArgument
      // NamedArgument
      $3 = parseNamedArgument(state);
      if (!state.ok) {
        // PositionalArgument
        // PositionalArgument
        $3 = parsePositionalArgument(state);
      }
      if (!state.ok) {
        state.pos = $4;
        break;
      }
      $2.add($3!);
      $4 = state.pos;
      // Comma
      // Comma
      fastParseComma(state);
      if (!state.ok) {
        break;
      }
    }
    state.ok = true;
    if (state.ok) {
      $0 = $2;
    }
    return $0;
  }

  /// Expression
  /// BitwiseAnd =
  ///   h:Shift t:(op:BitwiseAndOp expr:Shift)* {}
  ///   ;
  Expression? parseBitwiseAnd(State<String> state) {
    Expression? $0;
    // h:Shift t:(op:BitwiseAndOp expr:Shift)* {}
    final $1 = state.pos;
    Expression? $2;
    // Shift
    $2 = parseShift(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $3;
      final $4 = <({String op, Expression expr})>[];
      while (true) {
        ({String op, Expression expr})? $5;
        // op:BitwiseAndOp expr:Shift
        final $6 = state.pos;
        String? $7;
        // BitwiseAndOp
        $7 = parseBitwiseAndOp(state);
        if (state.ok) {
          Expression? $8;
          // Shift
          $8 = parseShift(state);
          if (state.ok) {
            $5 = (op: $7!, expr: $8!);
          }
        }
        if (!state.ok) {
          state.pos = $6;
        }
        if (!state.ok) {
          state.ok = true;
          break;
        }
        $4.add($5!);
      }
      if (state.ok) {
        $3 = $4;
      }
      if (state.ok) {
        Expression? $$;
        final h = $2!;
        final t = $3!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// BitwiseAndOp =
  ///   v:'&' Spaces
  ///   ;
  String? parseBitwiseAndOp(State<String> state) {
    String? $0;
    // v:'&' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '&';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 38;
    if (state.ok) {
      state.pos++;
      $2 = $3;
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Expression
  /// BitwiseOr =
  ///   h:BitwiseXor t:(op:BitwiseOrOp expr:BitwiseXor)* {}
  ///   ;
  Expression? parseBitwiseOr(State<String> state) {
    Expression? $0;
    // h:BitwiseXor t:(op:BitwiseOrOp expr:BitwiseXor)* {}
    final $1 = state.pos;
    Expression? $2;
    // BitwiseXor
    $2 = parseBitwiseXor(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $3;
      final $4 = <({String op, Expression expr})>[];
      while (true) {
        ({String op, Expression expr})? $5;
        // op:BitwiseOrOp expr:BitwiseXor
        final $6 = state.pos;
        String? $7;
        // BitwiseOrOp
        $7 = parseBitwiseOrOp(state);
        if (state.ok) {
          Expression? $8;
          // BitwiseXor
          $8 = parseBitwiseXor(state);
          if (state.ok) {
            $5 = (op: $7!, expr: $8!);
          }
        }
        if (!state.ok) {
          state.pos = $6;
        }
        if (!state.ok) {
          state.ok = true;
          break;
        }
        $4.add($5!);
      }
      if (state.ok) {
        $3 = $4;
      }
      if (state.ok) {
        Expression? $$;
        final h = $2!;
        final t = $3!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// BitwiseOrOp =
  ///   v:'|' Spaces
  ///   ;
  String? parseBitwiseOrOp(State<String> state) {
    String? $0;
    // v:'|' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '|';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 124;
    if (state.ok) {
      state.pos++;
      $2 = $3;
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Expression
  /// BitwiseXor =
  ///   h:BitwiseAnd t:(op:BitwiseXorOp expr:BitwiseAnd)* {}
  ///   ;
  Expression? parseBitwiseXor(State<String> state) {
    Expression? $0;
    // h:BitwiseAnd t:(op:BitwiseXorOp expr:BitwiseAnd)* {}
    final $1 = state.pos;
    Expression? $2;
    // BitwiseAnd
    $2 = parseBitwiseAnd(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $3;
      final $4 = <({String op, Expression expr})>[];
      while (true) {
        ({String op, Expression expr})? $5;
        // op:BitwiseXorOp expr:BitwiseAnd
        final $6 = state.pos;
        String? $7;
        // BitwiseXorOp
        $7 = parseBitwiseXorOp(state);
        if (state.ok) {
          Expression? $8;
          // BitwiseAnd
          $8 = parseBitwiseAnd(state);
          if (state.ok) {
            $5 = (op: $7!, expr: $8!);
          }
        }
        if (!state.ok) {
          state.pos = $6;
        }
        if (!state.ok) {
          state.ok = true;
          break;
        }
        $4.add($5!);
      }
      if (state.ok) {
        $3 = $4;
      }
      if (state.ok) {
        Expression? $$;
        final h = $2!;
        final t = $3!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// BitwiseXorOp =
  ///   v:'^' Spaces
  ///   ;
  String? parseBitwiseXorOp(State<String> state) {
    String? $0;
    // v:'^' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '^';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 94;
    if (state.ok) {
      state.pos++;
      $2 = $3;
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Expression
  /// Boolean =
  ///     'true' Spaces {}
  ///   / 'false' Spaces {}
  ///   ;
  Expression? parseBoolean(State<String> state) {
    Expression? $0;
    // 'true' Spaces {}
    final $1 = state.pos;
    const $2 = 'true';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 116 &&
        state.input.startsWith($2, state.pos);
    if (state.ok) {
      state.pos += 4;
    } else {
      state.fail(const ErrorExpectedTags([$2]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        Expression? $$;
        $$ = () => true;
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    if (!state.ok) {
      // 'false' Spaces {}
      final $3 = state.pos;
      const $4 = 'false';
      state.ok = state.pos < state.input.length &&
          state.input.codeUnitAt(state.pos) == 102 &&
          state.input.startsWith($4, state.pos);
      if (state.ok) {
        state.pos += 5;
      } else {
        state.fail(const ErrorExpectedTags([$4]));
      }
      if (state.ok) {
        // Spaces
        fastParseSpaces(state);
        if (state.ok) {
          Expression? $$;
          $$ = () => false;
          $0 = $$;
        }
      }
      if (!state.ok) {
        state.pos = $3;
      }
    }
    return $0;
  }

  /// Expression
  /// Conditional =
  ///     e1:IfNull Question e2:Expression Colon e3:Expression {}
  ///   / IfNull
  ///   ;
  Expression? parseConditional(State<String> state) {
    Expression? $0;
    // e1:IfNull Question e2:Expression Colon e3:Expression {}
    final $1 = state.pos;
    Expression? $2;
    // IfNull
    $2 = parseIfNull(state);
    if (state.ok) {
      // Question
      fastParseQuestion(state);
      if (state.ok) {
        Expression? $3;
        // Expression
        $3 = parseExpression(state);
        if (state.ok) {
          // Colon
          fastParseColon(state);
          if (state.ok) {
            Expression? $4;
            // Expression
            $4 = parseExpression(state);
            if (state.ok) {
              Expression? $$;
              final e1 = $2!;
              final e2 = $3!;
              final e3 = $4!;
              $$ = () => e1() as bool ? e2() : e3();
              $0 = $$;
            }
          }
        }
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    if (!state.ok) {
      // IfNull
      // IfNull
      $0 = parseIfNull(state);
    }
    return $0;
  }

  /// Dot =
  ///   v:'.' Spaces
  ///   ;
  String? parseDot(State<String> state) {
    String? $0;
    // v:'.' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '.';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 46;
    if (state.ok) {
      state.pos++;
      $2 = $3;
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Expression
  /// Equality =
  ///   h:Relational t:(op:EqualityOp expr:Relational)* {}
  ///   ;
  Expression? parseEquality(State<String> state) {
    Expression? $0;
    // h:Relational t:(op:EqualityOp expr:Relational)* {}
    final $1 = state.pos;
    Expression? $2;
    // Relational
    $2 = parseRelational(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $3;
      final $4 = <({String op, Expression expr})>[];
      while (true) {
        ({String op, Expression expr})? $5;
        // op:EqualityOp expr:Relational
        final $6 = state.pos;
        String? $7;
        // EqualityOp
        $7 = parseEqualityOp(state);
        if (state.ok) {
          Expression? $8;
          // Relational
          $8 = parseRelational(state);
          if (state.ok) {
            $5 = (op: $7!, expr: $8!);
          }
        }
        if (!state.ok) {
          state.pos = $6;
        }
        if (!state.ok) {
          state.ok = true;
          break;
        }
        $4.add($5!);
      }
      if (state.ok) {
        $3 = $4;
      }
      if (state.ok) {
        Expression? $$;
        final h = $2!;
        final t = $3!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// EqualityOp =
  ///   v:('==' / '!=') Spaces
  ///   ;
  String? parseEqualityOp(State<String> state) {
    String? $0;
    // v:('==' / '!=') Spaces
    final $1 = state.pos;
    String? $2;
    final $7 = state.pos;
    state.ok = false;
    final $4 = state.input;
    if (state.pos < $4.length) {
      final $3 = $4.runeAt(state.pos);
      state.pos += $3 > 0xffff ? 2 : 1;
      switch ($3) {
        case 61:
          state.ok = state.pos < $4.length && $4.runeAt(state.pos) == 61;
          if (state.ok) {
            state.pos += 1;
            $2 = '==';
          }
          break;
        case 33:
          state.ok = state.pos < $4.length && $4.runeAt(state.pos) == 61;
          if (state.ok) {
            state.pos += 1;
            $2 = '!=';
          }
          break;
      }
    }
    if (!state.ok) {
      state.pos = $7;
      state.fail(const ErrorExpectedTags(['==', '!=']));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Expression =
  ///   Conditional
  ///   ;
  Expression? parseExpression(State<String> state) {
    Expression? $0;
    // Conditional
    // Conditional
    $0 = parseConditional(state);
    return $0;
  }

  /// HexNumber =
  ///   @errorHandler(HexNumberRaw)
  ///   ;
  int? parseHexNumber(State<String> state) {
    int? $0;
    // @errorHandler(HexNumberRaw)
    final $2 = state.failPos;
    final $3 = state.errorCount;
    // HexNumberRaw
    // HexNumberRaw
    $0 = parseHexNumberRaw(state);
    if (!state.ok && state._canHandleError($2, $3)) {
      ParseError? error;
      // ignore: prefer_final_locals
      var rollbackErrors = false;
      error = ErrorMessage(
          state.pos - state.failPos, 'Expected 4 digit hex number');
      rollbackErrors = true;
      if (rollbackErrors == true) {
        state._rollbackErrors($2, $3);
        // ignore: unnecessary_null_comparison, prefer_conditional_assignment
        if (error == null) {
          error = const ErrorUnknownError();
        }
      }
      // ignore: unnecessary_null_comparison
      if (error != null) {
        state.failAt(state.failPos, error);
      }
    }
    return $0;
  }

  /// int
  /// HexNumberRaw =
  ///   v:$([0-9A-Za-z]{4,4}) {}
  ///   ;
  int? parseHexNumberRaw(State<String> state) {
    int? $0;
    // v:$([0-9A-Za-z]{4,4}) {}
    String? $2;
    final $3 = state.pos;
    // [0-9A-Za-z]{4,4}
    final $5 = state.pos;
    var $6 = 0;
    while ($6 < 4) {
      state.ok = state.pos < state.input.length;
      if (state.ok) {
        final $7 = state.input.codeUnitAt(state.pos);
        state.ok =
            $7 <= 90 ? $7 >= 48 && $7 <= 57 || $7 >= 65 : $7 >= 97 && $7 <= 122;
        if (state.ok) {
          state.pos++;
        } else {
          state.fail(const ErrorUnexpectedCharacter());
        }
      } else {
        state.fail(const ErrorUnexpectedEndOfInput());
      }
      if (!state.ok) {
        break;
      }
      $6++;
    }
    state.ok = $6 == 4;
    if (!state.ok) {
      state.pos = $5;
    }
    if (state.ok) {
      $2 = state.input.substring($3, state.pos);
    }
    if (state.ok) {
      int? $$;
      final v = $2!;
      $$ = int.parse(v, radix: 16);
      $0 = $$;
    }
    return $0;
  }

  /// Expression
  /// Identifier =
  ///   v:IdentifierRaw {}
  ///   ;
  Expression? parseIdentifier(State<String> state) {
    Expression? $0;
    // v:IdentifierRaw {}
    String? $2;
    // IdentifierRaw
    $2 = parseIdentifierRaw(state);
    if (state.ok) {
      Expression? $$;
      final v = $2!;
      $$ = () {
        if (!context.containsKey(v)) {
          throw StateError("Variable '$v' not found");
        }
        return context[v];
      };
      $0 = $$;
    }
    return $0;
  }

  /// String
  /// IdentifierRaw =
  ///   v:@errorHandler($([a-zA-Z_$] [a-zA-Z_$0-9]*)) Spaces
  ///   ;
  String? parseIdentifierRaw(State<String> state) {
    String? $0;
    // v:@errorHandler($([a-zA-Z_$] [a-zA-Z_$0-9]*)) Spaces
    final $1 = state.pos;
    String? $2;
    final $3 = state.failPos;
    final $4 = state.errorCount;
    // $([a-zA-Z_$] [a-zA-Z_$0-9]*)
    final $6 = state.pos;
    // [a-zA-Z_$] [a-zA-Z_$0-9]*
    final $7 = state.pos;
    state.ok = state.pos < state.input.length;
    if (state.ok) {
      final $8 = state.input.codeUnitAt(state.pos);
      state.ok =
          $8 <= 90 ? $8 == 36 || $8 >= 65 : $8 == 95 || $8 >= 97 && $8 <= 122;
      if (state.ok) {
        state.pos++;
      } else {
        state.fail(const ErrorUnexpectedCharacter());
      }
    } else {
      state.fail(const ErrorUnexpectedEndOfInput());
    }
    if (state.ok) {
      final $10 = state.input;
      while (state.pos < $10.length) {
        final $9 = $10.codeUnitAt(state.pos);
        state.ok = $9 <= 90
            ? $9 <= 57
                ? $9 == 36 || $9 >= 48
                : $9 >= 65
            : $9 == 95 || $9 >= 97 && $9 <= 122;
        if (!state.ok) {
          break;
        }
        state.pos++;
      }
      state.fail(const ErrorUnexpectedCharacter());
      state.ok = true;
    }
    if (!state.ok) {
      state.pos = $7;
    }
    if (state.ok) {
      $2 = state.input.substring($6, state.pos);
    }
    if (!state.ok && state._canHandleError($3, $4)) {
      ParseError? error;
      // ignore: prefer_final_locals
      var rollbackErrors = false;
      if (state.failPos == state.pos) {
        error = const ErrorExpectedTags(['identifier']);
      }
      if (rollbackErrors == true) {
        state._rollbackErrors($3, $4);
        // ignore: unnecessary_null_comparison, prefer_conditional_assignment
        if (error == null) {
          error = const ErrorUnknownError();
        }
      }
      // ignore: unnecessary_null_comparison
      if (error != null) {
        state.failAt(state.failPos, error);
      }
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Expression
  /// IfNull =
  ///   h:LogicalOr t:(op:IfNullOp expr:LogicalOr)* {}
  ///   ;
  Expression? parseIfNull(State<String> state) {
    Expression? $0;
    // h:LogicalOr t:(op:IfNullOp expr:LogicalOr)* {}
    final $1 = state.pos;
    Expression? $2;
    // LogicalOr
    $2 = parseLogicalOr(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $3;
      final $4 = <({String op, Expression expr})>[];
      while (true) {
        ({String op, Expression expr})? $5;
        // op:IfNullOp expr:LogicalOr
        final $6 = state.pos;
        String? $7;
        // IfNullOp
        $7 = parseIfNullOp(state);
        if (state.ok) {
          Expression? $8;
          // LogicalOr
          $8 = parseLogicalOr(state);
          if (state.ok) {
            $5 = (op: $7!, expr: $8!);
          }
        }
        if (!state.ok) {
          state.pos = $6;
        }
        if (!state.ok) {
          state.ok = true;
          break;
        }
        $4.add($5!);
      }
      if (state.ok) {
        $3 = $4;
      }
      if (state.ok) {
        Expression? $$;
        final h = $2!;
        final t = $3!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// IfNullOp =
  ///   v:'??' Spaces
  ///   ;
  String? parseIfNullOp(State<String> state) {
    String? $0;
    // v:'??' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '??';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 63 &&
        state.input.startsWith($3, state.pos);
    if (state.ok) {
      state.pos += 2;
      $2 = $3;
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Expression
  /// LogicalAnd =
  ///   h:Equality t:(op:LogicalAndOp expr:Equality)* {}
  ///   ;
  Expression? parseLogicalAnd(State<String> state) {
    Expression? $0;
    // h:Equality t:(op:LogicalAndOp expr:Equality)* {}
    final $1 = state.pos;
    Expression? $2;
    // Equality
    $2 = parseEquality(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $3;
      final $4 = <({String op, Expression expr})>[];
      while (true) {
        ({String op, Expression expr})? $5;
        // op:LogicalAndOp expr:Equality
        final $6 = state.pos;
        String? $7;
        // LogicalAndOp
        $7 = parseLogicalAndOp(state);
        if (state.ok) {
          Expression? $8;
          // Equality
          $8 = parseEquality(state);
          if (state.ok) {
            $5 = (op: $7!, expr: $8!);
          }
        }
        if (!state.ok) {
          state.pos = $6;
        }
        if (!state.ok) {
          state.ok = true;
          break;
        }
        $4.add($5!);
      }
      if (state.ok) {
        $3 = $4;
      }
      if (state.ok) {
        Expression? $$;
        final h = $2!;
        final t = $3!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// LogicalAndOp =
  ///   v:'&&' Spaces
  ///   ;
  String? parseLogicalAndOp(State<String> state) {
    String? $0;
    // v:'&&' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '&&';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 38 &&
        state.input.startsWith($3, state.pos);
    if (state.ok) {
      state.pos += 2;
      $2 = $3;
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Expression
  /// LogicalOr =
  ///   h:LogicalAnd t:(op:LogicalOrOp expr:LogicalAnd)* {}
  ///   ;
  Expression? parseLogicalOr(State<String> state) {
    Expression? $0;
    // h:LogicalAnd t:(op:LogicalOrOp expr:LogicalAnd)* {}
    final $1 = state.pos;
    Expression? $2;
    // LogicalAnd
    $2 = parseLogicalAnd(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $3;
      final $4 = <({String op, Expression expr})>[];
      while (true) {
        ({String op, Expression expr})? $5;
        // op:LogicalOrOp expr:LogicalAnd
        final $6 = state.pos;
        String? $7;
        // LogicalOrOp
        $7 = parseLogicalOrOp(state);
        if (state.ok) {
          Expression? $8;
          // LogicalAnd
          $8 = parseLogicalAnd(state);
          if (state.ok) {
            $5 = (op: $7!, expr: $8!);
          }
        }
        if (!state.ok) {
          state.pos = $6;
        }
        if (!state.ok) {
          state.ok = true;
          break;
        }
        $4.add($5!);
      }
      if (state.ok) {
        $3 = $4;
      }
      if (state.ok) {
        Expression? $$;
        final h = $2!;
        final t = $3!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// LogicalOrOp =
  ///   v:'||' Spaces
  ///   ;
  String? parseLogicalOrOp(State<String> state) {
    String? $0;
    // v:'||' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '||';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 124 &&
        state.input.startsWith($3, state.pos);
    if (state.ok) {
      state.pos += 2;
      $2 = $3;
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Expression
  /// Multiplicative =
  ///   h:UnaryPrefix t:(op:MultiplicativeOp expr:UnaryPrefix)* {}
  ///   ;
  Expression? parseMultiplicative(State<String> state) {
    Expression? $0;
    // h:UnaryPrefix t:(op:MultiplicativeOp expr:UnaryPrefix)* {}
    final $1 = state.pos;
    Expression? $2;
    // UnaryPrefix
    $2 = parseUnaryPrefix(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $3;
      final $4 = <({String op, Expression expr})>[];
      while (true) {
        ({String op, Expression expr})? $5;
        // op:MultiplicativeOp expr:UnaryPrefix
        final $6 = state.pos;
        String? $7;
        // MultiplicativeOp
        $7 = parseMultiplicativeOp(state);
        if (state.ok) {
          Expression? $8;
          // UnaryPrefix
          $8 = parseUnaryPrefix(state);
          if (state.ok) {
            $5 = (op: $7!, expr: $8!);
          }
        }
        if (!state.ok) {
          state.pos = $6;
        }
        if (!state.ok) {
          state.ok = true;
          break;
        }
        $4.add($5!);
      }
      if (state.ok) {
        $3 = $4;
      }
      if (state.ok) {
        Expression? $$;
        final h = $2!;
        final t = $3!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// MultiplicativeOp =
  ///   v:('/' / '*' / '%' / '~/') Spaces
  ///   ;
  String? parseMultiplicativeOp(State<String> state) {
    String? $0;
    // v:('/' / '*' / '%' / '~/') Spaces
    final $1 = state.pos;
    String? $2;
    final $9 = state.pos;
    state.ok = false;
    final $4 = state.input;
    if (state.pos < $4.length) {
      final $3 = $4.runeAt(state.pos);
      state.pos += $3 > 0xffff ? 2 : 1;
      switch ($3) {
        case 47:
          state.ok = true;
          $2 = '/';
          break;
        case 42:
          state.ok = true;
          $2 = '*';
          break;
        case 37:
          state.ok = true;
          $2 = '%';
          break;
        case 126:
          state.ok = state.pos < $4.length && $4.runeAt(state.pos) == 47;
          if (state.ok) {
            state.pos += 1;
            $2 = '~/';
          }
          break;
      }
    }
    if (!state.ok) {
      state.pos = $9;
      state.fail(const ErrorExpectedTags(['/', '*', '%', '~/']));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// NamedArgument =
  ///   name:IdentifierRaw Colon expr:Expression
  ///   ;
  ({String name, Expression expr})? parseNamedArgument(State<String> state) {
    ({String name, Expression expr})? $0;
    // name:IdentifierRaw Colon expr:Expression
    final $1 = state.pos;
    String? $2;
    // IdentifierRaw
    $2 = parseIdentifierRaw(state);
    if (state.ok) {
      // Colon
      fastParseColon(state);
      if (state.ok) {
        Expression? $3;
        // Expression
        $3 = parseExpression(state);
        if (state.ok) {
          $0 = (name: $2!, expr: $3!);
        }
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Expression
  /// Null =
  ///   'null' Spaces {}
  ///   ;
  Expression? parseNull(State<String> state) {
    Expression? $0;
    // 'null' Spaces {}
    final $1 = state.pos;
    const $2 = 'null';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 110 &&
        state.input.startsWith($2, state.pos);
    if (state.ok) {
      state.pos += 4;
    } else {
      state.fail(const ErrorExpectedTags([$2]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        Expression? $$;
        $$ = () => null;
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Expression
  /// Number =
  ///   v:@errorHandler(NumberRaw) Spaces
  ///   ;
  Expression? parseNumber(State<String> state) {
    Expression? $0;
    // v:@errorHandler(NumberRaw) Spaces
    final $1 = state.pos;
    Expression? $2;
    final $3 = state.failPos;
    final $4 = state.errorCount;
    // NumberRaw
    // NumberRaw
    $2 = parseNumberRaw(state);
    if (!state.ok && state._canHandleError($3, $4)) {
      ParseError? error;
      // ignore: prefer_final_locals
      var rollbackErrors = false;
      if (state.failPos != state.pos) {
        error = ErrorMessage(state.pos - state.failPos, 'Malformed number');
      } else {
        rollbackErrors = true;
        error = ErrorExpectedTags(['number']);
      }
      if (rollbackErrors == true) {
        state._rollbackErrors($3, $4);
        // ignore: unnecessary_null_comparison, prefer_conditional_assignment
        if (error == null) {
          error = const ErrorUnknownError();
        }
      }
      // ignore: unnecessary_null_comparison
      if (error != null) {
        state.failAt(state.failPos, error);
      }
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Expression
  /// NumberRaw =
  ///   v:$([-]? ([0] / [1-9] [0-9]*) ([.] Fraction)? ([eE] Exponent)?) {}
  ///   ;
  Expression? parseNumberRaw(State<String> state) {
    Expression? $0;
    // v:$([-]? ([0] / [1-9] [0-9]*) ([.] Fraction)? ([eE] Exponent)?) {}
    String? $2;
    final $3 = state.pos;
    // [-]? ([0] / [1-9] [0-9]*) ([.] Fraction)? ([eE] Exponent)?
    final $4 = state.pos;
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 45;
    if (state.ok) {
      state.pos++;
    } else {
      state.fail(const ErrorExpectedCharacter(45));
    }
    state.ok = true;
    if (state.ok) {
      // [0]
      state.ok = state.pos < state.input.length &&
          state.input.codeUnitAt(state.pos) == 48;
      if (state.ok) {
        state.pos++;
      } else {
        state.fail(const ErrorExpectedCharacter(48));
      }
      if (!state.ok) {
        // [1-9] [0-9]*
        final $6 = state.pos;
        state.ok = state.pos < state.input.length;
        if (state.ok) {
          final $7 = state.input.codeUnitAt(state.pos);
          state.ok = $7 >= 49 && $7 <= 57;
          if (state.ok) {
            state.pos++;
          } else {
            state.fail(const ErrorUnexpectedCharacter());
          }
        } else {
          state.fail(const ErrorUnexpectedEndOfInput());
        }
        if (state.ok) {
          final $9 = state.input;
          while (state.pos < $9.length) {
            final $8 = $9.codeUnitAt(state.pos);
            state.ok = $8 >= 48 && $8 <= 57;
            if (!state.ok) {
              break;
            }
            state.pos++;
          }
          state.fail(const ErrorUnexpectedCharacter());
          state.ok = true;
        }
        if (!state.ok) {
          state.pos = $6;
        }
      }
      if (state.ok) {
        // [.] Fraction
        final $10 = state.pos;
        state.ok = state.pos < state.input.length &&
            state.input.codeUnitAt(state.pos) == 46;
        if (state.ok) {
          state.pos++;
        } else {
          state.fail(const ErrorExpectedCharacter(46));
        }
        if (state.ok) {
          // Fraction
          fastParseFraction(state);
        }
        if (!state.ok) {
          state.pos = $10;
        }
        state.ok = true;
        if (state.ok) {
          // [eE] Exponent
          final $11 = state.pos;
          state.ok = state.pos < state.input.length;
          if (state.ok) {
            final $12 = state.input.codeUnitAt(state.pos);
            state.ok = $12 == 69 || $12 == 101;
            if (state.ok) {
              state.pos++;
            } else {
              state.fail(const ErrorUnexpectedCharacter());
            }
          } else {
            state.fail(const ErrorUnexpectedEndOfInput());
          }
          if (state.ok) {
            // Exponent
            fastParseExponent(state);
          }
          if (!state.ok) {
            state.pos = $11;
          }
          state.ok = true;
        }
      }
    }
    if (!state.ok) {
      state.pos = $4;
    }
    if (state.ok) {
      $2 = state.input.substring($3, state.pos);
    }
    if (state.ok) {
      Expression? $$;
      final v = $2!;
      final n = num.parse(v);
      $$ = () => n;
      $0 = $$;
    }
    return $0;
  }

  /// OpenBracket =
  ///   v:'[' Spaces
  ///   ;
  String? parseOpenBracket(State<String> state) {
    String? $0;
    // v:'[' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '[';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 91;
    if (state.ok) {
      state.pos++;
      $2 = $3;
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// OpenParenthesis =
  ///   v:'(' Spaces
  ///   ;
  String? parseOpenParenthesis(State<String> state) {
    String? $0;
    // v:'(' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '(';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 40;
    if (state.ok) {
      state.pos++;
      $2 = $3;
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// PositionalArgument =
  ///   name:'' expr:Expression
  ///   ;
  ({String name, Expression expr})? parsePositionalArgument(
      State<String> state) {
    ({String name, Expression expr})? $0;
    // name:'' expr:Expression
    final $1 = state.pos;
    String? $2;
    state.ok = true;
    if (state.ok) {
      $2 = '';
    }
    if (state.ok) {
      Expression? $3;
      // Expression
      $3 = parseExpression(state);
      if (state.ok) {
        $0 = (name: $2!, expr: $3!);
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Primary =
  ///     Number
  ///   / Boolean
  ///   / String
  ///   / Null
  ///   / Identifier
  ///   / OpenParenthesis v:Expression CloseParenthesis
  ///   ;
  Expression? parsePrimary(State<String> state) {
    Expression? $0;
    // Number
    // Number
    $0 = parseNumber(state);
    if (!state.ok) {
      // Boolean
      // Boolean
      $0 = parseBoolean(state);
      if (!state.ok) {
        // String
        // String
        $0 = parseString(state);
        if (!state.ok) {
          // Null
          // Null
          $0 = parseNull(state);
          if (!state.ok) {
            // Identifier
            // Identifier
            $0 = parseIdentifier(state);
            if (!state.ok) {
              // OpenParenthesis v:Expression CloseParenthesis
              final $6 = state.pos;
              // OpenParenthesis
              fastParseOpenParenthesis(state);
              if (state.ok) {
                Expression? $7;
                // Expression
                $7 = parseExpression(state);
                if (state.ok) {
                  // CloseParenthesis
                  fastParseCloseParenthesis(state);
                  if (state.ok) {
                    $0 = $7;
                  }
                }
              }
              if (!state.ok) {
                state.pos = $6;
              }
            }
          }
        }
      }
    }
    return $0;
  }

  /// Expression
  /// Relational =
  ///   h:BitwiseOr t:(op:RelationalOp expr:BitwiseOr)* {}
  ///   ;
  Expression? parseRelational(State<String> state) {
    Expression? $0;
    // h:BitwiseOr t:(op:RelationalOp expr:BitwiseOr)* {}
    final $1 = state.pos;
    Expression? $2;
    // BitwiseOr
    $2 = parseBitwiseOr(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $3;
      final $4 = <({String op, Expression expr})>[];
      while (true) {
        ({String op, Expression expr})? $5;
        // op:RelationalOp expr:BitwiseOr
        final $6 = state.pos;
        String? $7;
        // RelationalOp
        $7 = parseRelationalOp(state);
        if (state.ok) {
          Expression? $8;
          // BitwiseOr
          $8 = parseBitwiseOr(state);
          if (state.ok) {
            $5 = (op: $7!, expr: $8!);
          }
        }
        if (!state.ok) {
          state.pos = $6;
        }
        if (!state.ok) {
          state.ok = true;
          break;
        }
        $4.add($5!);
      }
      if (state.ok) {
        $3 = $4;
      }
      if (state.ok) {
        Expression? $$;
        final h = $2!;
        final t = $3!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// RelationalOp =
  ///   v:('>=' / '>' / '<=' / '<') Spaces
  ///   ;
  String? parseRelationalOp(State<String> state) {
    String? $0;
    // v:('>=' / '>' / '<=' / '<') Spaces
    final $1 = state.pos;
    String? $2;
    final $9 = state.pos;
    state.ok = false;
    final $4 = state.input;
    if (state.pos < $4.length) {
      final $3 = $4.runeAt(state.pos);
      state.pos += $3 > 0xffff ? 2 : 1;
      switch ($3) {
        case 62:
          state.ok = state.pos < $4.length && $4.runeAt(state.pos) == 61;
          if (state.ok) {
            state.pos += 1;
            $2 = '>=';
          } else {
            state.ok = true;
            $2 = '>';
          }
          break;
        case 60:
          state.ok = state.pos < $4.length && $4.runeAt(state.pos) == 61;
          if (state.ok) {
            state.pos += 1;
            $2 = '<=';
          } else {
            state.ok = true;
            $2 = '<';
          }
          break;
      }
    }
    if (!state.ok) {
      state.pos = $9;
      state.fail(const ErrorExpectedTags(['>=', '>', '<=', '<']));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// ({String kind, dynamic arguments})
  /// Selector =
  ///     kind:Dot arguments:IdentifierRaw
  ///   / kind:OpenBracket arguments:Expression CloseBracket
  ///   / kind:OpenParenthesis arguments:Arguments CloseParenthesis
  ///   ;
  ({String kind, dynamic arguments})? parseSelector(State<String> state) {
    ({String kind, dynamic arguments})? $0;
    // kind:Dot arguments:IdentifierRaw
    final $1 = state.pos;
    String? $2;
    // Dot
    $2 = parseDot(state);
    if (state.ok) {
      String? $3;
      // IdentifierRaw
      $3 = parseIdentifierRaw(state);
      if (state.ok) {
        $0 = (kind: $2!, arguments: $3!);
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    if (!state.ok) {
      // kind:OpenBracket arguments:Expression CloseBracket
      final $4 = state.pos;
      String? $5;
      // OpenBracket
      $5 = parseOpenBracket(state);
      if (state.ok) {
        Expression? $6;
        // Expression
        $6 = parseExpression(state);
        if (state.ok) {
          // CloseBracket
          fastParseCloseBracket(state);
          if (state.ok) {
            $0 = (kind: $5!, arguments: $6!);
          }
        }
      }
      if (!state.ok) {
        state.pos = $4;
      }
      if (!state.ok) {
        // kind:OpenParenthesis arguments:Arguments CloseParenthesis
        final $7 = state.pos;
        String? $8;
        // OpenParenthesis
        $8 = parseOpenParenthesis(state);
        if (state.ok) {
          List<({String name, Expression expr})>? $9;
          // Arguments
          $9 = parseArguments(state);
          if (state.ok) {
            // CloseParenthesis
            fastParseCloseParenthesis(state);
            if (state.ok) {
              $0 = (kind: $8!, arguments: $9!);
            }
          }
        }
        if (!state.ok) {
          state.pos = $7;
        }
      }
    }
    return $0;
  }

  /// Expression
  /// Shift =
  ///   h:Additive t:(op:ShiftOp expr:Additive)* {}
  ///   ;
  Expression? parseShift(State<String> state) {
    Expression? $0;
    // h:Additive t:(op:ShiftOp expr:Additive)* {}
    final $1 = state.pos;
    Expression? $2;
    // Additive
    $2 = parseAdditive(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $3;
      final $4 = <({String op, Expression expr})>[];
      while (true) {
        ({String op, Expression expr})? $5;
        // op:ShiftOp expr:Additive
        final $6 = state.pos;
        String? $7;
        // ShiftOp
        $7 = parseShiftOp(state);
        if (state.ok) {
          Expression? $8;
          // Additive
          $8 = parseAdditive(state);
          if (state.ok) {
            $5 = (op: $7!, expr: $8!);
          }
        }
        if (!state.ok) {
          state.pos = $6;
        }
        if (!state.ok) {
          state.ok = true;
          break;
        }
        $4.add($5!);
      }
      if (state.ok) {
        $3 = $4;
      }
      if (state.ok) {
        Expression? $$;
        final h = $2!;
        final t = $3!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// ShiftOp =
  ///   v:('<<' / '>>>' / '>>') Spaces
  ///   ;
  String? parseShiftOp(State<String> state) {
    String? $0;
    // v:('<<' / '>>>' / '>>') Spaces
    final $1 = state.pos;
    String? $2;
    final $8 = state.pos;
    state.ok = false;
    final $4 = state.input;
    if (state.pos < $4.length) {
      final $3 = $4.runeAt(state.pos);
      state.pos += $3 > 0xffff ? 2 : 1;
      switch ($3) {
        case 60:
          state.ok = state.pos < $4.length && $4.runeAt(state.pos) == 60;
          if (state.ok) {
            state.pos += 1;
            $2 = '<<';
          }
          break;
        case 62:
          const $6 = '>>>';
          state.ok = $4.startsWith($6, state.pos - 1);
          if (state.ok) {
            state.pos += 2;
            $2 = $6;
          } else {
            state.ok = state.pos < $4.length && $4.runeAt(state.pos) == 62;
            if (state.ok) {
              state.pos += 1;
              $2 = '>>';
            }
          }
          break;
      }
    }
    if (!state.ok) {
      state.pos = $8;
      state.fail(const ErrorExpectedTags(['<<', '>>>', '>>']));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Start =
  ///   Spaces v:Expression Eof
  ///   ;
  Expression? parseStart(State<String> state) {
    Expression? $0;
    // Spaces v:Expression Eof
    final $1 = state.pos;
    // Spaces
    fastParseSpaces(state);
    if (state.ok) {
      Expression? $2;
      // Expression
      $2 = parseExpression(state);
      if (state.ok) {
        // Eof
        fastParseEof(state);
        if (state.ok) {
          $0 = $2;
        }
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Expression
  /// String =
  ///   v:StringRaw {}
  ///   ;
  Expression? parseString(State<String> state) {
    Expression? $0;
    // v:StringRaw {}
    String? $2;
    // StringRaw
    $2 = parseStringRaw(state);
    if (state.ok) {
      Expression? $$;
      final v = $2!;
      $$ = () => v;
      $0 = $$;
    }
    return $0;
  }

  /// String
  /// StringChars =
  ///     $[ -!#-[\]-\u{10ffff}]+
  ///   / '\\' v:(EscapeChar / EscapeHex)
  ///   ;
  String? parseStringChars(State<String> state) {
    String? $0;
    // $[ -!#-[\]-\u{10ffff}]+
    final $2 = state.pos;
    final $5 = state.pos;
    final $4 = state.input;
    while (state.pos < $4.length) {
      final $3 = $4.runeAt(state.pos);
      state.ok = $3 <= 91
          ? $3 >= 32 && $3 <= 33 || $3 >= 35
          : $3 >= 93 && $3 <= 1114111;
      if (!state.ok) {
        break;
      }
      state.pos += $3 > 0xffff ? 2 : 1;
    }
    state.fail(const ErrorUnexpectedCharacter());
    state.ok = state.pos > $5;
    if (state.ok) {
      $0 = state.input.substring($2, state.pos);
    }
    if (!state.ok) {
      // '\\' v:(EscapeChar / EscapeHex)
      final $6 = state.pos;
      const $8 = '\\';
      state.ok = state.pos < state.input.length &&
          state.input.codeUnitAt(state.pos) == 92;
      if (state.ok) {
        state.pos++;
      } else {
        state.fail(const ErrorExpectedTags([$8]));
      }
      if (state.ok) {
        String? $7;
        // EscapeChar
        // String @inline EscapeChar = c:["/bfnrt\\] {} ;
        // c:["/bfnrt\\] {}
        int? $11;
        state.ok = state.pos < state.input.length;
        if (state.ok) {
          final $12 = state.input.codeUnitAt(state.pos);
          state.ok = $12 == 98 ||
              ($12 < 98
                  ? $12 == 47 || $12 == 34 || $12 == 92
                  : $12 == 110 ||
                      ($12 < 110 ? $12 == 102 : $12 == 114 || $12 == 116));
          if (state.ok) {
            state.pos++;
            $11 = $12;
          } else {
            state.fail(const ErrorUnexpectedCharacter());
          }
        } else {
          state.fail(const ErrorUnexpectedEndOfInput());
        }
        if (state.ok) {
          String? $$;
          final c = $11!;
          $$ = _escape(c);
          $7 = $$;
        }
        if (!state.ok) {
          // EscapeHex
          // String @inline EscapeHex = 'u' v:HexNumber {} ;
          // 'u' v:HexNumber {}
          final $14 = state.pos;
          const $16 = 'u';
          state.ok = state.pos < state.input.length &&
              state.input.codeUnitAt(state.pos) == 117;
          if (state.ok) {
            state.pos++;
          } else {
            state.fail(const ErrorExpectedTags([$16]));
          }
          if (state.ok) {
            int? $15;
            // HexNumber
            $15 = parseHexNumber(state);
            if (state.ok) {
              String? $$;
              final v = $15!;
              $$ = String.fromCharCode(v);
              $7 = $$;
            }
          }
          if (!state.ok) {
            state.pos = $14;
          }
        }
        if (state.ok) {
          $0 = $7;
        }
      }
      if (!state.ok) {
        state.pos = $6;
      }
    }
    return $0;
  }

  /// String
  /// StringRaw =
  ///   '"' v:StringChars* DoubleQuote {}
  ///   ;
  String? parseStringRaw(State<String> state) {
    String? $0;
    // '"' v:StringChars* DoubleQuote {}
    final $1 = state.pos;
    const $3 = '"';
    state.ok = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 34;
    if (state.ok) {
      state.pos++;
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      List<String>? $2;
      final $4 = <String>[];
      while (true) {
        String? $5;
        // StringChars
        $5 = parseStringChars(state);
        if (!state.ok) {
          state.ok = true;
          break;
        }
        $4.add($5!);
      }
      if (state.ok) {
        $2 = $4;
      }
      if (state.ok) {
        // DoubleQuote
        fastParseDoubleQuote(state);
        if (state.ok) {
          String? $$;
          final v = $2!;
          $$ = v.join();
          $0 = $$;
        }
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Expression
  /// UnaryPostfix =
  ///   object:Primary selectors:Selector* {}
  ///   ;
  Expression? parseUnaryPostfix(State<String> state) {
    Expression? $0;
    // object:Primary selectors:Selector* {}
    final $1 = state.pos;
    Expression? $2;
    // Primary
    $2 = parsePrimary(state);
    if (state.ok) {
      List<({String kind, dynamic arguments})>? $3;
      final $4 = <({String kind, dynamic arguments})>[];
      while (true) {
        ({String kind, dynamic arguments})? $5;
        // Selector
        $5 = parseSelector(state);
        if (!state.ok) {
          state.ok = true;
          break;
        }
        $4.add($5!);
      }
      if (state.ok) {
        $3 = $4;
      }
      if (state.ok) {
        Expression? $$;
        final object = $2!;
        final selectors = $3!;
        $$ = _postfix(object, selectors);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Expression
  /// UnaryPrefix =
  ///   op:UnaryPrefixOp? expr:UnaryPostfix {}
  ///   ;
  Expression? parseUnaryPrefix(State<String> state) {
    Expression? $0;
    // op:UnaryPrefixOp? expr:UnaryPostfix {}
    final $1 = state.pos;
    String? $2;
    // UnaryPrefixOp
    $2 = parseUnaryPrefixOp(state);
    state.ok = true;
    if (state.ok) {
      Expression? $3;
      // UnaryPostfix
      $3 = parseUnaryPostfix(state);
      if (state.ok) {
        Expression? $$;
        final op = $2;
        final expr = $3!;
        $$ = _prefix(op, expr);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// UnaryPrefixOp =
  ///   v:('-' / '!' / '~') Spaces
  ///   ;
  String? parseUnaryPrefixOp(State<String> state) {
    String? $0;
    // v:('-' / '!' / '~') Spaces
    final $1 = state.pos;
    String? $2;
    final $8 = state.pos;
    state.ok = false;
    final $4 = state.input;
    if (state.pos < $4.length) {
      final $3 = $4.runeAt(state.pos);
      state.pos += $3 > 0xffff ? 2 : 1;
      switch ($3) {
        case 45:
          state.ok = true;
          $2 = '-';
          break;
        case 33:
          state.ok = true;
          $2 = '!';
          break;
        case 126:
          state.ok = true;
          $2 = '~';
          break;
      }
    }
    if (!state.ok) {
      state.pos = $8;
      state.fail(const ErrorExpectedTags(['-', '!', '~']));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int? matchChar(State<String> state, int char, ParseError error) {
    final input = state.input;
    state.ok = state.pos < input.length && input.runeAt(state.pos) == char;
    if (state.ok) {
      state.pos += char > 0xffff ? 2 : 1;
      return char;
    } else {
      state.fail(error);
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int? matchCharAsync(
      State<ChunkedParsingSink> state, int char, ParseError error) {
    final input = state.input;
    if (state.pos < input.start) {
      state.fail(ErrorBacktracking(state.pos));
      return null;
    }
    state.ok = state.pos < input.end;
    if (state.ok) {
      final c = input.data.runeAt(state.pos - input.start);
      state.ok = c == char;
      if (state.ok) {
        state.pos += c > 0xffff ? 2 : 1;
        return char;
      }
    }
    if (!state.ok) {
      state.fail(error);
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String? matchLiteral(State<String> state, String string, ParseError error) {
    final input = state.input;
    state.ok = input.startsWith(string, state.pos);
    if (state.ok) {
      state.pos += string.length;
      return string;
    } else {
      state.fail(error);
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String? matchLiteral1(
      State<String> state, int char, String string, ParseError error) {
    final input = state.input;
    state.ok = state.pos < input.length && input.runeAt(state.pos) == char;
    if (state.ok) {
      state.pos += char > 0xffff ? 2 : 1;
      state.ok = true;
      return string;
    }
    state.fail(error);
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String? matchLiteral1Async(State<ChunkedParsingSink> state, int char,
      String string, ParseError error) {
    final input = state.input;
    if (state.pos < input.start) {
      state.fail(ErrorBacktracking(state.pos));
      return null;
    }
    state.ok = state.pos < input.end &&
        input.data.runeAt(state.pos - input.start) == char;
    if (state.ok) {
      state.pos += char > 0xffff ? 2 : 1;
      return string;
    }
    state.fail(error);
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String? matchLiteralAsync(
      State<ChunkedParsingSink> state, String string, ParseError error) {
    final input = state.input;
    if (state.pos < input.start) {
      state.fail(ErrorBacktracking(state.pos));
      return null;
    }
    state.ok = state.pos <= input.end &&
        input.data.startsWith(string, state.pos - input.start);
    if (state.ok) {
      state.pos += string.length;
      return string;
    }
    state.fail(error);
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int? readChar16Async(State<ChunkedParsingSink> state) {
    final input = state.input;
    if (state.pos < input.end || input.isClosed) {
      state.ok = state.pos < input.end;
      if (state.pos >= input.start) {
        if (state.ok) {
          return input.data.codeUnitAt(state.pos - input.start);
        } else {
          state.fail(const ErrorUnexpectedEndOfInput());
        }
      } else {
        state.fail(ErrorBacktracking(state.pos));
      }
      return -1;
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int? readChar32Async(State<ChunkedParsingSink> state) {
    final input = state.input;
    if (state.pos < input.end || input.isClosed) {
      state.ok = state.pos < input.end;
      if (state.pos >= input.start) {
        if (state.ok) {
          return input.data.runeAt(state.pos - input.start);
        } else {
          state.fail(const ErrorUnexpectedEndOfInput());
        }
      } else {
        state.fail(ErrorBacktracking(state.pos));
      }
      return -1;
    }
    return null;
  }
}

void fastParseString(
    void Function(State<String> state) fastParse, String source) {
  final result = tryParse(fastParse, source);
  result.getResult();
}

Sink<String> parseAsync<O>(
    AsyncResult<O> Function(State<ChunkedParsingSink> state) parse,
    void Function(ParseResult<ChunkedParsingSink, O> result) onComplete) {
  final input = ChunkedParsingSink();
  final state = State(input);
  final result = parse(state);
  void complete() {
    final parseResult =
        _createParseResult<ChunkedParsingSink, O>(state, result.value);
    onComplete(parseResult);
  }

  if (result.isComplete) {
    complete();
  } else {
    result.onComplete = complete;
  }

  return input;
}

O parseString<O>(O? Function(State<String> state) parse, String source) {
  final result = tryParse(parse, source);
  return result.getResult();
}

ParseResult<I, O> tryParse<I, O>(O? Function(State<I> state) parse, I input) {
  final result = _parse<I, O>(parse, input);
  return result;
}

ParseResult<I, O> _createParseResult<I, O>(State<I> state, O? result) {
  final input = state.input;
  if (state.ok) {
    return ParseResult(
      failPos: state.failPos,
      input: input,
      ok: true,
      pos: state.pos,
      result: result,
    );
  }

  final offset = state.failPos;
  final normalized = _normalize(input, offset, state.getErrors())
      .map((e) => e.getErrorMessage(input, offset))
      .toList();
  String? message;
  if (input is String) {
    final source = _StringWrapper(
      invalidChar: 32,
      leftPadding: 0,
      rightPadding: 0,
      source: input,
    );
    message = _errorMessage(source, offset, normalized);
  } else if (input is ChunkedParsingSink) {
    final source2 = _StringWrapper(
      invalidChar: 32,
      leftPadding: input.start,
      rightPadding: 0,
      source: input.data,
    );
    message = _errorMessage(source2, offset, normalized);
  } else {
    message = normalized.join('\n');
  }

  return ParseResult(
    errors: normalized,
    failPos: state.failPos,
    input: input,
    errorMessage: message,
    ok: false,
    pos: state.pos,
    result: result,
  );
}

String _errorMessage(
    _StringWrapper source, int offset, List<ErrorMessage> errors) {
  final sb = StringBuffer();
  final errorInfoList = errors
      .map((e) => (length: e.length, message: e.toString()))
      .toSet()
      .toList();
  final hasFullSource = source.leftPadding == 0 && source.rightPadding == 0;
  for (var i = 0; i < errorInfoList.length; i++) {
    int max(int x, int y) => x > y ? x : y;
    int min(int x, int y) => x < y ? x : y;
    if (sb.isNotEmpty) {
      sb.writeln();
      sb.writeln();
    }

    final errorInfo = errorInfoList[i];
    final length = errorInfo.length;
    final message = errorInfo.message;
    final start = min(offset + length, offset);
    final end = max(offset + length, offset);
    var row = 1;
    var lineStart = 0, next = 0, pos = 0;
    if (hasFullSource) {
      while (pos < source.length) {
        final c = source.codeUnitAt(pos++);
        if (c == 0xa || c == 0xd) {
          next = c == 0xa ? 0xd : 0xa;
          if (pos < source.length && source.codeUnitAt(pos) == next) {
            pos++;
          }
          if (pos - 1 >= start) {
            break;
          }
          row++;
          lineStart = pos;
        }
      }
    }

    final inputLen = source.length;
    final lineLimit = min(80, inputLen);
    final start2 = start;
    final end2 = min(start2 + lineLimit, end);
    final errorLen = end2 - start;
    final extraLen = lineLimit - errorLen;
    final rightLen = min(inputLen - end2, extraLen - (extraLen >> 1));
    final leftLen = min(start, max(0, lineLimit - errorLen - rightLen));
    var index = start2 - 1;
    final list = <int>[];
    for (var i = 0; i < leftLen && index >= 0; i++) {
      var cc = source.codeUnitAt(index--);
      if ((cc & 0xFC00) == 0xDC00 && (index > 0)) {
        final pc = source.codeUnitAt(index);
        if ((pc & 0xFC00) == 0xD800) {
          cc = 0x10000 + ((pc & 0x3FF) << 10) + (cc & 0x3FF);
          index--;
        }
      }

      list.add(cc);
    }

    final column = start - lineStart + 1;
    final left = String.fromCharCodes(list.reversed);
    final end3 = min(inputLen, start2 + (lineLimit - leftLen));
    final indicatorLen = max(1, errorLen);
    final right = source.substring(start2, end3);
    var text = left + right;
    text = text.replaceAll('\n', ' ');
    text = text.replaceAll('\r', ' ');
    text = text.replaceAll('\t', ' ');
    if (hasFullSource) {
      sb.writeln('line $row, column $column: $message');
    } else {
      sb.writeln('offset $start: $message');
    }

    sb.writeln(text);
    sb.write(' ' * leftLen + '^' * indicatorLen);
  }

  return sb.toString();
}

List<ParseError> _normalize<I>(I input, int offset, List<ParseError> errors) {
  final errorList = errors.toList();
  final expectedTags = errorList.whereType<ErrorExpectedTags>().toList();
  if (expectedTags.isNotEmpty) {
    errorList.removeWhere((e) => e is ErrorExpectedTags);
    final tags = <String>{};
    for (final error in expectedTags) {
      tags.addAll(error.tags);
    }

    final tagList = tags.toList();
    tagList.sort();
    final error = ErrorExpectedTags(tagList);
    errorList.add(error);
  }

  final errorMap = <Object?, ParseError>{};
  for (final error in errorList) {
    Object key = error;
    if (error is ErrorExpectedCharacter) {
      key = (ErrorExpectedCharacter, error.char);
    } else if (error is ErrorUnexpectedInput) {
      key = (ErrorUnexpectedInput, error.length);
    } else if (error is ErrorUnknownError) {
      key = ErrorUnknownError;
    } else if (error is ErrorUnexpectedCharacter) {
      key = (ErrorUnexpectedCharacter, error.char);
    } else if (error is ErrorBacktracking) {
      key = (ErrorBacktracking, error.length);
    }

    errorMap[key] = error;
  }

  return errorMap.values.toList();
}

ParseResult<I, O> _parse<I, O>(O? Function(State<I> input) parse, I input) {
  final state = State(input);
  final result = parse(state);
  return _createParseResult<I, O>(state, result);
}

class AsyncResult<T> {
  bool isComplete = false;

  void Function()? onComplete;

  T? value;
}

class ChunkedParsingSink implements Sink<String> {
  int bufferLoad = 0;

  String data = '';

  int end = 0;

  void Function()? handle;

  bool sleep = false;

  int start = 0;

  int _buffering = 0;

  bool _isClosed = false;

  int _lastPosition = 0;

  bool get isClosed => _isClosed;

  @override
  void add(String data) {
    if (_isClosed) {
      throw StateError('Chunked data sink already closed');
    }

    if (_lastPosition > start) {
      if (_lastPosition == end) {
        this.data = '';
      } else {
        this.data = this.data.substring(_lastPosition - start);
      }

      start = _lastPosition;
    }

    if (this.data.isEmpty) {
      this.data = data;
    } else {
      this.data = '${this.data}$data';
    }

    end = start + this.data.length;
    if (bufferLoad < this.data.length) {
      bufferLoad = this.data.length;
    }

    sleep = false;
    while (!sleep) {
      final h = handle;
      handle = null;
      if (h == null) {
        break;
      }

      h();
    }

    if (_buffering == 0) {
      if (_lastPosition > start) {
        if (_lastPosition == end) {
          this.data = '';
        } else {
          this.data = this.data.substring(_lastPosition - start);
        }

        start = _lastPosition;
      }
    }
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int beginBuffering() {
    return _buffering++;
  }

  @override
  void close() {
    if (_isClosed) {
      return;
    }

    _isClosed = true;
    sleep = false;
    while (!sleep) {
      final h = handle;
      handle = null;
      if (h == null) {
        break;
      }

      h();
    }

    if (_buffering != 0) {
      throw StateError('On closing, an incomplete buffering was detected');
    }

    if (data.isNotEmpty) {
      data = '';
    }
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void endBuffering(int position) {
    _buffering--;
    if (_buffering == 0) {
      if (_lastPosition < position) {
        _lastPosition = position;
      }
    } else if (_buffering < 0) {
      throw StateError('Inconsistent buffering completion detected.');
    }
  }
}

class ErrorBacktracking extends ParseError {
  static const message = 'Backtracking error to position {{0}}';

  final int position;

  const ErrorBacktracking(this.position);

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    return ErrorMessage(0, ErrorBacktracking.message, [position]);
  }
}

class ErrorExpectedCharacter extends ParseError {
  static const message = 'Expected a character {0}';

  final int char;

  const ErrorExpectedCharacter(this.char);

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    final value = ParseError.escape(char);
    final hexValue = char.toRadixString(16);
    final argument = '$value (0x$hexValue)';
    return ErrorMessage(0, ErrorExpectedCharacter.message, [argument]);
  }
}

class ErrorExpectedTags extends ParseError {
  static const message = 'Expected: {0}';

  final List<String> tags;

  const ErrorExpectedTags(this.tags);

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    final list = tags.map(ParseError.escape).toList();
    list.sort();
    final argument = list.join(', ');
    return ErrorMessage(0, ErrorExpectedTags.message, [argument]);
  }
}

class ErrorMessage extends ParseError {
  final List<Object?> arguments;

  @override
  final int length;

  final String text;

  const ErrorMessage(this.length, this.text, [this.arguments = const []]);

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    return this;
  }

  @override
  String toString() {
    var result = text;
    for (var i = 0; i < arguments.length; i++) {
      final argument = arguments[i];
      result = result.replaceAll('{$i}', argument.toString());
    }

    return result;
  }
}

class ErrorUnexpectedCharacter extends ParseError {
  static const message = 'Unexpected character {0}';

  final int? char;

  const ErrorUnexpectedCharacter([this.char]);

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    var argument = '<?>';
    var char = this.char;
    if (offset != null && offset > 0) {
      if (input is String) {
        if (offset < input.length) {
          char = input.runeAt(offset);
        } else {
          argument = '<EOF>';
        }
      } else if (input is ChunkedParsingSink) {
        final data = input.data;
        final length = input.isClosed ? input.end : -1;
        if (length != -1) {
          if (offset < length) {
            final source = _StringWrapper(
              invalidChar: 32,
              leftPadding: input.start,
              rightPadding: 0,
              source: data,
            );
            if (source.hasCodeUnitAt(offset)) {
              char = source.runeAt(offset);
            }
          } else {
            argument = '<EOF>';
          }
        }
      }
    }

    if (char != null) {
      final hexValue = char.toRadixString(16);
      final value = ParseError.escape(char);
      argument = '$value (0x$hexValue)';
    }

    return ErrorMessage(0, ErrorUnexpectedCharacter.message, [argument]);
  }
}

class ErrorUnexpectedEndOfInput extends ParseError {
  static const message = 'Unexpected end of input';

  const ErrorUnexpectedEndOfInput();

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    return ErrorMessage(length, ErrorUnexpectedEndOfInput.message);
  }
}

class ErrorUnexpectedInput extends ParseError {
  static const message = 'Unexpected input data';

  @override
  final int length;

  const ErrorUnexpectedInput(this.length);

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    return ErrorMessage(length, ErrorUnexpectedInput.message);
  }
}

class ErrorUnknownError extends ParseError {
  static const message = 'Unknown error';

  const ErrorUnknownError();

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    return const ErrorMessage(0, ErrorUnknownError.message);
  }
}

abstract class ParseError {
  const ParseError();

  int get length => 0;

  ErrorMessage getErrorMessage(Object? input, int? offset);

  @override
  String toString() {
    final message = getErrorMessage(null, null);
    return message.toString();
  }

  static String escape(Object? value, [bool quote = true]) {
    if (value is int) {
      if (value >= 0 && value <= 0xd7ff ||
          value >= 0xe000 && value <= 0x10ffff) {
        value = String.fromCharCode(value);
      } else {
        return value.toString();
      }
    } else if (value is! String) {
      return value.toString();
    }

    final map = {
      '\b': '\\b',
      '\f': '\\f',
      '\n': '\\n',
      '\r': '\\r',
      '\t': '\\t',
      '\v': '\\v',
    };
    var result = value.toString();
    for (final key in map.keys) {
      result = result.replaceAll(key, map[key]!);
    }
    if (quote) {
      result = "'$result'";
    }
    return result;
  }
}

class ParseResult<I, O> {
  final String errorMessage;

  final List<ErrorMessage> errors;

  final int failPos;

  final I input;

  final bool ok;

  final int pos;

  final O? result;

  ParseResult({
    this.errorMessage = '',
    this.errors = const [],
    required this.failPos,
    required this.input,
    required this.ok,
    required this.pos,
    required this.result,
  });

  O getResult() {
    if (!ok) {
      throw FormatException(errorMessage);
    }

    return result as O;
  }
}

class State<T> {
  Object? context;

  final List<ParseError?> errors = List.filled(64, null, growable: false);

  int errorCount = 0;

  int failPos = 0;

  final T input;

  bool ok = false;

  int pos = 0;

  State(this.input);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool fail(ParseError error) {
    ok = false;
    if (pos >= failPos) {
      if (failPos < pos) {
        failPos = pos;
        errorCount = 0;
      }
      if (errorCount < errors.length) {
        errors[errorCount++] = error;
      }
    }
    return false;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool failAll(List<ParseError> errors) {
    ok = false;
    if (pos >= failPos) {
      if (failPos < pos) {
        failPos = pos;
        errorCount = 0;
      }
      for (var i = 0; i < errors.length; i++) {
        if (errorCount < errors.length) {
          this.errors[errorCount++] = errors[i];
        }
      }
    }
    return false;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool failAllAt(int offset, List<ParseError> errors) {
    ok = false;
    if (offset >= failPos) {
      if (failPos < offset) {
        failPos = offset;
        errorCount = 0;
      }
      for (var i = 0; i < errors.length; i++) {
        if (errorCount < errors.length) {
          this.errors[errorCount++] = errors[i];
        }
      }
    }
    return false;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool failAt(int offset, ParseError error) {
    ok = false;
    if (offset >= failPos) {
      if (failPos < offset) {
        failPos = offset;
        errorCount = 0;
      }
      if (errorCount < errors.length) {
        errors[errorCount++] = error;
      }
    }
    return false;
  }

  List<ParseError> getErrors() {
    return List.generate(errorCount, (i) => errors[i]!);
  }

  @override
  String toString() {
    if (input case final String input) {
      if (pos >= input.length) {
        return '$pos:';
      }
      var length = input.length - pos;
      length = length > 40 ? 40 : length;
      final string = input.substring(pos, pos + length);
      return '$pos:$string';
    } else if (input case final ChunkedParsingSink input) {
      final source = input.data;
      final pos = this.pos - input.start;
      if (pos < 0 || pos >= source.length) {
        return '$pos:';
      }
      var length = source.length - pos;
      length = length > 40 ? 40 : length;
      final string = source.substring(pos, pos + length);
      return '$pos:$string';
    }

    return super.toString();
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  // ignore: unused_element
  bool _canHandleError(int failPos, int errorCount) {
    return failPos == this.failPos
        ? errorCount < this.errorCount
        : failPos < this.failPos;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  // ignore: unused_element
  void _rollbackErrors(int failPos, int errorCount) {
    if (this.failPos == failPos) {
      this.errorCount = errorCount;
    } else if (this.failPos > failPos) {
      this.errorCount = 0;
    }
  }
}

class _StringWrapper {
  final int invalidChar;

  final int leftPadding;

  final int length;

  final int rightPadding;

  final String source;

  _StringWrapper({
    required this.invalidChar,
    required this.leftPadding,
    required this.rightPadding,
    required this.source,
  }) : length = leftPadding + source.length + rightPadding;

  int codeUnitAt(int index) {
    if (index < 0 || index > length - 1) {
      throw RangeError.range(index, 0, length, 'index');
    }

    final offset = index - leftPadding;
    if (offset >= 0 && offset < source.length) {
      return source.codeUnitAt(offset);
    }

    return invalidChar;
  }

  bool hasCodeUnitAt(int index) {
    if (index < 0 || index > length - 1) {
      throw RangeError.range(index, 0, length, 'index');
    }

    return index >= leftPadding && index <= rightPadding && source.isNotEmpty;
  }

  int runeAt(int index) {
    final w1 = codeUnitAt(index++);
    if (w1 > 0xd7ff && w1 < 0xe000) {
      if (index < length) {
        final w2 = codeUnitAt(index);
        if ((w2 & 0xfc00) == 0xdc00) {
          return 0x10000 + ((w1 & 0x3ff) << 10) + (w2 & 0x3ff);
        }
      }
      throw FormatException('Invalid UTF-16 character', this, index - 1);
    }
    return w1;
  }

  String substring(int start, int end) {
    if (start < 0 || start > length) {
      throw RangeError.range(start, 0, length, 'index');
    }

    if (end < start || end > length) {
      throw RangeError.range(end, start, length, 'end');
    }

    final codeUnits = List.generate(end - start, (i) => codeUnitAt(start + i));
    return String.fromCharCodes(codeUnits);
  }
}

extension StringExt on String {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  // ignore: unused_element
  int runeAt(int index) {
    final w1 = codeUnitAt(index++);
    if (w1 > 0xd7ff && w1 < 0xe000) {
      if (index < length) {
        final w2 = codeUnitAt(index);
        if ((w2 & 0xfc00) == 0xdc00) {
          return 0x10000 + ((w1 & 0x3ff) << 10) + (w2 & 0x3ff);
        }
      }
      throw FormatException('Invalid UTF-16 character', this, index - 1);
    }
    return w1;
  }
}
