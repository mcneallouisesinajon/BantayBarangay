import '../../../core/constants/keyword_tables.dart';
import 'incident_category.dart';
import 'incident_severity.dart';

class ClassificationResult {
  final IncidentSeverity severity;
  final String type;
  final List<String> tags;

  const ClassificationResult({
    required this.severity,
    required this.type,
    required this.tags,
  });
}

ClassificationResult classifyIncident({
  required String title,
  required String description,
  required IncidentCategory category,
}) {
  final raw = '${title.trim()} ${description.trim()}'.toLowerCase();
  final normalized = raw.replaceAll(RegExp(r"[^a-z0-9\s'-]"), ' ');
  final tokens = normalized.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).map(_stem).toList();
  final tokenSet = tokens.toSet();
  final joined = ' ${tokens.join(' ')} ';

  final rules = kCategoryTypes[category] ?? const [];
  TypeRule? best;
  int bestScore = 0;
  final matchedKeywords = <String>{};
  for (final rule in rules) {
    final hits = tokenSet.intersection(rule.keywords);
    if (hits.length > bestScore) {
      bestScore = hits.length;
      best = rule;
    }
  }
  if (best != null) {
    matchedKeywords.addAll(tokenSet.intersection(best.keywords));
  }

  IncidentSeverity severity = best?.baseSeverity ?? category.defaultSeverity;
  final escalations = tokenSet.intersection(kEscalationTokens);
  final deescalations = tokenSet.intersection(kDeescalationTokens);
  final escalatePhrases = kEscalationBigrams.where((p) => joined.contains(' $p ')).toSet();
  final deescalatePhrases = kDeescalationBigrams.where((p) => joined.contains(' $p ')).toSet();

  if (escalations.isNotEmpty || escalatePhrases.isNotEmpty) {
    severity = severity.escalate();
  }
  if (deescalations.isNotEmpty || deescalatePhrases.isNotEmpty) {
    severity = severity.deescalate();
  }

  matchedKeywords.addAll(escalations);
  matchedKeywords.addAll(deescalations);
  matchedKeywords.addAll(escalatePhrases);
  matchedKeywords.addAll(deescalatePhrases);

  return ClassificationResult(
    severity: severity,
    type: best?.type ?? 'general',
    tags: matchedKeywords.toList()..sort(),
  );
}

String _stem(String word) {
  if (word.length > 3 && word.endsWith('s') && !word.endsWith('ss')) {
    return word.substring(0, word.length - 1);
  }
  return word;
}
