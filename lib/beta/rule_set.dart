import 'package:serializable_data/serializable_data.dart';

class RuleSet extends PersistableDataObject {
  static const String objectType = 'RuleSet';

  static const String ruleSetNameLabel = 'ruleSetName';
  static const String rulesLabel = 'rules';

  RuleSet({Map<String, dynamic>? data}) : super(objectType, data: data);

  List<Rule> get rules => get(rulesLabel) ?? <Rule>[];
}

class Rule extends DataObject {
  static const String equals = '=';
  static const String notEquals = '!=';

  static const String greaterThan = '>';
  static const String lessThan = '<';
  static const String greaterThanOrEquals = '>=';
  static const String lessThanOrEquals = '<=';
  static const String isContainedIn = 'in';

  static const String firstLabel = 'first';
  static const String secondLabel = 'second';
  static const String comparatorLabel = 'comparator';

  Rule({String? first, String? second, String? comparator, String? name}) : super(<String, dynamic>{});

  String get first => get(firstLabel);
  String get second => get(firstLabel);
  String get comparator => get(firstLabel);
}

bool evaluateRule(RuleSet ruleSet, Evaluator evaluator) {
  bool response = true;

  var rules = ruleSet.rules;

  for (var rule in rules) {
    var first = evaluator.get(rule.first);
    var second = evaluator.get(rule.second);
    var result = checkResult(first, rule.comparator, second);
    if (!result) {
      return false;
    }
  }

  return response;
}

bool checkResult(dynamic first, String comparator, dynamic second) {
  var response = true;

  switch (comparator) {
    case Rule.equals:
      return first == second;

    case Rule.notEquals:
      return first != second;

    case Rule.greaterThan:
      var numFirst = num.parse(first);
      var numSecond = num.parse(second);
      return numFirst > numSecond;

    case Rule.greaterThanOrEquals:
      var numFirst = num.parse(first);
      var numSecond = num.parse(second);
      return numFirst >= numSecond;

    case Rule.lessThan:
      var numFirst = num.parse(first);
      var numSecond = num.parse(second);
      return numFirst < numSecond;

    case Rule.lessThanOrEquals:
      var numFirst = num.parse(first);
      var numSecond = num.parse(second);
      return numFirst <= numSecond;

    case Rule.isContainedIn:
      var list = second.spit(',');
      return list.contains(first);

    default:
      throw DataObjectException('Cannot determine result : $first, $comparator, $second');
  }
}

class Evaluator {
  PathFollower pathFollower;

  Map<String, Function> functions = <String, Function>{};

  Map<String, dynamic> cache = <String, dynamic>{};

  Evaluator(this.pathFollower);

  dynamic get(dynamic item) {
    if (item is! String) {
      return item;
    }

    if (cache.containsKey(item)) {
      return cache[item];
    }

    if (item.contains(',')) {
      var response = pathFollower.get(item);
      cache[item] = response;
      return response;
    }

    if (functions.containsKey(item)) {
      var response = functions[item]!();
      cache[item] = response;
      return response;
    }

    throw RuleException('Cannot evaluate $item');
  }
}

abstract class PathFollower {
  dynamic get(String path);
}

class RuleException implements Exception {
  final String _message;

  RuleException(this._message);
}