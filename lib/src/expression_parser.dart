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
    final $2 = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 93;
    if ($2) {
      state.pos++;
      state.setOk(true);
    } else {
      state.fail(const ErrorExpectedTags([$1]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
    }
    if (!state.ok) {
      state.backtrack($0);
    }
  }

  /// CloseParenthesis =
  ///   v:')' Spaces
  ///   ;
  void fastParseCloseParenthesis(State<String> state) {
    // v:')' Spaces
    final $0 = state.pos;
    const $1 = ')';
    final $2 = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 41;
    if ($2) {
      state.pos++;
      state.setOk(true);
    } else {
      state.fail(const ErrorExpectedTags([$1]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
    }
    if (!state.ok) {
      state.backtrack($0);
    }
  }

  /// Colon =
  ///   v:':' Spaces
  ///   ;
  void fastParseColon(State<String> state) {
    // v:':' Spaces
    final $0 = state.pos;
    const $1 = ':';
    final $2 = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 58;
    if ($2) {
      state.pos++;
      state.setOk(true);
    } else {
      state.fail(const ErrorExpectedTags([$1]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
    }
    if (!state.ok) {
      state.backtrack($0);
    }
  }

  /// Comma =
  ///   v:',' Spaces
  ///   ;
  void fastParseComma(State<String> state) {
    // v:',' Spaces
    final $0 = state.pos;
    const $1 = ',';
    final $2 = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 44;
    if ($2) {
      state.pos++;
      state.setOk(true);
    } else {
      state.fail(const ErrorExpectedTags([$1]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
    }
    if (!state.ok) {
      state.backtrack($0);
    }
  }

  /// DoubleQuote =
  ///   v:'"' Spaces
  ///   ;
  void fastParseDoubleQuote(State<String> state) {
    // v:'"' Spaces
    final $0 = state.pos;
    const $1 = '"';
    final $2 = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 34;
    if ($2) {
      state.pos++;
      state.setOk(true);
    } else {
      state.fail(const ErrorExpectedTags([$1]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
    }
    if (!state.ok) {
      state.backtrack($0);
    }
  }

  /// Eof =
  ///   !.
  ///   ;
  void fastParseEof(State<String> state) {
    // !.
    final $1 = state.pos;
    if (state.pos < state.input.length) {
      final c = state.input.runeAt(state.pos);
      state.pos += c > 0xffff ? 2 : 1;
      state.setOk(true);
    } else {
      state.fail(const ErrorUnexpectedEndOfInput());
    }
    if (state.ok) {
      final length = $1 - state.pos;
      state.fail(switch (length) {
        0 => const ErrorUnexpectedInput(0),
        -1 => const ErrorUnexpectedInput(-1),
        -2 => const ErrorUnexpectedInput(-2),
        _ => ErrorUnexpectedInput(length)
      });
      state.backtrack($1);
    } else {
      state.setOk(true);
    }
  }

  /// OpenParenthesis =
  ///   v:'(' Spaces
  ///   ;
  void fastParseOpenParenthesis(State<String> state) {
    // v:'(' Spaces
    final $0 = state.pos;
    const $1 = '(';
    final $2 = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 40;
    if ($2) {
      state.pos++;
      state.setOk(true);
    } else {
      state.fail(const ErrorExpectedTags([$1]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
    }
    if (!state.ok) {
      state.backtrack($0);
    }
  }

  /// Question =
  ///   v:'?' Spaces
  ///   ;
  void fastParseQuestion(State<String> state) {
    // v:'?' Spaces
    final $0 = state.pos;
    const $1 = '?';
    final $2 = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 63;
    if ($2) {
      state.pos++;
      state.setOk(true);
    } else {
      state.fail(const ErrorExpectedTags([$1]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
    }
    if (!state.ok) {
      state.backtrack($0);
    }
  }

  /// Spaces =
  ///   [ \n\r\t]*
  ///   ;
  void fastParseSpaces(State<String> state) {
    // [ \n\r\t]*
    for (var c = 0;
        state.pos < state.input.length &&
            (c = state.input.codeUnitAt(state.pos)) == c &&
            (c < 13 ? c >= 9 && c <= 10 : c <= 13 || c == 32);
        // ignore: curly_braces_in_flow_control_structures, empty_statements
        state.pos++);
    state.setOk(true);
  }

  /// Expression
  /// Additive =
  ///   h:Multiplicative t:(op:AdditiveOp ↑ expr:Multiplicative)* {}
  ///   ;
  Expression? parseAdditive(State<String> state) {
    Expression? $0;
    // h:Multiplicative t:(op:AdditiveOp ↑ expr:Multiplicative)* {}
    final $3 = state.pos;
    Expression? $1;
    // Multiplicative
    $1 = parseMultiplicative(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $2;
      final $5 = <({String op, Expression expr})>[];
      final $4 = state.ignoreErrors;
      state.ignoreErrors = true;
      while (true) {
        ({String op, Expression expr})? $6;
        // op:AdditiveOp ↑ expr:Multiplicative
        final $11 = state.pos;
        var $9 = true;
        final $10 = state.ignoreErrors;
        String? $7;
        // AdditiveOp
        $7 = parseAdditiveOp(state);
        if (state.ok) {
          $9 = false;
          state.ignoreErrors = false;
          state.setOk(true);
          if (state.ok) {
            Expression? $8;
            // Multiplicative
            $8 = parseMultiplicative(state);
            if (state.ok) {
              $6 = (op: $7!, expr: $8!);
            }
          }
        }
        if (!state.ok) {
          if (!$9) {
            state.isRecoverable = false;
          }
          state.backtrack($11);
        }
        state.ignoreErrors = $10;
        if (!state.ok) {
          break;
        }
        $5.add($6!);
      }
      state.ignoreErrors = $4;
      state.setOk(true);
      if (state.ok) {
        $2 = $5;
      }
      if (state.ok) {
        Expression? $$;
        final h = $1!;
        final t = $2!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.backtrack($3);
    }
    return $0;
  }

  /// AdditiveOp =
  ///   v:('-' / '+') Spaces
  ///   ;
  String? parseAdditiveOp(State<String> state) {
    String? $0;
    // v:('-' / '+') Spaces
    final $2 = state.pos;
    String? $1;
    final $4 = state.pos;
    var $3 = 0;
    if (state.pos < state.input.length) {
      final input = state.input;
      final c = input.codeUnitAt(state.pos);
      // ignore: unused_local_variable
      final pos2 = state.pos + 1;
      switch (c) {
        case 45:
          $3 = 1;
          $1 = '-';
          break;
        case 43:
          $3 = 1;
          $1 = '+';
          break;
      }
    }
    if ($3 > 0) {
      state.pos += $3;
      state.setOk(true);
    } else {
      state.pos = $4;
      state.fail(const ErrorExpectedTags(['-', '+']));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $1;
      }
    }
    if (!state.ok) {
      state.backtrack($2);
    }
    return $0;
  }

  /// Arguments =
  ///   @list(NamedArgument / PositionalArgument, Comma ↑ v:(NamedArgument / PositionalArgument))
  ///   ;
  List<({String name, Expression expr})>? parseArguments(State<String> state) {
    List<({String name, Expression expr})>? $0;
    // @list(NamedArgument / PositionalArgument, Comma ↑ v:(NamedArgument / PositionalArgument))
    final $2 = <({String name, Expression expr})>[];
    final $5 = state.ignoreErrors;
    state.ignoreErrors = true;
    ({String name, Expression expr})? $3;
    // NamedArgument
    // NamedArgument
    $3 = parseNamedArgument(state);
    if (!state.ok && state.isRecoverable) {
      // PositionalArgument
      // PositionalArgument
      $3 = parsePositionalArgument(state);
    }
    if (state.ok) {
      $2.add($3!);
      while (true) {
        ({String name, Expression expr})? $4;
        // Comma ↑ v:(NamedArgument / PositionalArgument)
        final $12 = state.pos;
        var $10 = true;
        final $11 = state.ignoreErrors;
        // Comma
        fastParseComma(state);
        if (state.ok) {
          $10 = false;
          state.ignoreErrors = false;
          state.setOk(true);
          if (state.ok) {
            ({String name, Expression expr})? $9;
            // NamedArgument
            // NamedArgument
            $9 = parseNamedArgument(state);
            if (!state.ok && state.isRecoverable) {
              // PositionalArgument
              // PositionalArgument
              $9 = parsePositionalArgument(state);
            }
            if (state.ok) {
              $4 = $9;
            }
          }
        }
        if (!state.ok) {
          if (!$10) {
            state.isRecoverable = false;
          }
          state.backtrack($12);
        }
        state.ignoreErrors = $11;
        if (!state.ok) {
          break;
        }
        $2.add($4!);
      }
    }
    state.ignoreErrors = $5;
    state.setOk(true);
    if (state.ok) {
      $0 = $2;
    }
    return $0;
  }

  /// Expression
  /// BitwiseAnd =
  ///   h:Shift t:(op:BitwiseAndOp ↑ expr:Shift)* {}
  ///   ;
  Expression? parseBitwiseAnd(State<String> state) {
    Expression? $0;
    // h:Shift t:(op:BitwiseAndOp ↑ expr:Shift)* {}
    final $3 = state.pos;
    Expression? $1;
    // Shift
    $1 = parseShift(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $2;
      final $5 = <({String op, Expression expr})>[];
      final $4 = state.ignoreErrors;
      state.ignoreErrors = true;
      while (true) {
        ({String op, Expression expr})? $6;
        // op:BitwiseAndOp ↑ expr:Shift
        final $11 = state.pos;
        var $9 = true;
        final $10 = state.ignoreErrors;
        String? $7;
        // BitwiseAndOp
        $7 = parseBitwiseAndOp(state);
        if (state.ok) {
          $9 = false;
          state.ignoreErrors = false;
          state.setOk(true);
          if (state.ok) {
            Expression? $8;
            // Shift
            $8 = parseShift(state);
            if (state.ok) {
              $6 = (op: $7!, expr: $8!);
            }
          }
        }
        if (!state.ok) {
          if (!$9) {
            state.isRecoverable = false;
          }
          state.backtrack($11);
        }
        state.ignoreErrors = $10;
        if (!state.ok) {
          break;
        }
        $5.add($6!);
      }
      state.ignoreErrors = $4;
      state.setOk(true);
      if (state.ok) {
        $2 = $5;
      }
      if (state.ok) {
        Expression? $$;
        final h = $1!;
        final t = $2!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.backtrack($3);
    }
    return $0;
  }

  /// BitwiseAndOp =
  ///   !'&&' v:'&' Spaces
  ///   ;
  String? parseBitwiseAndOp(State<String> state) {
    String? $0;
    // !'&&' v:'&' Spaces
    final $2 = state.pos;
    final $3 = state.pos;
    const $4 = '&&';
    final $5 = state.pos + 1 < state.input.length &&
        state.input.codeUnitAt(state.pos) == 38 &&
        state.input.codeUnitAt(state.pos + 1) == 38;
    if ($5) {
      state.pos += 2;
      state.setOk(true);
    } else {
      state.fail(const ErrorExpectedTags([$4]));
    }
    if (state.ok) {
      final length = $3 - state.pos;
      state.fail(switch (length) {
        0 => const ErrorUnexpectedInput(0),
        -1 => const ErrorUnexpectedInput(-1),
        -2 => const ErrorUnexpectedInput(-2),
        _ => ErrorUnexpectedInput(length)
      });
      state.backtrack($3);
    } else {
      state.setOk(true);
    }
    if (state.ok) {
      String? $1;
      const $6 = '&';
      final $7 = state.pos < state.input.length &&
          state.input.codeUnitAt(state.pos) == 38;
      if ($7) {
        state.pos++;
        state.setOk(true);
        $1 = $6;
      } else {
        state.fail(const ErrorExpectedTags([$6]));
      }
      if (state.ok) {
        // Spaces
        fastParseSpaces(state);
        if (state.ok) {
          $0 = $1;
        }
      }
    }
    if (!state.ok) {
      state.backtrack($2);
    }
    return $0;
  }

  /// Expression
  /// BitwiseOr =
  ///   h:BitwiseXor t:(op:BitwiseOrOp ↑ expr:BitwiseXor)* {}
  ///   ;
  Expression? parseBitwiseOr(State<String> state) {
    Expression? $0;
    // h:BitwiseXor t:(op:BitwiseOrOp ↑ expr:BitwiseXor)* {}
    final $3 = state.pos;
    Expression? $1;
    // BitwiseXor
    $1 = parseBitwiseXor(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $2;
      final $5 = <({String op, Expression expr})>[];
      final $4 = state.ignoreErrors;
      state.ignoreErrors = true;
      while (true) {
        ({String op, Expression expr})? $6;
        // op:BitwiseOrOp ↑ expr:BitwiseXor
        final $11 = state.pos;
        var $9 = true;
        final $10 = state.ignoreErrors;
        String? $7;
        // BitwiseOrOp
        $7 = parseBitwiseOrOp(state);
        if (state.ok) {
          $9 = false;
          state.ignoreErrors = false;
          state.setOk(true);
          if (state.ok) {
            Expression? $8;
            // BitwiseXor
            $8 = parseBitwiseXor(state);
            if (state.ok) {
              $6 = (op: $7!, expr: $8!);
            }
          }
        }
        if (!state.ok) {
          if (!$9) {
            state.isRecoverable = false;
          }
          state.backtrack($11);
        }
        state.ignoreErrors = $10;
        if (!state.ok) {
          break;
        }
        $5.add($6!);
      }
      state.ignoreErrors = $4;
      state.setOk(true);
      if (state.ok) {
        $2 = $5;
      }
      if (state.ok) {
        Expression? $$;
        final h = $1!;
        final t = $2!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.backtrack($3);
    }
    return $0;
  }

  /// BitwiseOrOp =
  ///   !'||' v:'|' Spaces
  ///   ;
  String? parseBitwiseOrOp(State<String> state) {
    String? $0;
    // !'||' v:'|' Spaces
    final $2 = state.pos;
    final $3 = state.pos;
    const $4 = '||';
    final $5 = state.pos + 1 < state.input.length &&
        state.input.codeUnitAt(state.pos) == 124 &&
        state.input.codeUnitAt(state.pos + 1) == 124;
    if ($5) {
      state.pos += 2;
      state.setOk(true);
    } else {
      state.fail(const ErrorExpectedTags([$4]));
    }
    if (state.ok) {
      final length = $3 - state.pos;
      state.fail(switch (length) {
        0 => const ErrorUnexpectedInput(0),
        -1 => const ErrorUnexpectedInput(-1),
        -2 => const ErrorUnexpectedInput(-2),
        _ => ErrorUnexpectedInput(length)
      });
      state.backtrack($3);
    } else {
      state.setOk(true);
    }
    if (state.ok) {
      String? $1;
      const $6 = '|';
      final $7 = state.pos < state.input.length &&
          state.input.codeUnitAt(state.pos) == 124;
      if ($7) {
        state.pos++;
        state.setOk(true);
        $1 = $6;
      } else {
        state.fail(const ErrorExpectedTags([$6]));
      }
      if (state.ok) {
        // Spaces
        fastParseSpaces(state);
        if (state.ok) {
          $0 = $1;
        }
      }
    }
    if (!state.ok) {
      state.backtrack($2);
    }
    return $0;
  }

  /// Expression
  /// BitwiseXor =
  ///   h:BitwiseAnd t:(op:BitwiseXorOp ↑ expr:BitwiseAnd)* {}
  ///   ;
  Expression? parseBitwiseXor(State<String> state) {
    Expression? $0;
    // h:BitwiseAnd t:(op:BitwiseXorOp ↑ expr:BitwiseAnd)* {}
    final $3 = state.pos;
    Expression? $1;
    // BitwiseAnd
    $1 = parseBitwiseAnd(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $2;
      final $5 = <({String op, Expression expr})>[];
      final $4 = state.ignoreErrors;
      state.ignoreErrors = true;
      while (true) {
        ({String op, Expression expr})? $6;
        // op:BitwiseXorOp ↑ expr:BitwiseAnd
        final $11 = state.pos;
        var $9 = true;
        final $10 = state.ignoreErrors;
        String? $7;
        // BitwiseXorOp
        $7 = parseBitwiseXorOp(state);
        if (state.ok) {
          $9 = false;
          state.ignoreErrors = false;
          state.setOk(true);
          if (state.ok) {
            Expression? $8;
            // BitwiseAnd
            $8 = parseBitwiseAnd(state);
            if (state.ok) {
              $6 = (op: $7!, expr: $8!);
            }
          }
        }
        if (!state.ok) {
          if (!$9) {
            state.isRecoverable = false;
          }
          state.backtrack($11);
        }
        state.ignoreErrors = $10;
        if (!state.ok) {
          break;
        }
        $5.add($6!);
      }
      state.ignoreErrors = $4;
      state.setOk(true);
      if (state.ok) {
        $2 = $5;
      }
      if (state.ok) {
        Expression? $$;
        final h = $1!;
        final t = $2!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.backtrack($3);
    }
    return $0;
  }

  /// BitwiseXorOp =
  ///   v:'^' Spaces
  ///   ;
  String? parseBitwiseXorOp(State<String> state) {
    String? $0;
    // v:'^' Spaces
    final $2 = state.pos;
    String? $1;
    const $3 = '^';
    final $4 = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 94;
    if ($4) {
      state.pos++;
      state.setOk(true);
      $1 = $3;
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $1;
      }
    }
    if (!state.ok) {
      state.backtrack($2);
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
    final $3 = state.pos + 3 < state.input.length &&
        state.input.codeUnitAt(state.pos) == 116 &&
        state.input.codeUnitAt(state.pos + 1) == 114 &&
        state.input.codeUnitAt(state.pos + 2) == 117 &&
        state.input.codeUnitAt(state.pos + 3) == 101;
    if ($3) {
      state.pos += 4;
      state.setOk(true);
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
      state.backtrack($1);
    }
    if (!state.ok && state.isRecoverable) {
      // 'false' Spaces {}
      final $4 = state.pos;
      const $5 = 'false';
      final $6 = state.pos + 4 < state.input.length &&
          state.input.codeUnitAt(state.pos) == 102 &&
          state.input.codeUnitAt(state.pos + 1) == 97 &&
          state.input.codeUnitAt(state.pos + 2) == 108 &&
          state.input.codeUnitAt(state.pos + 3) == 115 &&
          state.input.codeUnitAt(state.pos + 4) == 101;
      if ($6) {
        state.pos += 5;
        state.setOk(true);
      } else {
        state.fail(const ErrorExpectedTags([$5]));
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
        state.backtrack($4);
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
    final $4 = state.pos;
    Expression? $1;
    // IfNull
    $1 = parseIfNull(state);
    if (state.ok) {
      // Question
      fastParseQuestion(state);
      if (state.ok) {
        Expression? $2;
        // Expression
        $2 = parseExpression(state);
        if (state.ok) {
          // Colon
          fastParseColon(state);
          if (state.ok) {
            Expression? $3;
            // Expression
            $3 = parseExpression(state);
            if (state.ok) {
              Expression? $$;
              final e1 = $1!;
              final e2 = $2!;
              final e3 = $3!;
              $$ = () => e1() as bool ? e2() : e3();
              $0 = $$;
            }
          }
        }
      }
    }
    if (!state.ok) {
      state.backtrack($4);
    }
    if (!state.ok && state.isRecoverable) {
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
    final $2 = state.pos;
    String? $1;
    const $3 = '.';
    final $4 = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 46;
    if ($4) {
      state.pos++;
      state.setOk(true);
      $1 = $3;
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $1;
      }
    }
    if (!state.ok) {
      state.backtrack($2);
    }
    return $0;
  }

  /// Expression
  /// Equality =
  ///   h:Relational t:(op:EqualityOp ↑ expr:Relational)* {}
  ///   ;
  Expression? parseEquality(State<String> state) {
    Expression? $0;
    // h:Relational t:(op:EqualityOp ↑ expr:Relational)* {}
    final $3 = state.pos;
    Expression? $1;
    // Relational
    $1 = parseRelational(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $2;
      final $5 = <({String op, Expression expr})>[];
      final $4 = state.ignoreErrors;
      state.ignoreErrors = true;
      while (true) {
        ({String op, Expression expr})? $6;
        // op:EqualityOp ↑ expr:Relational
        final $11 = state.pos;
        var $9 = true;
        final $10 = state.ignoreErrors;
        String? $7;
        // EqualityOp
        $7 = parseEqualityOp(state);
        if (state.ok) {
          $9 = false;
          state.ignoreErrors = false;
          state.setOk(true);
          if (state.ok) {
            Expression? $8;
            // Relational
            $8 = parseRelational(state);
            if (state.ok) {
              $6 = (op: $7!, expr: $8!);
            }
          }
        }
        if (!state.ok) {
          if (!$9) {
            state.isRecoverable = false;
          }
          state.backtrack($11);
        }
        state.ignoreErrors = $10;
        if (!state.ok) {
          break;
        }
        $5.add($6!);
      }
      state.ignoreErrors = $4;
      state.setOk(true);
      if (state.ok) {
        $2 = $5;
      }
      if (state.ok) {
        Expression? $$;
        final h = $1!;
        final t = $2!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.backtrack($3);
    }
    return $0;
  }

  /// EqualityOp =
  ///   v:('==' / '!=') Spaces
  ///   ;
  String? parseEqualityOp(State<String> state) {
    String? $0;
    // v:('==' / '!=') Spaces
    final $2 = state.pos;
    String? $1;
    final $4 = state.pos;
    var $3 = 0;
    if (state.pos < state.input.length) {
      final input = state.input;
      final c = input.codeUnitAt(state.pos);
      // ignore: unused_local_variable
      final pos2 = state.pos + 1;
      switch (c) {
        case 61:
          final ok = pos2 < input.length && input.codeUnitAt(pos2) == 61;
          if (ok) {
            $3 = 2;
            $1 = '==';
          }
          break;
        case 33:
          final ok = pos2 < input.length && input.codeUnitAt(pos2) == 61;
          if (ok) {
            $3 = 2;
            $1 = '!=';
          }
          break;
      }
    }
    if ($3 > 0) {
      state.pos += $3;
      state.setOk(true);
    } else {
      state.pos = $4;
      state.fail(const ErrorExpectedTags(['==', '!=']));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $1;
      }
    }
    if (!state.ok) {
      state.backtrack($2);
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
  ///   @indicate('Expected 4 digit hex number', HexNumber_)
  ///   ;
  int? parseHexNumber(State<String> state) {
    int? $0;
    // @indicate('Expected 4 digit hex number', HexNumber_)
    final $5 = state.pos;
    final $2 = state.errorCount;
    final $3 = state.failPos;
    final $4 = state.lastFailPos;
    state.lastFailPos = -1;
    // HexNumber_
    // int @inline HexNumber_ = v:$([0-9A-Za-z]{4,4}) {} ;
    // v:$([0-9A-Za-z]{4,4}) {}
    String? $7;
    final $9 = state.pos;
    // [0-9A-Za-z]{4,4}
    final $11 = state.pos;
    var $12 = 0;
    while ($12 < 4) {
      if (state.pos < state.input.length) {
        final $13 = state.input.codeUnitAt(state.pos);
        final $14 = $13 < 65
            ? $13 >= 48 && $13 <= 57
            : $13 <= 90 || $13 >= 97 && $13 <= 122;
        if ($14) {
          state.pos++;
          state.setOk(true);
        } else {
          state.fail(const ErrorUnexpectedCharacter());
        }
      } else {
        state.fail(const ErrorUnexpectedEndOfInput());
      }
      if (!state.ok) {
        break;
      }
      $12++;
    }
    if ($12 == 4) {
      state.setOk(true);
    } else {
      state.backtrack($11);
    }
    if (state.ok) {
      $7 = state.input.substring($9, state.pos);
    }
    if (state.ok) {
      int? $$;
      final v = $7!;
      $$ = int.parse(v, radix: 16);
      $0 = $$;
    }
    if (!state.ok) {
      if (state.lastFailPos == $3) {
        state.errorCount = $2;
      } else if (state.lastFailPos > $3) {
        state.errorCount = 0;
      }
      final length = $5 - state.lastFailPos;
      state.failAt(state.lastFailPos,
          ErrorMessage(length, 'Expected 4 digit hex number'));
    }
    if (state.lastFailPos < $4) {
      state.lastFailPos = $4;
    }
    return $0;
  }

  /// Expression
  /// Identifier =
  ///   v:Identifier_ {}
  ///   ;
  Expression? parseIdentifier(State<String> state) {
    Expression? $0;
    // v:Identifier_ {}
    String? $1;
    // String @inline Identifier_ = v:@expected('identifier', $([a-zA-Z_$] [a-zA-Z_$0-9]*)) Spaces ;
    // v:@expected('identifier', $([a-zA-Z_$] [a-zA-Z_$0-9]*)) Spaces
    final $4 = state.pos;
    String? $3;
    final $5 = state.pos;
    final $6 = state.errorCount;
    final $7 = state.failPos;
    final $8 = state.lastFailPos;
    state.lastFailPos = -1;
    // $([a-zA-Z_$] [a-zA-Z_$0-9]*)
    final $10 = state.pos;
    // [a-zA-Z_$] [a-zA-Z_$0-9]*
    final $11 = state.pos;
    if (state.pos < state.input.length) {
      final $12 = state.input.codeUnitAt(state.pos);
      final $13 = $12 < 65
          ? $12 == 36
          : $12 <= 90 || $12 == 95 || $12 >= 97 && $12 <= 122;
      if ($13) {
        state.pos++;
        state.setOk(true);
      } else {
        state.fail(const ErrorUnexpectedCharacter());
      }
    } else {
      state.fail(const ErrorUnexpectedEndOfInput());
    }
    if (state.ok) {
      for (var c = 0;
          state.pos < state.input.length &&
              (c = state.input.codeUnitAt(state.pos)) == c &&
              (c < 65
                  ? c == 36 || c >= 48 && c <= 57
                  : c <= 90 || c == 95 || c >= 97 && c <= 122);
          // ignore: curly_braces_in_flow_control_structures, empty_statements
          state.pos++);
      state.setOk(true);
    }
    if (!state.ok) {
      state.backtrack($11);
    }
    if (state.ok) {
      $3 = state.input.substring($10, state.pos);
    }
    if (!state.ok && state.lastFailPos == $5) {
      if (state.lastFailPos == $7) {
        state.errorCount = $6;
      } else if (state.lastFailPos > $7) {
        state.errorCount = 0;
      }
      state.fail(const ErrorExpectedTags(['identifier']));
    }
    if (state.lastFailPos < $8) {
      state.lastFailPos = $8;
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $1 = $3;
      }
    }
    if (!state.ok) {
      state.backtrack($4);
    }
    if (state.ok) {
      Expression? $$;
      final v = $1!;
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

  /// Expression
  /// IfNull =
  ///   h:LogicalOr t:(op:IfNullOp ↑ expr:LogicalOr)* {}
  ///   ;
  Expression? parseIfNull(State<String> state) {
    Expression? $0;
    // h:LogicalOr t:(op:IfNullOp ↑ expr:LogicalOr)* {}
    final $3 = state.pos;
    Expression? $1;
    // LogicalOr
    $1 = parseLogicalOr(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $2;
      final $5 = <({String op, Expression expr})>[];
      final $4 = state.ignoreErrors;
      state.ignoreErrors = true;
      while (true) {
        ({String op, Expression expr})? $6;
        // op:IfNullOp ↑ expr:LogicalOr
        final $11 = state.pos;
        var $9 = true;
        final $10 = state.ignoreErrors;
        String? $7;
        // IfNullOp
        $7 = parseIfNullOp(state);
        if (state.ok) {
          $9 = false;
          state.ignoreErrors = false;
          state.setOk(true);
          if (state.ok) {
            Expression? $8;
            // LogicalOr
            $8 = parseLogicalOr(state);
            if (state.ok) {
              $6 = (op: $7!, expr: $8!);
            }
          }
        }
        if (!state.ok) {
          if (!$9) {
            state.isRecoverable = false;
          }
          state.backtrack($11);
        }
        state.ignoreErrors = $10;
        if (!state.ok) {
          break;
        }
        $5.add($6!);
      }
      state.ignoreErrors = $4;
      state.setOk(true);
      if (state.ok) {
        $2 = $5;
      }
      if (state.ok) {
        Expression? $$;
        final h = $1!;
        final t = $2!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.backtrack($3);
    }
    return $0;
  }

  /// IfNullOp =
  ///   v:'??' Spaces
  ///   ;
  String? parseIfNullOp(State<String> state) {
    String? $0;
    // v:'??' Spaces
    final $2 = state.pos;
    String? $1;
    const $3 = '??';
    final $4 = state.pos + 1 < state.input.length &&
        state.input.codeUnitAt(state.pos) == 63 &&
        state.input.codeUnitAt(state.pos + 1) == 63;
    if ($4) {
      state.pos += 2;
      state.setOk(true);
      $1 = $3;
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $1;
      }
    }
    if (!state.ok) {
      state.backtrack($2);
    }
    return $0;
  }

  /// Expression
  /// LogicalAnd =
  ///   h:Equality t:(op:LogicalAndOp ↑ expr:Equality)* {}
  ///   ;
  Expression? parseLogicalAnd(State<String> state) {
    Expression? $0;
    // h:Equality t:(op:LogicalAndOp ↑ expr:Equality)* {}
    final $3 = state.pos;
    Expression? $1;
    // Equality
    $1 = parseEquality(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $2;
      final $5 = <({String op, Expression expr})>[];
      final $4 = state.ignoreErrors;
      state.ignoreErrors = true;
      while (true) {
        ({String op, Expression expr})? $6;
        // op:LogicalAndOp ↑ expr:Equality
        final $11 = state.pos;
        var $9 = true;
        final $10 = state.ignoreErrors;
        String? $7;
        // LogicalAndOp
        $7 = parseLogicalAndOp(state);
        if (state.ok) {
          $9 = false;
          state.ignoreErrors = false;
          state.setOk(true);
          if (state.ok) {
            Expression? $8;
            // Equality
            $8 = parseEquality(state);
            if (state.ok) {
              $6 = (op: $7!, expr: $8!);
            }
          }
        }
        if (!state.ok) {
          if (!$9) {
            state.isRecoverable = false;
          }
          state.backtrack($11);
        }
        state.ignoreErrors = $10;
        if (!state.ok) {
          break;
        }
        $5.add($6!);
      }
      state.ignoreErrors = $4;
      state.setOk(true);
      if (state.ok) {
        $2 = $5;
      }
      if (state.ok) {
        Expression? $$;
        final h = $1!;
        final t = $2!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.backtrack($3);
    }
    return $0;
  }

  /// LogicalAndOp =
  ///   v:'&&' Spaces
  ///   ;
  String? parseLogicalAndOp(State<String> state) {
    String? $0;
    // v:'&&' Spaces
    final $2 = state.pos;
    String? $1;
    const $3 = '&&';
    final $4 = state.pos + 1 < state.input.length &&
        state.input.codeUnitAt(state.pos) == 38 &&
        state.input.codeUnitAt(state.pos + 1) == 38;
    if ($4) {
      state.pos += 2;
      state.setOk(true);
      $1 = $3;
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $1;
      }
    }
    if (!state.ok) {
      state.backtrack($2);
    }
    return $0;
  }

  /// Expression
  /// LogicalOr =
  ///   h:LogicalAnd t:(op:LogicalOrOp ↑ expr:LogicalAnd)* {}
  ///   ;
  Expression? parseLogicalOr(State<String> state) {
    Expression? $0;
    // h:LogicalAnd t:(op:LogicalOrOp ↑ expr:LogicalAnd)* {}
    final $3 = state.pos;
    Expression? $1;
    // LogicalAnd
    $1 = parseLogicalAnd(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $2;
      final $5 = <({String op, Expression expr})>[];
      final $4 = state.ignoreErrors;
      state.ignoreErrors = true;
      while (true) {
        ({String op, Expression expr})? $6;
        // op:LogicalOrOp ↑ expr:LogicalAnd
        final $11 = state.pos;
        var $9 = true;
        final $10 = state.ignoreErrors;
        String? $7;
        // LogicalOrOp
        $7 = parseLogicalOrOp(state);
        if (state.ok) {
          $9 = false;
          state.ignoreErrors = false;
          state.setOk(true);
          if (state.ok) {
            Expression? $8;
            // LogicalAnd
            $8 = parseLogicalAnd(state);
            if (state.ok) {
              $6 = (op: $7!, expr: $8!);
            }
          }
        }
        if (!state.ok) {
          if (!$9) {
            state.isRecoverable = false;
          }
          state.backtrack($11);
        }
        state.ignoreErrors = $10;
        if (!state.ok) {
          break;
        }
        $5.add($6!);
      }
      state.ignoreErrors = $4;
      state.setOk(true);
      if (state.ok) {
        $2 = $5;
      }
      if (state.ok) {
        Expression? $$;
        final h = $1!;
        final t = $2!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.backtrack($3);
    }
    return $0;
  }

  /// LogicalOrOp =
  ///   v:'||' Spaces
  ///   ;
  String? parseLogicalOrOp(State<String> state) {
    String? $0;
    // v:'||' Spaces
    final $2 = state.pos;
    String? $1;
    const $3 = '||';
    final $4 = state.pos + 1 < state.input.length &&
        state.input.codeUnitAt(state.pos) == 124 &&
        state.input.codeUnitAt(state.pos + 1) == 124;
    if ($4) {
      state.pos += 2;
      state.setOk(true);
      $1 = $3;
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $1;
      }
    }
    if (!state.ok) {
      state.backtrack($2);
    }
    return $0;
  }

  /// Expression
  /// Multiplicative =
  ///   h:UnaryPrefix t:(op:MultiplicativeOp ↑ expr:UnaryPrefix)* {}
  ///   ;
  Expression? parseMultiplicative(State<String> state) {
    Expression? $0;
    // h:UnaryPrefix t:(op:MultiplicativeOp ↑ expr:UnaryPrefix)* {}
    final $3 = state.pos;
    Expression? $1;
    // UnaryPrefix
    $1 = parseUnaryPrefix(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $2;
      final $5 = <({String op, Expression expr})>[];
      final $4 = state.ignoreErrors;
      state.ignoreErrors = true;
      while (true) {
        ({String op, Expression expr})? $6;
        // op:MultiplicativeOp ↑ expr:UnaryPrefix
        final $11 = state.pos;
        var $9 = true;
        final $10 = state.ignoreErrors;
        String? $7;
        // MultiplicativeOp
        $7 = parseMultiplicativeOp(state);
        if (state.ok) {
          $9 = false;
          state.ignoreErrors = false;
          state.setOk(true);
          if (state.ok) {
            Expression? $8;
            // UnaryPrefix
            $8 = parseUnaryPrefix(state);
            if (state.ok) {
              $6 = (op: $7!, expr: $8!);
            }
          }
        }
        if (!state.ok) {
          if (!$9) {
            state.isRecoverable = false;
          }
          state.backtrack($11);
        }
        state.ignoreErrors = $10;
        if (!state.ok) {
          break;
        }
        $5.add($6!);
      }
      state.ignoreErrors = $4;
      state.setOk(true);
      if (state.ok) {
        $2 = $5;
      }
      if (state.ok) {
        Expression? $$;
        final h = $1!;
        final t = $2!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.backtrack($3);
    }
    return $0;
  }

  /// MultiplicativeOp =
  ///   v:('/' / '*' / '%' / '~/') Spaces
  ///   ;
  String? parseMultiplicativeOp(State<String> state) {
    String? $0;
    // v:('/' / '*' / '%' / '~/') Spaces
    final $2 = state.pos;
    String? $1;
    final $4 = state.pos;
    var $3 = 0;
    if (state.pos < state.input.length) {
      final input = state.input;
      final c = input.codeUnitAt(state.pos);
      // ignore: unused_local_variable
      final pos2 = state.pos + 1;
      switch (c) {
        case 47:
          $3 = 1;
          $1 = '/';
          break;
        case 42:
          $3 = 1;
          $1 = '*';
          break;
        case 37:
          $3 = 1;
          $1 = '%';
          break;
        case 126:
          final ok = pos2 < input.length && input.codeUnitAt(pos2) == 47;
          if (ok) {
            $3 = 2;
            $1 = '~/';
          }
          break;
      }
    }
    if ($3 > 0) {
      state.pos += $3;
      state.setOk(true);
    } else {
      state.pos = $4;
      state.fail(const ErrorExpectedTags(['/', '*', '%', '~/']));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $1;
      }
    }
    if (!state.ok) {
      state.backtrack($2);
    }
    return $0;
  }

  /// NamedArgument =
  ///   name:Identifier_ Colon expr:Expression
  ///   ;
  ({String name, Expression expr})? parseNamedArgument(State<String> state) {
    ({String name, Expression expr})? $0;
    // name:Identifier_ Colon expr:Expression
    final $3 = state.pos;
    String? $1;
    // String @inline Identifier_ = v:@expected('identifier', $([a-zA-Z_$] [a-zA-Z_$0-9]*)) Spaces ;
    // v:@expected('identifier', $([a-zA-Z_$] [a-zA-Z_$0-9]*)) Spaces
    final $5 = state.pos;
    String? $4;
    final $6 = state.pos;
    final $7 = state.errorCount;
    final $8 = state.failPos;
    final $9 = state.lastFailPos;
    state.lastFailPos = -1;
    // $([a-zA-Z_$] [a-zA-Z_$0-9]*)
    final $11 = state.pos;
    // [a-zA-Z_$] [a-zA-Z_$0-9]*
    final $12 = state.pos;
    if (state.pos < state.input.length) {
      final $13 = state.input.codeUnitAt(state.pos);
      final $14 = $13 < 65
          ? $13 == 36
          : $13 <= 90 || $13 == 95 || $13 >= 97 && $13 <= 122;
      if ($14) {
        state.pos++;
        state.setOk(true);
      } else {
        state.fail(const ErrorUnexpectedCharacter());
      }
    } else {
      state.fail(const ErrorUnexpectedEndOfInput());
    }
    if (state.ok) {
      for (var c = 0;
          state.pos < state.input.length &&
              (c = state.input.codeUnitAt(state.pos)) == c &&
              (c < 65
                  ? c == 36 || c >= 48 && c <= 57
                  : c <= 90 || c == 95 || c >= 97 && c <= 122);
          // ignore: curly_braces_in_flow_control_structures, empty_statements
          state.pos++);
      state.setOk(true);
    }
    if (!state.ok) {
      state.backtrack($12);
    }
    if (state.ok) {
      $4 = state.input.substring($11, state.pos);
    }
    if (!state.ok && state.lastFailPos == $6) {
      if (state.lastFailPos == $8) {
        state.errorCount = $7;
      } else if (state.lastFailPos > $8) {
        state.errorCount = 0;
      }
      state.fail(const ErrorExpectedTags(['identifier']));
    }
    if (state.lastFailPos < $9) {
      state.lastFailPos = $9;
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $1 = $4;
      }
    }
    if (!state.ok) {
      state.backtrack($5);
    }
    if (state.ok) {
      // Colon
      fastParseColon(state);
      if (state.ok) {
        Expression? $2;
        // Expression
        $2 = parseExpression(state);
        if (state.ok) {
          $0 = (name: $1!, expr: $2!);
        }
      }
    }
    if (!state.ok) {
      state.backtrack($3);
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
    final $3 = state.pos + 3 < state.input.length &&
        state.input.codeUnitAt(state.pos) == 110 &&
        state.input.codeUnitAt(state.pos + 1) == 117 &&
        state.input.codeUnitAt(state.pos + 2) == 108 &&
        state.input.codeUnitAt(state.pos + 3) == 108;
    if ($3) {
      state.pos += 4;
      state.setOk(true);
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
      state.backtrack($1);
    }
    return $0;
  }

  /// Expression
  /// Number =
  ///   v:$([-]? ([0] / [1-9] [0-9]*) ([.] [0-9]+)? ([eE] ↑ [-+]? [0-9]+)?) Spaces {}
  ///   ;
  Expression? parseNumber(State<String> state) {
    Expression? $0;
    // v:$([-]? ([0] / [1-9] [0-9]*) ([.] [0-9]+)? ([eE] ↑ [-+]? [0-9]+)?) Spaces {}
    final $2 = state.pos;
    String? $1;
    final $3 = state.pos;
    // [-]? ([0] / [1-9] [0-9]*) ([.] [0-9]+)? ([eE] ↑ [-+]? [0-9]+)?
    final $4 = state.pos;
    final $5 = state.ignoreErrors;
    state.ignoreErrors = true;
    if (state.pos < state.input.length) {
      final ok = state.input.codeUnitAt(state.pos) == 45;
      if (ok) {
        state.pos++;
        state.setOk(true);
      } else {
        state.fail(const ErrorUnexpectedCharacter());
      }
    } else {
      state.fail(const ErrorUnexpectedEndOfInput());
    }
    state.ignoreErrors = $5;
    if (!state.ok) {
      state.setOk(true);
    }
    if (state.ok) {
      // [0]
      if (state.pos < state.input.length) {
        final ok = state.input.codeUnitAt(state.pos) == 48;
        if (ok) {
          state.pos++;
          state.setOk(true);
        } else {
          state.fail(const ErrorUnexpectedCharacter());
        }
      } else {
        state.fail(const ErrorUnexpectedEndOfInput());
      }
      if (!state.ok && state.isRecoverable) {
        // [1-9] [0-9]*
        final $7 = state.pos;
        if (state.pos < state.input.length) {
          final $8 = state.input.codeUnitAt(state.pos);
          final $9 = $8 >= 49 && $8 <= 57;
          if ($9) {
            state.pos++;
            state.setOk(true);
          } else {
            state.fail(const ErrorUnexpectedCharacter());
          }
        } else {
          state.fail(const ErrorUnexpectedEndOfInput());
        }
        if (state.ok) {
          for (var c = 0;
              state.pos < state.input.length &&
                  (c = state.input.codeUnitAt(state.pos)) == c &&
                  (c >= 48 && c <= 57);
              // ignore: curly_braces_in_flow_control_structures, empty_statements
              state.pos++);
          state.setOk(true);
        }
        if (!state.ok) {
          state.backtrack($7);
        }
      }
      if (state.ok) {
        final $10 = state.ignoreErrors;
        state.ignoreErrors = true;
        // [.] [0-9]+
        final $11 = state.pos;
        if (state.pos < state.input.length) {
          final ok = state.input.codeUnitAt(state.pos) == 46;
          if (ok) {
            state.pos++;
            state.setOk(true);
          } else {
            state.fail(const ErrorUnexpectedCharacter());
          }
        } else {
          state.fail(const ErrorUnexpectedEndOfInput());
        }
        if (state.ok) {
          var $12 = false;
          for (var c = 0;
              state.pos < state.input.length &&
                  (c = state.input.codeUnitAt(state.pos)) == c &&
                  (c >= 48 && c <= 57);
              state.pos++,
              // ignore: curly_braces_in_flow_control_structures, empty_statements
              $12 = true);
          if ($12) {
            state.setOk($12);
          } else {
            state.pos < state.input.length
                ? state.fail(const ErrorUnexpectedCharacter())
                : state.fail(const ErrorUnexpectedEndOfInput());
          }
        }
        if (!state.ok) {
          state.backtrack($11);
        }
        state.ignoreErrors = $10;
        if (!state.ok) {
          state.setOk(true);
        }
        if (state.ok) {
          final $13 = state.ignoreErrors;
          state.ignoreErrors = true;
          // [eE] ↑ [-+]? [0-9]+
          final $16 = state.pos;
          var $14 = true;
          final $15 = state.ignoreErrors;
          if (state.pos < state.input.length) {
            final $17 = state.input.codeUnitAt(state.pos);
            final $18 = $17 == 69 || $17 == 101;
            if ($18) {
              state.pos++;
              state.setOk(true);
            } else {
              state.fail(const ErrorUnexpectedCharacter());
            }
          } else {
            state.fail(const ErrorUnexpectedEndOfInput());
          }
          if (state.ok) {
            $14 = false;
            state.ignoreErrors = false;
            state.setOk(true);
            if (state.ok) {
              final $19 = state.ignoreErrors;
              state.ignoreErrors = true;
              if (state.pos < state.input.length) {
                final $20 = state.input.codeUnitAt(state.pos);
                final $21 = $20 == 43 || $20 == 45;
                if ($21) {
                  state.pos++;
                  state.setOk(true);
                } else {
                  state.fail(const ErrorUnexpectedCharacter());
                }
              } else {
                state.fail(const ErrorUnexpectedEndOfInput());
              }
              state.ignoreErrors = $19;
              if (!state.ok) {
                state.setOk(true);
              }
              if (state.ok) {
                var $22 = false;
                for (var c = 0;
                    state.pos < state.input.length &&
                        (c = state.input.codeUnitAt(state.pos)) == c &&
                        (c >= 48 && c <= 57);
                    state.pos++,
                    // ignore: curly_braces_in_flow_control_structures, empty_statements
                    $22 = true);
                if ($22) {
                  state.setOk($22);
                } else {
                  state.pos < state.input.length
                      ? state.fail(const ErrorUnexpectedCharacter())
                      : state.fail(const ErrorUnexpectedEndOfInput());
                }
              }
            }
          }
          if (!state.ok) {
            if (!$14) {
              state.isRecoverable = false;
            }
            state.backtrack($16);
          }
          state.ignoreErrors = $15;
          state.ignoreErrors = $13;
          if (!state.ok) {
            state.setOk(true);
          }
        }
      }
    }
    if (!state.ok) {
      state.backtrack($4);
    }
    if (state.ok) {
      $1 = state.input.substring($3, state.pos);
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        Expression? $$;
        final v = $1!;
        final n = num.parse(v);
        $$ = () => n;
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.backtrack($2);
    }
    return $0;
  }

  /// OpenBracket =
  ///   v:'[' Spaces
  ///   ;
  String? parseOpenBracket(State<String> state) {
    String? $0;
    // v:'[' Spaces
    final $2 = state.pos;
    String? $1;
    const $3 = '[';
    final $4 = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 91;
    if ($4) {
      state.pos++;
      state.setOk(true);
      $1 = $3;
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $1;
      }
    }
    if (!state.ok) {
      state.backtrack($2);
    }
    return $0;
  }

  /// OpenParenthesis =
  ///   v:'(' Spaces
  ///   ;
  String? parseOpenParenthesis(State<String> state) {
    String? $0;
    // v:'(' Spaces
    final $2 = state.pos;
    String? $1;
    const $3 = '(';
    final $4 = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 40;
    if ($4) {
      state.pos++;
      state.setOk(true);
      $1 = $3;
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $1;
      }
    }
    if (!state.ok) {
      state.backtrack($2);
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
    final $3 = state.pos;
    String? $1;
    state.setOk(true);
    if (state.ok) {
      $1 = '';
    }
    if (state.ok) {
      Expression? $2;
      // Expression
      $2 = parseExpression(state);
      if (state.ok) {
        $0 = (name: $1!, expr: $2!);
      }
    }
    if (!state.ok) {
      state.backtrack($3);
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
    if (!state.ok && state.isRecoverable) {
      // Boolean
      // Boolean
      $0 = parseBoolean(state);
      if (!state.ok && state.isRecoverable) {
        // String
        // String
        $0 = parseString(state);
        if (!state.ok && state.isRecoverable) {
          // Null
          // Null
          $0 = parseNull(state);
          if (!state.ok && state.isRecoverable) {
            // Identifier
            // Identifier
            $0 = parseIdentifier(state);
            if (!state.ok && state.isRecoverable) {
              // OpenParenthesis v:Expression CloseParenthesis
              final $7 = state.pos;
              // OpenParenthesis
              fastParseOpenParenthesis(state);
              if (state.ok) {
                Expression? $6;
                // Expression
                $6 = parseExpression(state);
                if (state.ok) {
                  // CloseParenthesis
                  fastParseCloseParenthesis(state);
                  if (state.ok) {
                    $0 = $6;
                  }
                }
              }
              if (!state.ok) {
                state.backtrack($7);
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
  ///   h:BitwiseOr t:(op:RelationalOp ↑ expr:BitwiseOr)* {}
  ///   ;
  Expression? parseRelational(State<String> state) {
    Expression? $0;
    // h:BitwiseOr t:(op:RelationalOp ↑ expr:BitwiseOr)* {}
    final $3 = state.pos;
    Expression? $1;
    // BitwiseOr
    $1 = parseBitwiseOr(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $2;
      final $5 = <({String op, Expression expr})>[];
      final $4 = state.ignoreErrors;
      state.ignoreErrors = true;
      while (true) {
        ({String op, Expression expr})? $6;
        // op:RelationalOp ↑ expr:BitwiseOr
        final $11 = state.pos;
        var $9 = true;
        final $10 = state.ignoreErrors;
        String? $7;
        // RelationalOp
        $7 = parseRelationalOp(state);
        if (state.ok) {
          $9 = false;
          state.ignoreErrors = false;
          state.setOk(true);
          if (state.ok) {
            Expression? $8;
            // BitwiseOr
            $8 = parseBitwiseOr(state);
            if (state.ok) {
              $6 = (op: $7!, expr: $8!);
            }
          }
        }
        if (!state.ok) {
          if (!$9) {
            state.isRecoverable = false;
          }
          state.backtrack($11);
        }
        state.ignoreErrors = $10;
        if (!state.ok) {
          break;
        }
        $5.add($6!);
      }
      state.ignoreErrors = $4;
      state.setOk(true);
      if (state.ok) {
        $2 = $5;
      }
      if (state.ok) {
        Expression? $$;
        final h = $1!;
        final t = $2!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.backtrack($3);
    }
    return $0;
  }

  /// RelationalOp =
  ///   v:('>=' / '>' / '<=' / '<') Spaces
  ///   ;
  String? parseRelationalOp(State<String> state) {
    String? $0;
    // v:('>=' / '>' / '<=' / '<') Spaces
    final $2 = state.pos;
    String? $1;
    final $4 = state.pos;
    var $3 = 0;
    if (state.pos < state.input.length) {
      final input = state.input;
      final c = input.codeUnitAt(state.pos);
      // ignore: unused_local_variable
      final pos2 = state.pos + 1;
      switch (c) {
        case 62:
          final ok = pos2 < input.length && input.codeUnitAt(pos2) == 61;
          if (ok) {
            $3 = 2;
            $1 = '>=';
          } else {
            $3 = 1;
            $1 = '>';
          }
          break;
        case 60:
          final ok = pos2 < input.length && input.codeUnitAt(pos2) == 61;
          if (ok) {
            $3 = 2;
            $1 = '<=';
          } else {
            $3 = 1;
            $1 = '<';
          }
          break;
      }
    }
    if ($3 > 0) {
      state.pos += $3;
      state.setOk(true);
    } else {
      state.pos = $4;
      state.fail(const ErrorExpectedTags(['>=', '>', '<=', '<']));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $1;
      }
    }
    if (!state.ok) {
      state.backtrack($2);
    }
    return $0;
  }

  /// ({String kind, dynamic arguments})
  /// Selector =
  ///     kind:Dot arguments:Identifier_
  ///   / kind:OpenBracket arguments:Expression CloseBracket
  ///   / kind:OpenParenthesis arguments:Arguments CloseParenthesis
  ///   ;
  ({String kind, dynamic arguments})? parseSelector(State<String> state) {
    ({String kind, dynamic arguments})? $0;
    // kind:Dot arguments:Identifier_
    final $3 = state.pos;
    String? $1;
    // Dot
    $1 = parseDot(state);
    if (state.ok) {
      String? $2;
      // String @inline Identifier_ = v:@expected('identifier', $([a-zA-Z_$] [a-zA-Z_$0-9]*)) Spaces ;
      // v:@expected('identifier', $([a-zA-Z_$] [a-zA-Z_$0-9]*)) Spaces
      final $5 = state.pos;
      String? $4;
      final $6 = state.pos;
      final $7 = state.errorCount;
      final $8 = state.failPos;
      final $9 = state.lastFailPos;
      state.lastFailPos = -1;
      // $([a-zA-Z_$] [a-zA-Z_$0-9]*)
      final $11 = state.pos;
      // [a-zA-Z_$] [a-zA-Z_$0-9]*
      final $12 = state.pos;
      if (state.pos < state.input.length) {
        final $13 = state.input.codeUnitAt(state.pos);
        final $14 = $13 < 65
            ? $13 == 36
            : $13 <= 90 || $13 == 95 || $13 >= 97 && $13 <= 122;
        if ($14) {
          state.pos++;
          state.setOk(true);
        } else {
          state.fail(const ErrorUnexpectedCharacter());
        }
      } else {
        state.fail(const ErrorUnexpectedEndOfInput());
      }
      if (state.ok) {
        for (var c = 0;
            state.pos < state.input.length &&
                (c = state.input.codeUnitAt(state.pos)) == c &&
                (c < 65
                    ? c == 36 || c >= 48 && c <= 57
                    : c <= 90 || c == 95 || c >= 97 && c <= 122);
            // ignore: curly_braces_in_flow_control_structures, empty_statements
            state.pos++);
        state.setOk(true);
      }
      if (!state.ok) {
        state.backtrack($12);
      }
      if (state.ok) {
        $4 = state.input.substring($11, state.pos);
      }
      if (!state.ok && state.lastFailPos == $6) {
        if (state.lastFailPos == $8) {
          state.errorCount = $7;
        } else if (state.lastFailPos > $8) {
          state.errorCount = 0;
        }
        state.fail(const ErrorExpectedTags(['identifier']));
      }
      if (state.lastFailPos < $9) {
        state.lastFailPos = $9;
      }
      if (state.ok) {
        // Spaces
        fastParseSpaces(state);
        if (state.ok) {
          $2 = $4;
        }
      }
      if (!state.ok) {
        state.backtrack($5);
      }
      if (state.ok) {
        $0 = (kind: $1!, arguments: $2!);
      }
    }
    if (!state.ok) {
      state.backtrack($3);
    }
    if (!state.ok && state.isRecoverable) {
      // kind:OpenBracket arguments:Expression CloseBracket
      final $17 = state.pos;
      String? $15;
      // OpenBracket
      $15 = parseOpenBracket(state);
      if (state.ok) {
        Expression? $16;
        // Expression
        $16 = parseExpression(state);
        if (state.ok) {
          // CloseBracket
          fastParseCloseBracket(state);
          if (state.ok) {
            $0 = (kind: $15!, arguments: $16!);
          }
        }
      }
      if (!state.ok) {
        state.backtrack($17);
      }
      if (!state.ok && state.isRecoverable) {
        // kind:OpenParenthesis arguments:Arguments CloseParenthesis
        final $20 = state.pos;
        String? $18;
        // OpenParenthesis
        $18 = parseOpenParenthesis(state);
        if (state.ok) {
          List<({String name, Expression expr})>? $19;
          // Arguments
          $19 = parseArguments(state);
          if (state.ok) {
            // CloseParenthesis
            fastParseCloseParenthesis(state);
            if (state.ok) {
              $0 = (kind: $18!, arguments: $19!);
            }
          }
        }
        if (!state.ok) {
          state.backtrack($20);
        }
      }
    }
    return $0;
  }

  /// Expression
  /// Shift =
  ///   h:Additive t:(op:ShiftOp ↑ expr:Additive)* {}
  ///   ;
  Expression? parseShift(State<String> state) {
    Expression? $0;
    // h:Additive t:(op:ShiftOp ↑ expr:Additive)* {}
    final $3 = state.pos;
    Expression? $1;
    // Additive
    $1 = parseAdditive(state);
    if (state.ok) {
      List<({String op, Expression expr})>? $2;
      final $5 = <({String op, Expression expr})>[];
      final $4 = state.ignoreErrors;
      state.ignoreErrors = true;
      while (true) {
        ({String op, Expression expr})? $6;
        // op:ShiftOp ↑ expr:Additive
        final $11 = state.pos;
        var $9 = true;
        final $10 = state.ignoreErrors;
        String? $7;
        // ShiftOp
        $7 = parseShiftOp(state);
        if (state.ok) {
          $9 = false;
          state.ignoreErrors = false;
          state.setOk(true);
          if (state.ok) {
            Expression? $8;
            // Additive
            $8 = parseAdditive(state);
            if (state.ok) {
              $6 = (op: $7!, expr: $8!);
            }
          }
        }
        if (!state.ok) {
          if (!$9) {
            state.isRecoverable = false;
          }
          state.backtrack($11);
        }
        state.ignoreErrors = $10;
        if (!state.ok) {
          break;
        }
        $5.add($6!);
      }
      state.ignoreErrors = $4;
      state.setOk(true);
      if (state.ok) {
        $2 = $5;
      }
      if (state.ok) {
        Expression? $$;
        final h = $1!;
        final t = $2!;
        $$ = t.isEmpty ? h : t.fold(h, _binary);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.backtrack($3);
    }
    return $0;
  }

  /// ShiftOp =
  ///   v:('<<' / '>>>' / '>>') Spaces
  ///   ;
  String? parseShiftOp(State<String> state) {
    String? $0;
    // v:('<<' / '>>>' / '>>') Spaces
    final $2 = state.pos;
    String? $1;
    final $4 = state.pos;
    var $3 = 0;
    if (state.pos < state.input.length) {
      final input = state.input;
      final c = input.codeUnitAt(state.pos);
      // ignore: unused_local_variable
      final pos2 = state.pos + 1;
      switch (c) {
        case 60:
          final ok = pos2 < input.length && input.codeUnitAt(pos2) == 60;
          if (ok) {
            $3 = 2;
            $1 = '<<';
          }
          break;
        case 62:
          final ok = pos2 + 1 < input.length &&
              input.codeUnitAt(pos2) == 62 &&
              input.codeUnitAt(pos2 + 1) == 62;
          if (ok) {
            $3 = 3;
            $1 = '>>>';
          } else {
            final ok = pos2 < input.length && input.codeUnitAt(pos2) == 62;
            if (ok) {
              $3 = 2;
              $1 = '>>';
            }
          }
          break;
      }
    }
    if ($3 > 0) {
      state.pos += $3;
      state.setOk(true);
    } else {
      state.pos = $4;
      state.fail(const ErrorExpectedTags(['<<', '>>>', '>>']));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $1;
      }
    }
    if (!state.ok) {
      state.backtrack($2);
    }
    return $0;
  }

  /// Start =
  ///   Spaces v:Expression Eof
  ///   ;
  Expression? parseStart(State<String> state) {
    Expression? $0;
    // Spaces v:Expression Eof
    final $2 = state.pos;
    // Spaces
    fastParseSpaces(state);
    if (state.ok) {
      Expression? $1;
      // Expression
      $1 = parseExpression(state);
      if (state.ok) {
        // Eof
        fastParseEof(state);
        if (state.ok) {
          $0 = $1;
        }
      }
    }
    if (!state.ok) {
      state.backtrack($2);
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
    String? $1;
    // StringRaw
    $1 = parseStringRaw(state);
    if (state.ok) {
      Expression? $$;
      final v = $1!;
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
    var $3 = false;
    for (var c = 0;
        state.pos < state.input.length &&
            (c = state.input.runeAt(state.pos)) == c &&
            (c < 35 ? c >= 32 && c <= 33 : c <= 91 || c >= 93 && c <= 1114111);
        state.pos += c > 0xffff ? 2 : 1,
        // ignore: curly_braces_in_flow_control_structures, empty_statements
        $3 = true);
    if ($3) {
      state.setOk($3);
    } else {
      state.pos < state.input.length
          ? state.fail(const ErrorUnexpectedCharacter())
          : state.fail(const ErrorUnexpectedEndOfInput());
    }
    if (state.ok) {
      $0 = state.input.substring($2, state.pos);
    }
    if (!state.ok && state.isRecoverable) {
      // '\\' v:(EscapeChar / EscapeHex)
      final $5 = state.pos;
      const $6 = '\\';
      final $7 = state.pos < state.input.length &&
          state.input.codeUnitAt(state.pos) == 92;
      if ($7) {
        state.pos++;
        state.setOk(true);
      } else {
        state.fail(const ErrorExpectedTags([$6]));
      }
      if (state.ok) {
        String? $4;
        // EscapeChar
        // String @inline EscapeChar = c:["/bfnrt\\] {} ;
        // c:["/bfnrt\\] {}
        int? $9;
        if (state.pos < state.input.length) {
          final $11 = state.input.codeUnitAt(state.pos);
          final $12 = $11 < 98
              ? $11 < 47
                  ? $11 == 34
                  : $11 <= 47 || $11 == 92
              : $11 <= 98 ||
                  ($11 < 110
                      ? $11 == 102
                      : $11 <= 110 || $11 == 114 || $11 == 116);
          if ($12) {
            state.pos++;
            state.setOk(true);
            $9 = $11;
          } else {
            state.fail(const ErrorUnexpectedCharacter());
          }
        } else {
          state.fail(const ErrorUnexpectedEndOfInput());
        }
        if (state.ok) {
          String? $$;
          final c = $9!;
          $$ = _escape(c);
          $4 = $$;
        }
        if (!state.ok && state.isRecoverable) {
          // EscapeHex
          // String @inline EscapeHex = 'u' v:HexNumber {} ;
          // 'u' v:HexNumber {}
          final $15 = state.pos;
          const $16 = 'u';
          final $17 = state.pos < state.input.length &&
              state.input.codeUnitAt(state.pos) == 117;
          if ($17) {
            state.pos++;
            state.setOk(true);
          } else {
            state.fail(const ErrorExpectedTags([$16]));
          }
          if (state.ok) {
            int? $14;
            // HexNumber
            $14 = parseHexNumber(state);
            if (state.ok) {
              String? $$;
              final v = $14!;
              $$ = String.fromCharCode(v);
              $4 = $$;
            }
          }
          if (!state.ok) {
            state.backtrack($15);
          }
        }
        if (state.ok) {
          $0 = $4;
        }
      }
      if (!state.ok) {
        state.backtrack($5);
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
    final $2 = state.pos;
    const $3 = '"';
    final $4 = state.pos < state.input.length &&
        state.input.codeUnitAt(state.pos) == 34;
    if ($4) {
      state.pos++;
      state.setOk(true);
    } else {
      state.fail(const ErrorExpectedTags([$3]));
    }
    if (state.ok) {
      List<String>? $1;
      final $6 = <String>[];
      final $5 = state.ignoreErrors;
      state.ignoreErrors = true;
      while (true) {
        String? $7;
        // StringChars
        $7 = parseStringChars(state);
        if (!state.ok) {
          break;
        }
        $6.add($7!);
      }
      state.ignoreErrors = $5;
      state.setOk(true);
      if (state.ok) {
        $1 = $6;
      }
      if (state.ok) {
        // DoubleQuote
        fastParseDoubleQuote(state);
        if (state.ok) {
          String? $$;
          final v = $1!;
          $$ = v.join();
          $0 = $$;
        }
      }
    }
    if (!state.ok) {
      state.backtrack($2);
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
    final $3 = state.pos;
    Expression? $1;
    // Primary
    $1 = parsePrimary(state);
    if (state.ok) {
      List<({String kind, dynamic arguments})>? $2;
      final $5 = <({String kind, dynamic arguments})>[];
      final $4 = state.ignoreErrors;
      state.ignoreErrors = true;
      while (true) {
        ({String kind, dynamic arguments})? $6;
        // Selector
        $6 = parseSelector(state);
        if (!state.ok) {
          break;
        }
        $5.add($6!);
      }
      state.ignoreErrors = $4;
      state.setOk(true);
      if (state.ok) {
        $2 = $5;
      }
      if (state.ok) {
        Expression? $$;
        final object = $1!;
        final selectors = $2!;
        $$ = _postfix(object, selectors);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.backtrack($3);
    }
    return $0;
  }

  /// UnaryPrefix =
  ///   @expected('expression', UnaryPrefix_)
  ///   ;
  Expression? parseUnaryPrefix(State<String> state) {
    Expression? $0;
    // @expected('expression', UnaryPrefix_)
    final $2 = state.pos;
    final $3 = state.errorCount;
    final $4 = state.failPos;
    final $5 = state.lastFailPos;
    state.lastFailPos = -1;
    // UnaryPrefix_
    // Expression @inline UnaryPrefix_ = op:UnaryPrefixOp? expr:UnaryPostfix {} ;
    // op:UnaryPrefixOp? expr:UnaryPostfix {}
    final $9 = state.pos;
    String? $7;
    final $10 = state.ignoreErrors;
    state.ignoreErrors = true;
    // UnaryPrefixOp
    $7 = parseUnaryPrefixOp(state);
    state.ignoreErrors = $10;
    if (!state.ok) {
      state.setOk(true);
    }
    if (state.ok) {
      Expression? $8;
      // UnaryPostfix
      $8 = parseUnaryPostfix(state);
      if (state.ok) {
        Expression? $$;
        final op = $7;
        final expr = $8!;
        $$ = _prefix(op, expr);
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.backtrack($9);
    }
    if (!state.ok && state.lastFailPos == $2) {
      if (state.lastFailPos == $4) {
        state.errorCount = $3;
      } else if (state.lastFailPos > $4) {
        state.errorCount = 0;
      }
      state.fail(const ErrorExpectedTags(['expression']));
    }
    if (state.lastFailPos < $5) {
      state.lastFailPos = $5;
    }
    return $0;
  }

  /// UnaryPrefixOp =
  ///   v:('-' / '!' / '~') Spaces
  ///   ;
  String? parseUnaryPrefixOp(State<String> state) {
    String? $0;
    // v:('-' / '!' / '~') Spaces
    final $2 = state.pos;
    String? $1;
    final $4 = state.pos;
    var $3 = 0;
    if (state.pos < state.input.length) {
      final input = state.input;
      final c = input.codeUnitAt(state.pos);
      // ignore: unused_local_variable
      final pos2 = state.pos + 1;
      switch (c) {
        case 45:
          $3 = 1;
          $1 = '-';
          break;
        case 33:
          $3 = 1;
          $1 = '!';
          break;
        case 126:
          $3 = 1;
          $1 = '~';
          break;
      }
    }
    if ($3 > 0) {
      state.pos += $3;
      state.setOk(true);
    } else {
      state.pos = $4;
      state.fail(const ErrorExpectedTags(['-', '!', '~']));
    }
    if (state.ok) {
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        $0 = $1;
      }
    }
    if (!state.ok) {
      state.backtrack($2);
    }
    return $0;
  }
}

void fastParseString(
    void Function(State<String> state) fastParse, String source) {
  final state = State(source);
  fastParse(state);
  if (state.ok) {
    return;
  }

  final parseResult = _createParseResult<String, Object?>(state, null);
  parseResult.getResult();
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
  final state = State(source);
  final result = parse(state);
  if (state.ok) {
    return result as O;
  }

  final parseResult = _createParseResult<String, O>(state, result);
  return parseResult.getResult();
}

ParseResult<I, O> tryParse<I, O>(O? Function(State<I> state) parse, I input) {
  final state = State(input);
  final result = parse(state);
  final parseResult = _createParseResult<I, O>(state, result);
  return parseResult;
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
    message = _errorMessage(input, 0, offset, normalized);
  } else if (input is ChunkedParsingSink) {
    message = _errorMessage(input.data, input.start, offset, normalized);
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
    String source, int inputStart, int offset, List<ErrorMessage> errors) {
  final sb = StringBuffer();
  final errorInfoList = errors
      .map((e) => (length: e.length, message: e.toString()))
      .toSet()
      .toList();
  final offsets =
      errors.map((e) => e.length < 0 ? offset + e.length : offset).toSet();
  final offsetMap = <int, ({int line, int column})>{};
  if (inputStart == 0) {
    var line = 1;
    var lineStart = 0, next = 0, pos = 0;
    while (pos < source.length) {
      final found = offsets.any((e) => pos == e);
      if (found) {
        final column = pos - lineStart + 1;
        offsetMap[pos] = (line: line, column: column);
        offsets.remove(pos);
        if (offsets.isEmpty) {
          break;
        }
      }

      final c = source.codeUnitAt(pos++);
      if (c == 0xa || c == 0xd) {
        next = c == 0xa ? 0xd : 0xa;
        if (pos < source.length && source.codeUnitAt(pos) == next) {
          pos++;
        }

        line++;
        lineStart = pos;
      }
    }
  }

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
    final inputLen = source.length;
    final lineLimit = min(80, inputLen);
    final start2 = start;
    final end2 = min(start2 + lineLimit, end);
    final errorLen = end2 - start;
    final extraLen = lineLimit - errorLen;
    final rightLen =
        min(inputStart + inputLen - end2, extraLen - (extraLen >> 1));
    final leftLen =
        min(start - inputStart, max(0, lineLimit - errorLen - rightLen));
    var index = start2 - 1 - inputStart;
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

    final left = String.fromCharCodes(list.reversed);
    final end3 = min(inputLen, start2 + (lineLimit - leftLen));
    final indicatorLen = max(1, errorLen);
    final right = source.substring(start - inputStart, end3);
    var text = left + right;
    text = text.replaceAll('\n', ' ');
    text = text.replaceAll('\r', ' ');
    text = text.replaceAll('\t', ' ');
    final location = offsetMap[start];
    if (location != null) {
      final line = location.line;
      final column = location.column;
      sb.writeln('line $line, column $column (offset $start): $message');
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
  if (errorList.isEmpty) {
    errorList.add(const ErrorUnknownError());
  }

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
    if (error is ErrorUnexpectedInput) {
      key = (ErrorUnexpectedInput, error.length);
    } else if (error is ErrorUnknownError) {
      key = ErrorUnknownError;
    } else if (error is ErrorUnexpectedCharacter) {
      key = (ErrorUnexpectedCharacter, error.char);
    }

    errorMap[key] = error;
  }

  return errorMap.values.toList();
}

class AsyncResult<T> {
  bool isComplete = false;

  void Function()? onComplete;

  T? value;
}

class ChunkedParsingSink implements Sink<String> {
  int bufferLoad = 0;

  int _cuttingPosition = 0;

  String data = '';

  int end = 0;

  void Function()? handle;

  bool sleep = false;

  int start = 0;

  int _buffering = 0;

  bool _isClosed = false;

  bool get isClosed => _isClosed;

  @override
  void add(String data) {
    if (_isClosed) {
      throw StateError('Chunked data sink already closed');
    }

    this.data = this.data.isNotEmpty ? '${this.data}$data' : data;
    final length = this.data.length;
    end = start + length;
    if (bufferLoad < length) {
      bufferLoad = length;
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

    if (_cuttingPosition > start) {
      this.data = _cuttingPosition != end
          ? this.data.substring(_cuttingPosition - start)
          : '';
      start = _cuttingPosition;
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

  void cut(int position) {
    if (position < start || position > end) {
      throw RangeError.range(position, start, end, 'position');
    }

    if (_buffering == 0) {
      _cuttingPosition = position;
    }
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void endBuffering() {
    if (--_buffering < 0) {
      throw StateError('Inconsistent buffering completion detected.');
    }
  }
}

class ErrorExpectedEndOfInput extends ParseError {
  static const message = 'Expected an end of input';

  const ErrorExpectedEndOfInput();

  @override
  ErrorMessage getErrorMessage(Object? input, offset) {
    return const ErrorMessage(0, ErrorExpectedEndOfInput.message);
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
    if (offset != null && offset >= 0) {
      if (input is String) {
        if (offset < input.length) {
          char = input.runeAt(offset);
        } else {
          argument = '<EOF>';
        }
      } else if (input is ChunkedParsingSink) {
        if (offset >= input.start && offset < input.end) {
          final index = offset - input.start;
          char = input.data.runeAt(index);
        } else if (input.isClosed && offset >= input.end) {
          argument = '<EOF>';
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
  int errorCount = 0;

  int failPos = 0;

  bool ignoreErrors = false;

  final T input;

  bool isRecoverable = true;

  int lastFailPos = -1;

  bool ok = false;

  int pos = 0;

  final List<ParseError?> _errors = List.filled(256, null, growable: false);

  State(this.input);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void backtrack(int pos) {
    if (isRecoverable) {
      this.pos = pos;
    }
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool fail(ParseError error) {
    return failAt(pos, error);
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool failAll(List<ParseError> errors) {
    return failAllAt(pos, errors);
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool failAllAt(int offset, List<ParseError> errors) {
    ok = false;
    if (!ignoreErrors || !isRecoverable) {
      if (offset >= failPos) {
        if (failPos < offset) {
          failPos = offset;
          errorCount = 0;
        }

        for (var i = 0; i < errors.length; i++) {
          if (errorCount < errors.length) {
            _errors[errorCount++] = errors[i];
          }
        }

        if (lastFailPos < offset) {
          lastFailPos = offset;
        }
      }
    }

    return false;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool failAt(int offset, ParseError error) {
    ok = false;
    if (!ignoreErrors || !isRecoverable) {
      if (offset >= failPos) {
        if (failPos < offset) {
          failPos = offset;
          errorCount = 0;
        }

        if (errorCount < _errors.length) {
          _errors[errorCount++] = error;
        }
      }
    }

    if (lastFailPos < offset) {
      lastFailPos = offset;
    }

    return false;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  List<ParseError> getErrors() {
    return List.generate(errorCount, (i) => _errors[i]!);
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void setOk(bool ok) {
    this.ok = !ok ? false : isRecoverable;
  }

  @override
  String toString() {
    if (input case final String input) {
      if (pos >= input.length) {
        return '$ok $pos:';
      }

      var length = input.length - pos;
      length = length > 40 ? 40 : length;
      final string = input.substring(pos, pos + length);
      return '$ok $pos:$string';
    } else if (input case final ChunkedParsingSink input) {
      final source = input.data;
      final pos = this.pos - input.start;
      if (pos < 0 || pos >= source.length) {
        return '$ok $pos:';
      }

      var length = source.length - pos;
      length = length > 40 ? 40 : length;
      final string = source.substring(pos, pos + length);
      return '$ok $pos:$string';
    }

    return super.toString();
  }
}

extension ParseStringExt on String {
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
