import 'src/expression_converter.dart';

/// Parses the source code of the expression from [source] and returns a
/// function in which the parsed expression will be wrapped.
///
/// Parameters:
/// - [source] - source code of the expression
/// - [context] - used to specify the variables used and their values
/// - [resolve] - used to resolve instance member values (fields, methods) by
/// name
dynamic Function() parseExpression(
  String source, {
  Map<String, dynamic> context = const {},
  dynamic Function(Object? object, String member)? resolve,
}) {
  final parser = ExpressionParser(
    context: context,
    resolve: resolve,
  );
  final result = ExpressionConverter(parser: parser).convert(source);
  return result;
}
