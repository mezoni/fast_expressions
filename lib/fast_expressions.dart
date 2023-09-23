import 'src/expression_parser.dart';

dynamic Function() parseExpression(
  String source, {
  Map<String, dynamic> context = const {},
  dynamic Function(Object? object, String member)? resolve,
}) {
  final parser = ExpressionParser(
    context: context,
    resolve: resolve,
  );
  final result = parseString(parser.parseStart, source);
  return result;
}
