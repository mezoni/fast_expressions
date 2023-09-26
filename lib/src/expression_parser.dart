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
          final arguments2 = arguments as ({
            List<Expression>? positionalArguments,
            Map<Symbol, Expression>? namedArguments
          });
          final positionalArguments = arguments2.positionalArguments;
          final namedArguments = arguments2.namedArguments;
          object = () {
            final object3 = object2() as Function;
            var positionalArguments2 = const <dynamic>[];
            if (positionalArguments != null) {
              positionalArguments2 =
                  positionalArguments.map((e) => e()).toList();
            }

            var namedArguments2 = const <Symbol, dynamic>{};
            if (namedArguments != null) {
              final entries =
                  namedArguments.entries.map((e) => MapEntry(e.key, e.value()));
              namedArguments2 = Map.fromEntries(entries);
            }

            return Function.apply(
                object3, positionalArguments2, namedArguments2);
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
  void fastParseCloseBracket(State<StringReader> state) {
    // v:']' Spaces
    final $0 = state.pos;
    const $1 = ']';
    matchLiteral1(state, 93, $1, const ErrorExpectedTags([$1]));
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
  void fastParseCloseParenthesis(State<StringReader> state) {
    // v:')' Spaces
    final $0 = state.pos;
    const $1 = ')';
    matchLiteral1(state, 41, $1, const ErrorExpectedTags([$1]));
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
  void fastParseColon(State<StringReader> state) {
    // v:':' Spaces
    final $0 = state.pos;
    const $1 = ':';
    matchLiteral1(state, 58, $1, const ErrorExpectedTags([$1]));
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
  void fastParseComma(State<StringReader> state) {
    // v:',' Spaces
    final $0 = state.pos;
    const $1 = ',';
    matchLiteral1(state, 44, $1, const ErrorExpectedTags([$1]));
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
  void fastParseDoubleQuote(State<StringReader> state) {
    // v:'"' Spaces
    final $0 = state.pos;
    const $1 = '"';
    matchLiteral1(state, 34, $1, const ErrorExpectedTags([$1]));
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
  void fastParseEof(State<StringReader> state) {
    // !.
    state.ok = state.pos >= state.input.length;
    if (!state.ok) {
      state.fail(const ErrorUnexpectedCharacter());
    }
  }

  /// Exponent =
  ///   @errorHandler([-+]? [0-9]+)
  ///   ;
  void fastParseExponent(State<StringReader> state) {
    // @errorHandler([-+]? [0-9]+)
    final $1 = state.failPos;
    final $2 = state.errorCount;
    // [-+]? [0-9]+
    final $3 = state.pos;
    state.ok = state.pos < state.input.length;
    if (state.ok) {
      final $4 = state.input.readChar(state.pos);
      state.ok = $4 == 43 || $4 == 45;
      if (state.ok) {
        state.pos += state.input.count;
      }
    }
    if (!state.ok) {
      state.fail(const ErrorUnexpectedCharacter());
    }
    state.ok = true;
    if (state.ok) {
      var $5 = false;
      while (true) {
        state.ok = state.pos < state.input.length;
        if (state.ok) {
          final $6 = state.input.readChar(state.pos);
          state.ok = $6 >= 48 && $6 <= 57;
          if (state.ok) {
            state.pos += state.input.count;
          }
        }
        if (!state.ok) {
          state.fail(const ErrorUnexpectedCharacter());
        }
        if (!state.ok) {
          break;
        }
        $5 = true;
      }
      state.ok = $5;
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
  void fastParseFraction(State<StringReader> state) {
    // @errorHandler([0-9]+)
    final $1 = state.failPos;
    final $2 = state.errorCount;
    // [0-9]+
    var $4 = false;
    while (true) {
      state.ok = state.pos < state.input.length;
      if (state.ok) {
        final $5 = state.input.readChar(state.pos);
        state.ok = $5 >= 48 && $5 <= 57;
        if (state.ok) {
          state.pos += state.input.count;
        }
      }
      if (!state.ok) {
        state.fail(const ErrorUnexpectedCharacter());
      }
      if (!state.ok) {
        break;
      }
      $4 = true;
    }
    state.ok = $4;
    if (!state.ok && state._canHandleError($1, $2)) {
      ParseError? error;
      // ignore: prefer_final_locals
      var rollbackErrors = false;
      error = const ErrorExpectedTags(['fraction part']);
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
  void fastParseOpenParenthesis(State<StringReader> state) {
    // v:'(' Spaces
    final $0 = state.pos;
    const $1 = '(';
    matchLiteral1(state, 40, $1, const ErrorExpectedTags([$1]));
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
  void fastParseQuestion(State<StringReader> state) {
    // v:'?' Spaces
    final $0 = state.pos;
    const $1 = '?';
    matchLiteral1(state, 63, $1, const ErrorExpectedTags([$1]));
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
  void fastParseSpaces(State<StringReader> state) {
    // [ \n\r\t]*
    while (state.pos < state.input.length) {
      final $1 = state.input.readChar(state.pos);
      state.ok = $1 == 13 || $1 >= 9 && $1 <= 10 || $1 == 32;
      if (!state.ok) {
        break;
      }
      state.pos += state.input.count;
    }
    state.fail(const ErrorUnexpectedCharacter());
    state.ok = true;
  }

  /// Expression
  /// Additive =
  ///   h:Multiplicative t:(op:AdditiveOp expr:Multiplicative)*
  ///   ;
  Expression? parseAdditive(State<StringReader> state) {
    Expression? $0;
    // h:Multiplicative t:(op:AdditiveOp expr:Multiplicative)*
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
  String? parseAdditiveOp(State<StringReader> state) {
    String? $0;
    // v:('-' / '+') Spaces
    final $1 = state.pos;
    String? $2;
    state.ok = false;
    final $5 = state.input;
    if (state.pos < $5.length) {
      final $3 = $5.readChar(state.pos);
      // ignore: unused_local_variable
      final $4 = $5.count;
      switch ($3) {
        case 45:
          state.ok = true;
          state.pos += $4;
          $2 = '-';
          break;
        case 43:
          state.ok = true;
          state.pos += $4;
          $2 = '+';
          break;
      }
    }
    if (!state.ok) {
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

  /// ({List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments})
  /// Arguments =
  ///   positionalArguments:PositionalArguments namedArguments:NamedArguments
  ///   ;
  ({List<dynamic>? positionalArguments, Map<Symbol, dynamic>? namedArguments})?
      parseArguments(State<StringReader> state) {
    ({
      List<dynamic>? positionalArguments,
      Map<Symbol, dynamic>? namedArguments
    })? $0;
    // positionalArguments:PositionalArguments namedArguments:NamedArguments
    final $1 = state.pos;
    List<Expression>? $2;
    // PositionalArguments
    $2 = parsePositionalArguments(state);
    if (state.ok) {
      Map<Symbol, Expression>? $3;
      // NamedArguments
      $3 = parseNamedArguments(state);
      if (state.ok) {
        $0 = (positionalArguments: $2!, namedArguments: $3!);
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Expression
  /// BitwiseAnd =
  ///   h:Shift t:(op:BitwiseAndOp expr:Shift)*
  ///   ;
  Expression? parseBitwiseAnd(State<StringReader> state) {
    Expression? $0;
    // h:Shift t:(op:BitwiseAndOp expr:Shift)*
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
  String? parseBitwiseAndOp(State<StringReader> state) {
    String? $0;
    // v:'&' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '&';
    $2 = matchLiteral1(state, 38, $3, const ErrorExpectedTags([$3]));
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
  ///   h:BitwiseXor t:(op:BitwiseOrOp expr:BitwiseXor)*
  ///   ;
  Expression? parseBitwiseOr(State<StringReader> state) {
    Expression? $0;
    // h:BitwiseXor t:(op:BitwiseOrOp expr:BitwiseXor)*
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
  String? parseBitwiseOrOp(State<StringReader> state) {
    String? $0;
    // v:'|' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '|';
    $2 = matchLiteral1(state, 124, $3, const ErrorExpectedTags([$3]));
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
  ///   h:BitwiseAnd t:(op:BitwiseXorOp expr:BitwiseAnd)*
  ///   ;
  Expression? parseBitwiseXor(State<StringReader> state) {
    Expression? $0;
    // h:BitwiseAnd t:(op:BitwiseXorOp expr:BitwiseAnd)*
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
  String? parseBitwiseXorOp(State<StringReader> state) {
    String? $0;
    // v:'^' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '^';
    $2 = matchLiteral1(state, 94, $3, const ErrorExpectedTags([$3]));
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
  ///     'true' Spaces
  ///   / 'false' Spaces
  ///   ;
  Expression? parseBoolean(State<StringReader> state) {
    Expression? $0;
    // 'true' Spaces
    final $3 = state.pos;
    const $4 = 'true';
    matchLiteral(state, $4, const ErrorExpectedTags([$4]));
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
      state.pos = $3;
    }
    if (!state.ok) {
      // 'false' Spaces
      final $1 = state.pos;
      const $2 = 'false';
      matchLiteral(state, $2, const ErrorExpectedTags([$2]));
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
        state.pos = $1;
      }
    }
    return $0;
  }

  /// Expression
  /// Conditional =
  ///     e1:IfNull Question e2:Expression Colon e3:Expression
  ///   / IfNull
  ///   ;
  Expression? parseConditional(State<StringReader> state) {
    Expression? $0;
    // e1:IfNull Question e2:Expression Colon e3:Expression
    final $2 = state.pos;
    Expression? $3;
    // IfNull
    $3 = parseIfNull(state);
    if (state.ok) {
      // Question
      fastParseQuestion(state);
      if (state.ok) {
        Expression? $4;
        // Expression
        $4 = parseExpression(state);
        if (state.ok) {
          // Colon
          fastParseColon(state);
          if (state.ok) {
            Expression? $5;
            // Expression
            $5 = parseExpression(state);
            if (state.ok) {
              Expression? $$;
              final e1 = $3!;
              final e2 = $4!;
              final e3 = $5!;
              $$ = () => e1() as bool ? e2() : e3();
              $0 = $$;
            }
          }
        }
      }
    }
    if (!state.ok) {
      state.pos = $2;
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
  String? parseDot(State<StringReader> state) {
    String? $0;
    // v:'.' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '.';
    $2 = matchLiteral1(state, 46, $3, const ErrorExpectedTags([$3]));
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
  ///   h:Relational t:(op:EqualityOp expr:Relational)*
  ///   ;
  Expression? parseEquality(State<StringReader> state) {
    Expression? $0;
    // h:Relational t:(op:EqualityOp expr:Relational)*
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
  String? parseEqualityOp(State<StringReader> state) {
    String? $0;
    // v:('==' / '!=') Spaces
    final $1 = state.pos;
    String? $2;
    state.ok = false;
    final $5 = state.input;
    if (state.pos < $5.length) {
      final $3 = $5.readChar(state.pos);
      // ignore: unused_local_variable
      final $4 = $5.count;
      switch ($3) {
        case 61:
          state.ok = $5.matchChar(61, state.pos + $4);
          if (state.ok) {
            state.pos += $4 + $5.count;
            $2 = '==';
          }
          break;
        case 33:
          state.ok = $5.matchChar(61, state.pos + $4);
          if (state.ok) {
            state.pos += $4 + $5.count;
            $2 = '!=';
          }
          break;
      }
    }
    if (!state.ok) {
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
  Expression? parseExpression(State<StringReader> state) {
    Expression? $0;
    // Conditional
    // Conditional
    $0 = parseConditional(state);
    return $0;
  }

  /// HexNumber =
  ///   @errorHandler(HexNumberRaw)
  ///   ;
  int? parseHexNumber(State<StringReader> state) {
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
  ///   v:$([0-9A-Za-z]{4,4})
  ///   ;
  int? parseHexNumberRaw(State<StringReader> state) {
    int? $0;
    // v:$([0-9A-Za-z]{4,4})
    String? $2;
    final $3 = state.pos;
    // [0-9A-Za-z]{4,4}
    final $6 = state.pos;
    var $7 = 0;
    while ($7 < 4) {
      state.ok = state.pos < state.input.length;
      if (state.ok) {
        final $8 = state.input.readChar(state.pos);
        state.ok =
            $8 <= 90 ? $8 >= 48 && $8 <= 57 || $8 >= 65 : $8 >= 97 && $8 <= 122;
        if (state.ok) {
          state.pos += state.input.count;
        }
      }
      if (!state.ok) {
        state.fail(const ErrorUnexpectedCharacter());
      }
      if (!state.ok) {
        break;
      }
      $7++;
    }
    state.ok = $7 == 4;
    if (!state.ok) {
      state.pos = $6;
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
  ///   v:IdentifierRaw
  ///   ;
  Expression? parseIdentifier(State<StringReader> state) {
    Expression? $0;
    // v:IdentifierRaw
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
  String? parseIdentifierRaw(State<StringReader> state) {
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
      final $8 = state.input.readChar(state.pos);
      state.ok =
          $8 <= 90 ? $8 == 36 || $8 >= 65 : $8 == 95 || $8 >= 97 && $8 <= 122;
      if (state.ok) {
        state.pos += state.input.count;
      }
    }
    if (!state.ok) {
      state.fail(const ErrorUnexpectedCharacter());
    }
    if (state.ok) {
      while (state.pos < state.input.length) {
        final $9 = state.input.readChar(state.pos);
        state.ok = $9 <= 90
            ? $9 <= 57
                ? $9 == 36 || $9 >= 48
                : $9 >= 65
            : $9 == 95 || $9 >= 97 && $9 <= 122;
        if (!state.ok) {
          break;
        }
        state.pos += state.input.count;
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
  ///   h:LogicalOr t:(op:IfNullOp expr:LogicalOr)*
  ///   ;
  Expression? parseIfNull(State<StringReader> state) {
    Expression? $0;
    // h:LogicalOr t:(op:IfNullOp expr:LogicalOr)*
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
  String? parseIfNullOp(State<StringReader> state) {
    String? $0;
    // v:'??' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '??';
    $2 = matchLiteral(state, $3, const ErrorExpectedTags([$3]));
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
  ///   h:Equality t:(op:LogicalAndOp expr:Equality)*
  ///   ;
  Expression? parseLogicalAnd(State<StringReader> state) {
    Expression? $0;
    // h:Equality t:(op:LogicalAndOp expr:Equality)*
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
  String? parseLogicalAndOp(State<StringReader> state) {
    String? $0;
    // v:'&&' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '&&';
    $2 = matchLiteral(state, $3, const ErrorExpectedTags([$3]));
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
  ///   h:LogicalAnd t:(op:LogicalOrOp expr:LogicalAnd)*
  ///   ;
  Expression? parseLogicalOr(State<StringReader> state) {
    Expression? $0;
    // h:LogicalAnd t:(op:LogicalOrOp expr:LogicalAnd)*
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
  String? parseLogicalOrOp(State<StringReader> state) {
    String? $0;
    // v:'||' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '||';
    $2 = matchLiteral(state, $3, const ErrorExpectedTags([$3]));
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
  ///   h:UnaryPrefix t:(op:MultiplicativeOp expr:UnaryPrefix)*
  ///   ;
  Expression? parseMultiplicative(State<StringReader> state) {
    Expression? $0;
    // h:UnaryPrefix t:(op:MultiplicativeOp expr:UnaryPrefix)*
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
  String? parseMultiplicativeOp(State<StringReader> state) {
    String? $0;
    // v:('/' / '*' / '%' / '~/') Spaces
    final $1 = state.pos;
    String? $2;
    state.ok = false;
    final $5 = state.input;
    if (state.pos < $5.length) {
      final $3 = $5.readChar(state.pos);
      // ignore: unused_local_variable
      final $4 = $5.count;
      switch ($3) {
        case 47:
          state.ok = true;
          state.pos += $4;
          $2 = '/';
          break;
        case 42:
          state.ok = true;
          state.pos += $4;
          $2 = '*';
          break;
        case 37:
          state.ok = true;
          state.pos += $4;
          $2 = '%';
          break;
        case 126:
          state.ok = $5.matchChar(47, state.pos + $4);
          if (state.ok) {
            state.pos += $4 + $5.count;
            $2 = '~/';
          }
          break;
      }
    }
    if (!state.ok) {
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

  /// MapEntry<Symbol, Expression>
  /// NamedArgument =
  ///   i:IdentifierRaw Colon e:Expression
  ///   ;
  MapEntry<Symbol, Expression>? parseNamedArgument(State<StringReader> state) {
    MapEntry<Symbol, Expression>? $0;
    // i:IdentifierRaw Colon e:Expression
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
          MapEntry<Symbol, Expression>? $$;
          final i = $2!;
          final e = $3!;
          $$ = MapEntry(Symbol(i), e);
          $0 = $$;
        }
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Map<Symbol, Expression>
  /// NamedArguments =
  ///   v:@sepBy(NamedArgument, Comma)
  ///   ;
  Map<Symbol, Expression>? parseNamedArguments(State<StringReader> state) {
    Map<Symbol, Expression>? $0;
    // v:@sepBy(NamedArgument, Comma)
    List<MapEntry<Symbol, Expression>>? $2;
    MapEntry<Symbol, Expression>? $5;
    // NamedArgument
    // NamedArgument
    $5 = parseNamedArgument(state);
    if (!state.ok) {
      state.ok = true;
      $2 = const [];
    } else {
      final $4 = [$5!];
      while (true) {
        final $3 = state.pos;
        // Comma
        // Comma
        fastParseComma(state);
        if (!state.ok) {
          state.ok = true;
          $2 = $4;
          break;
        }
        // NamedArgument
        // NamedArgument
        $5 = parseNamedArgument(state);
        if (!state.ok) {
          state.pos = $3;
          break;
        }
        $4.add($5!);
      }
    }
    if (state.ok) {
      Map<Symbol, Expression>? $$;
      final v = $2!;
      $$ = v.isEmpty ? const {} : Map.fromEntries(v);
      $0 = $$;
    }
    return $0;
  }

  /// Expression
  /// Null =
  ///   'null' Spaces
  ///   ;
  Expression? parseNull(State<StringReader> state) {
    Expression? $0;
    // 'null' Spaces
    final $1 = state.pos;
    const $2 = 'null';
    matchLiteral(state, $2, const ErrorExpectedTags([$2]));
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
  ///   v:@errorHandler(NumberRaw)
  ///   ;
  Expression? parseNumber(State<StringReader> state) {
    Expression? $0;
    // v:@errorHandler(NumberRaw)
    final $2 = state.failPos;
    final $3 = state.errorCount;
    // NumberRaw
    // NumberRaw
    $0 = parseNumberRaw(state);
    if (!state.ok && state._canHandleError($2, $3)) {
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

  /// Expression
  /// NumberRaw =
  ///   v:$([-]? ([0] / [1-9] [0-9]*) ([.] Fraction)? ([eE] Exponent)?) Spaces
  ///   ;
  Expression? parseNumberRaw(State<StringReader> state) {
    Expression? $0;
    // v:$([-]? ([0] / [1-9] [0-9]*) ([.] Fraction)? ([eE] Exponent)?) Spaces
    final $1 = state.pos;
    String? $2;
    final $3 = state.pos;
    // [-]? ([0] / [1-9] [0-9]*) ([.] Fraction)? ([eE] Exponent)?
    final $4 = state.pos;
    matchChar(state, 45, const ErrorUnexpectedCharacter(45));
    state.ok = true;
    if (state.ok) {
      // [0]
      matchChar(state, 48, const ErrorUnexpectedCharacter(48));
      if (!state.ok) {
        // [1-9] [0-9]*
        final $5 = state.pos;
        state.ok = state.pos < state.input.length;
        if (state.ok) {
          final $6 = state.input.readChar(state.pos);
          state.ok = $6 >= 49 && $6 <= 57;
          if (state.ok) {
            state.pos += state.input.count;
          }
        }
        if (!state.ok) {
          state.fail(const ErrorUnexpectedCharacter());
        }
        if (state.ok) {
          while (state.pos < state.input.length) {
            final $7 = state.input.readChar(state.pos);
            state.ok = $7 >= 48 && $7 <= 57;
            if (!state.ok) {
              break;
            }
            state.pos += state.input.count;
          }
          state.fail(const ErrorUnexpectedCharacter());
          state.ok = true;
        }
        if (!state.ok) {
          state.pos = $5;
        }
      }
      if (state.ok) {
        // [.] Fraction
        final $9 = state.pos;
        matchChar(state, 46, const ErrorUnexpectedCharacter(46));
        if (state.ok) {
          // Fraction
          fastParseFraction(state);
        }
        if (!state.ok) {
          state.pos = $9;
        }
        state.ok = true;
        if (state.ok) {
          // [eE] Exponent
          final $10 = state.pos;
          state.ok = state.pos < state.input.length;
          if (state.ok) {
            final $11 = state.input.readChar(state.pos);
            state.ok = $11 == 69 || $11 == 101;
            if (state.ok) {
              state.pos += state.input.count;
            }
          }
          if (!state.ok) {
            state.fail(const ErrorUnexpectedCharacter());
          }
          if (state.ok) {
            // Exponent
            fastParseExponent(state);
          }
          if (!state.ok) {
            state.pos = $10;
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
      // Spaces
      fastParseSpaces(state);
      if (state.ok) {
        Expression? $$;
        final v = $2!;
        final n = num.parse(v);
        $$ = () => n;
        $0 = $$;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// OpenBracket =
  ///   v:'[' Spaces
  ///   ;
  String? parseOpenBracket(State<StringReader> state) {
    String? $0;
    // v:'[' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '[';
    $2 = matchLiteral1(state, 91, $3, const ErrorExpectedTags([$3]));
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
  String? parseOpenParenthesis(State<StringReader> state) {
    String? $0;
    // v:'(' Spaces
    final $1 = state.pos;
    String? $2;
    const $3 = '(';
    $2 = matchLiteral1(state, 40, $3, const ErrorExpectedTags([$3]));
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

  /// List<Expression>
  /// PositionalArguments =
  ///   @sepBy(Expression, Comma)
  ///   ;
  List<Expression>? parsePositionalArguments(State<StringReader> state) {
    List<Expression>? $0;
    // @sepBy(Expression, Comma)
    Expression? $4;
    // Expression
    // Expression
    $4 = parseExpression(state);
    if (!state.ok) {
      state.ok = true;
      $0 = const [];
    } else {
      final $3 = [$4!];
      while (true) {
        final $2 = state.pos;
        // Comma
        // Comma
        fastParseComma(state);
        if (!state.ok) {
          state.ok = true;
          $0 = $3;
          break;
        }
        // Expression
        // Expression
        $4 = parseExpression(state);
        if (!state.ok) {
          state.pos = $2;
          break;
        }
        $3.add($4!);
      }
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
  Expression? parsePrimary(State<StringReader> state) {
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
              final $1 = state.pos;
              // OpenParenthesis
              fastParseOpenParenthesis(state);
              if (state.ok) {
                Expression? $2;
                // Expression
                $2 = parseExpression(state);
                if (state.ok) {
                  // CloseParenthesis
                  fastParseCloseParenthesis(state);
                  if (state.ok) {
                    $0 = $2;
                  }
                }
              }
              if (!state.ok) {
                state.pos = $1;
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
  ///   h:BitwiseOr t:(op:RelationalOp expr:BitwiseOr)*
  ///   ;
  Expression? parseRelational(State<StringReader> state) {
    Expression? $0;
    // h:BitwiseOr t:(op:RelationalOp expr:BitwiseOr)*
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
  String? parseRelationalOp(State<StringReader> state) {
    String? $0;
    // v:('>=' / '>' / '<=' / '<') Spaces
    final $1 = state.pos;
    String? $2;
    state.ok = false;
    final $5 = state.input;
    if (state.pos < $5.length) {
      final $3 = $5.readChar(state.pos);
      // ignore: unused_local_variable
      final $4 = $5.count;
      switch ($3) {
        case 62:
          state.ok = $5.matchChar(61, state.pos + $4);
          if (state.ok) {
            state.pos += $4 + $5.count;
            $2 = '>=';
          } else {
            state.ok = true;
            state.pos += $4;
            $2 = '>';
          }
          break;
        case 60:
          state.ok = $5.matchChar(61, state.pos + $4);
          if (state.ok) {
            state.pos += $4 + $5.count;
            $2 = '<=';
          } else {
            state.ok = true;
            state.pos += $4;
            $2 = '<';
          }
          break;
      }
    }
    if (!state.ok) {
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
  ({String kind, dynamic arguments})? parseSelector(State<StringReader> state) {
    ({String kind, dynamic arguments})? $0;
    // kind:Dot arguments:IdentifierRaw
    final $7 = state.pos;
    String? $8;
    // Dot
    $8 = parseDot(state);
    if (state.ok) {
      String? $9;
      // IdentifierRaw
      $9 = parseIdentifierRaw(state);
      if (state.ok) {
        $0 = (kind: $8!, arguments: $9!);
      }
    }
    if (!state.ok) {
      state.pos = $7;
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
        final $1 = state.pos;
        String? $2;
        // OpenParenthesis
        $2 = parseOpenParenthesis(state);
        if (state.ok) {
          ({
            List<dynamic>? positionalArguments,
            Map<Symbol, dynamic>? namedArguments
          })? $3;
          // Arguments
          $3 = parseArguments(state);
          if (state.ok) {
            // CloseParenthesis
            fastParseCloseParenthesis(state);
            if (state.ok) {
              $0 = (kind: $2!, arguments: $3!);
            }
          }
        }
        if (!state.ok) {
          state.pos = $1;
        }
      }
    }
    return $0;
  }

  /// Expression
  /// Shift =
  ///   h:Additive t:(op:ShiftOp expr:Additive)*
  ///   ;
  Expression? parseShift(State<StringReader> state) {
    Expression? $0;
    // h:Additive t:(op:ShiftOp expr:Additive)*
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
  String? parseShiftOp(State<StringReader> state) {
    String? $0;
    // v:('<<' / '>>>' / '>>') Spaces
    final $1 = state.pos;
    String? $2;
    state.ok = false;
    final $5 = state.input;
    if (state.pos < $5.length) {
      final $3 = $5.readChar(state.pos);
      // ignore: unused_local_variable
      final $4 = $5.count;
      switch ($3) {
        case 60:
          state.ok = $5.matchChar(60, state.pos + $4);
          if (state.ok) {
            state.pos += $4 + $5.count;
            $2 = '<<';
          }
          break;
        case 62:
          const $7 = '>>>';
          state.ok = $5.startsWith($7, state.pos);
          if (state.ok) {
            state.pos += $5.count;
            $2 = $7;
          } else {
            state.ok = $5.matchChar(62, state.pos + $4);
            if (state.ok) {
              state.pos += $4 + $5.count;
              $2 = '>>';
            }
          }
          break;
      }
    }
    if (!state.ok) {
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
  Expression? parseStart(State<StringReader> state) {
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
  ///   v:StringRaw
  ///   ;
  Expression? parseString(State<StringReader> state) {
    Expression? $0;
    // v:StringRaw
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
  String? parseStringChars(State<StringReader> state) {
    String? $0;
    // $[ -!#-[\]-\u{10ffff}]+
    final $13 = state.pos;
    var $14 = false;
    while (true) {
      state.ok = state.pos < state.input.length;
      if (state.ok) {
        final $15 = state.input.readChar(state.pos);
        state.ok = $15 <= 91
            ? $15 >= 32 && $15 <= 33 || $15 >= 35
            : $15 >= 93 && $15 <= 1114111;
        if (state.ok) {
          state.pos += state.input.count;
        }
      }
      if (!state.ok) {
        state.fail(const ErrorUnexpectedCharacter());
      }
      if (!state.ok) {
        break;
      }
      $14 = true;
    }
    state.ok = $14;
    if (state.ok) {
      $0 = state.input.substring($13, state.pos);
    }
    if (!state.ok) {
      // '\\' v:(EscapeChar / EscapeHex)
      final $1 = state.pos;
      const $3 = '\\';
      matchLiteral1(state, 92, $3, const ErrorExpectedTags([$3]));
      if (state.ok) {
        String? $2;
        // EscapeChar
        // String @inline EscapeChar = c:["/bfnrt\\] ;
        // c:["/bfnrt\\]
        int? $10;
        state.ok = state.pos < state.input.length;
        if (state.ok) {
          final $11 = state.input.readChar(state.pos);
          state.ok = $11 == 98 ||
              ($11 < 98
                  ? $11 == 47 || $11 == 34 || $11 == 92
                  : $11 == 110 ||
                      ($11 < 110 ? $11 == 102 : $11 == 114 || $11 == 116));
          if (state.ok) {
            state.pos += state.input.count;
            $10 = $11;
          }
        }
        if (!state.ok) {
          state.fail(const ErrorUnexpectedCharacter());
        }
        if (state.ok) {
          String? $$;
          final c = $10!;
          $$ = _escape(c);
          $2 = $$;
        }
        if (!state.ok) {
          // EscapeHex
          // String @inline EscapeHex = 'u' v:HexNumber ;
          // 'u' v:HexNumber
          final $5 = state.pos;
          const $7 = 'u';
          matchLiteral1(state, 117, $7, const ErrorExpectedTags([$7]));
          if (state.ok) {
            int? $6;
            // HexNumber
            $6 = parseHexNumber(state);
            if (state.ok) {
              String? $$;
              final v = $6!;
              $$ = String.fromCharCode(v);
              $2 = $$;
            }
          }
          if (!state.ok) {
            state.pos = $5;
          }
        }
        if (state.ok) {
          $0 = $2;
        }
      }
      if (!state.ok) {
        state.pos = $1;
      }
    }
    return $0;
  }

  /// String
  /// StringRaw =
  ///   '"' v:StringChars* DoubleQuote
  ///   ;
  String? parseStringRaw(State<StringReader> state) {
    String? $0;
    // '"' v:StringChars* DoubleQuote
    final $1 = state.pos;
    const $3 = '"';
    matchLiteral1(state, 34, $3, const ErrorExpectedTags([$3]));
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
  ///   object:Primary selectors:Selector*
  ///   ;
  Expression? parseUnaryPostfix(State<StringReader> state) {
    Expression? $0;
    // object:Primary selectors:Selector*
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
  ///   op:UnaryPrefixOp? expr:UnaryPostfix
  ///   ;
  Expression? parseUnaryPrefix(State<StringReader> state) {
    Expression? $0;
    // op:UnaryPrefixOp? expr:UnaryPostfix
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
  String? parseUnaryPrefixOp(State<StringReader> state) {
    String? $0;
    // v:('-' / '!' / '~') Spaces
    final $1 = state.pos;
    String? $2;
    state.ok = false;
    final $5 = state.input;
    if (state.pos < $5.length) {
      final $3 = $5.readChar(state.pos);
      // ignore: unused_local_variable
      final $4 = $5.count;
      switch ($3) {
        case 45:
          state.ok = true;
          state.pos += $4;
          $2 = '-';
          break;
        case 33:
          state.ok = true;
          state.pos += $4;
          $2 = '!';
          break;
        case 126:
          state.ok = true;
          state.pos += $4;
          $2 = '~';
          break;
      }
    }
    if (!state.ok) {
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
  int? matchChar(State<StringReader> state, int char, ParseError error) {
    final input = state.input;
    state.ok = input.matchChar(char, state.pos);
    if (state.ok) {
      state.pos += input.count;
      return char;
    } else {
      state.fail(error);
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String? matchLiteral(
      State<StringReader> state, String string, ParseError error) {
    final input = state.input;
    state.ok = input.startsWith(string, state.pos);
    if (state.ok) {
      state.pos += input.count;
      return string;
    } else {
      state.fail(error);
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String? matchLiteral1(
      State<StringReader> state, int char, String string, ParseError error) {
    final input = state.input;
    state.ok = state.pos < input.length && input.readChar(state.pos) == char;
    if (state.ok) {
      state.pos += input.count;
      state.ok = true;
      return string;
    }
    state.fail(error);
    return null;
  }
}

void fastParseString(
  void Function(State<StringReader> state) fastParse,
  String source, {
  String Function(StringReader input, int offset, List<ErrorMessage> errors)?
      errorMessage,
}) {
  final input = StringReader(source);
  final result = tryFastParse(
    fastParse,
    input,
    errorMessage: errorMessage,
  );

  if (result.ok) {
    return;
  }

  errorMessage ??= errorMessage;
  final message = result.errorMessage;
  throw FormatException(message);
}

O parseInput<I, O>(
  O? Function(State<I> state) parse,
  I input, {
  String Function(I input, int offset, List<ErrorMessage> errors)? errorMessage,
}) {
  final result = tryParse(
    parse,
    input,
    errorMessage: errorMessage,
  );

  return result.getResult();
}

O parseString<O>(
  O? Function(State<StringReader> state) parse,
  String source, {
  String Function(StringReader input, int offset, List<ErrorMessage> errors)?
      errorMessage,
}) {
  final input = StringReader(source);
  final result = tryParse(
    parse,
    input,
    errorMessage: errorMessage,
  );

  return result.getResult();
}

ParseResult<I, void> tryFastParse<I>(
  void Function(State<I> state) fastParse,
  I input, {
  String Function(I input, int offset, List<ErrorMessage> errors)? errorMessage,
}) {
  final result = _parse<I, void>(
    fastParse,
    input,
    errorMessage: errorMessage,
  );
  return result;
}

ParseResult<I, O> tryParse<I, O>(
  O? Function(State<I> state) parse,
  I input, {
  String Function(I input, int offset, List<ErrorMessage> errors)? errorMessage,
}) {
  final result = _parse<I, O>(
    parse,
    input,
    errorMessage: errorMessage,
  );
  return result;
}

ParseResult<I, O> _createParseResult<I, O>(
  State<I> state,
  O? result, {
  String Function(I input, int offset, List<ErrorMessage> errors)? errorMessage,
}) {
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
  if (errorMessage != null) {
    message = errorMessage(input, offset, normalized);
  } else if (input is StringReader) {
    if (input.hasSource) {
      message = _errorMessage(input.source, offset, normalized);
    } else {
      message = _errorMessageWithoutSource(input, offset, normalized);
    }
  } else if (input is String) {
    message = _errorMessage(input, offset, normalized);
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

String _errorMessage(String source, int offset, List<ErrorMessage> errors) {
  final sb = StringBuffer();
  final errorInfoList = errors
      .map((e) => (length: e.length, message: e.toString()))
      .toSet()
      .toList();
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
    sb.writeln('line $row, column $column: $message');
    sb.writeln(text);
    sb.write(' ' * leftLen + '^' * indicatorLen);
  }

  return sb.toString();
}

String _errorMessageWithoutSource(
    StringReader input, int offset, List<ErrorMessage> errors) {
  final sb = StringBuffer();
  final errorInfoList = errors
      .map((e) => (length: e.length, message: e.toString()))
      .toSet()
      .toList();
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
    final inputLen = input.length;
    final lineLimit = min(80, inputLen);
    final start2 = start;
    final end2 = min(start2 + lineLimit, end);
    final errorLen = end2 - start;
    final indicatorLen = max(1, errorLen);
    var text = input.substring(start, lineLimit);
    text = text.replaceAll('\n', ' ');
    text = text.replaceAll('\r', ' ');
    text = text.replaceAll('\t', ' ');
    sb.writeln('offset $offset: $message');
    sb.writeln(text);
    sb.write('^' * indicatorLen);
  }

  return sb.toString();
}

List<ParseError> _normalize<I>(I input, int offset, List<ParseError> errors) {
  final result = errors.toList();
  if (input case final StringReader input) {
    if (offset >= input.length) {
      result.add(const ErrorUnexpectedEndOfInput());
      result.removeWhere((e) => e is ErrorUnexpectedCharacter);
    }
  } else if (input case final ChunkedData<StringReader> input) {
    if (input.isClosed && offset == input.start + input.data.length) {
      result.add(const ErrorUnexpectedEndOfInput());
      result.removeWhere((e) => e is ErrorUnexpectedCharacter);
    }
  }

  final foundTags =
      result.whereType<ErrorExpectedTag>().map((e) => e.tag).toList();
  if (foundTags.isNotEmpty) {
    result.removeWhere((e) => e is ErrorExpectedTag);
    result.add(ErrorExpectedTags(foundTags));
  }

  final expectedTags = result.whereType<ErrorExpectedTags>().toList();
  if (expectedTags.isNotEmpty) {
    result.removeWhere((e) => e is ErrorExpectedTags);
    final tags = <String>{};
    for (final error in expectedTags) {
      tags.addAll(error.tags);
    }

    final tagList = tags.toList();
    tagList.sort();
    final error = ErrorExpectedTags(tagList);
    result.add(error);
  }

  return result;
}

ParseResult<I, O> _parse<I, O>(
  O? Function(State<I> input) parse,
  I input, {
  String Function(I input, int offset, List<ErrorMessage> errors)? errorMessage,
}) {
  final state = State(input);
  final result = parse(state);
  return _createParseResult<I, O>(
    state,
    result,
    errorMessage: errorMessage,
  );
}

abstract interface class ByteReader {
  int get length;

  int readByte(int offset);
}

abstract class ChunkedData<T> implements Sink<T> {
  void Function()? handler;

  bool _isClosed = false;

  int buffering = 0;

  T data;

  int end = 0;

  bool sleep = false;

  int start = 0;

  final T _empty;

  ChunkedData(T empty)
      : data = empty,
        _empty = empty;

  bool get isClosed => _isClosed;

  @override
  void add(T data) {
    if (_isClosed) {
      throw StateError('Chunked data sink already closed');
    }

    if (buffering != 0) {
      this.data = join(this.data, data);
    } else {
      start = end;
      this.data = data;
    }

    end = start + getLength(this.data);
    sleep = false;
    while (!sleep) {
      final h = handler;
      handler = null;
      if (h == null) {
        break;
      }

      h();
    }

    if (buffering == 0) {
      //
    }
  }

  @override
  void close() {
    if (_isClosed) {
      return;
    }

    _isClosed = true;
    sleep = false;
    while (!sleep) {
      final h = handler;
      handler = null;
      if (h == null) {
        break;
      }

      h();
    }

    if (buffering != 0) {
      throw StateError('On closing, an incomplete buffering was detected');
    }

    final length = getLength(data);
    if (length != 0) {
      data = _empty;
    }
  }

  int getLength(T data);

  T join(T data1, T data2);
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

class ErrorExpectedEndOfInput extends ParseError {
  static const message = 'Expected an end of input';

  const ErrorExpectedEndOfInput();

  @override
  ErrorMessage getErrorMessage(Object? input, offset) {
    return const ErrorMessage(0, ErrorExpectedEndOfInput.message);
  }
}

class ErrorExpectedIntegerValue extends ParseError {
  static const message = 'Expected an integer value {0}';

  final int size;

  final int value;

  const ErrorExpectedIntegerValue(this.size, this.value);

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    var argument = value.toRadixString(16);
    if (const [8, 16, 24, 32, 40, 48, 56, 64].contains(size)) {
      argument = argument.padLeft(size >> 2, '0');
    }

    argument = '0x$argument';
    if (value >= 0 && value <= 0x10ffff) {
      argument = '$argument (${ParseError.escape(value)})';
    }

    return ErrorMessage(0, ErrorExpectedIntegerValue.message, [argument]);
  }
}

class ErrorExpectedTag extends ParseError {
  static const message = 'Expected: {0}';

  final String tag;

  const ErrorExpectedTag(this.tag);

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    return const ErrorMessage(0, ErrorExpectedTag.message);
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
    if (input is StringReader && input.hasSource) {
      if (offset case final int offset) {
        if (offset < input.length) {
          char = input.readChar(offset);
        } else {
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
    return const ErrorMessage(0, ErrorUnexpectedEndOfInput.message);
  }
}

class ErrorUnexpectedInput extends ParseError {
  static const message = 'Unexpected input';

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
    if (input case final StringReader input) {
      if (input.hasSource) {
        final source = input.source;
        if (pos >= source.length) {
          return '$pos:';
        }
        var length = source.length - pos;
        length = length > 40 ? 40 : length;
        final string = source.substring(pos, pos + length);
        return '$pos:$string';
      }
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

abstract interface class StringReader {
  factory StringReader(String source) {
    return _StringReader(source);
  }

  int get count;

  bool get hasSource;

  int get length;

  String get source;

  int indexOf(String string, int start);

  bool matchChar(int char, int offset);

  int readChar(int offset);

  bool startsWith(String string, [int index = 0]);

  String substring(int start, [int? end]);
}

class StringReaderChunkedData extends ChunkedData<StringReader> {
  StringReaderChunkedData() : super(StringReader(''));

  @override
  int getLength(StringReader data) => data.length;

  @override
  StringReader join(StringReader data1, StringReader data2) => data1.length != 0
      ? StringReader('${data1.source}${data2.source}')
      : data2;
}

class _StringReader implements StringReader {
  @override
  final bool hasSource = true;

  @override
  final int length;

  @override
  int count = 0;

  @override
  final String source;

  _StringReader(this.source) : length = source.length;

  @override
  int indexOf(String string, int start) {
    return source.indexOf(string, start);
  }

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool matchChar(int char, int offset) {
    if (offset < length) {
      final c = source.runeAt(offset);
      count = char > 0xffff ? 2 : 1;
      if (c == char) {
        return true;
      }
    }

    return false;
  }

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int readChar(int offset) {
    final result = source.runeAt(offset);
    count = result > 0xffff ? 2 : 1;
    return result;
  }

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool startsWith(String string, [int index = 0]) {
    if (source.startsWith(string, index)) {
      count = string.length;
      return true;
    }

    return false;
  }

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String substring(int start, [int? end]) {
    final result = source.substring(start, end);
    count = result.length;
    return result;
  }

  @override
  String toString() {
    return source;
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
