


import 'dart:convert';

class AiPick {
  final String id;
  final String reason;
  const AiPick(this.id, this.reason);
}

/// Older "pick list" format. Kept so existing tests keep working.
List<AiPick> parseAiPicks(
  String? raw,
  Set<String> allowedIds, {
  int max = 5,
}) {
  if (raw == null || raw.trim().isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw.trim());
    final list = decoded is Map ? decoded['picks'] : decoded;
    if (list is! List) return const [];
    final seen = <String>{};
    final out = <AiPick>[];
    for (final item in list) {
      if (item is! Map) continue;
      final id = item['id'];
      final reason = item['reason'];
      if (id is! String || !allowedIds.contains(id) || !seen.add(id)) {
        continue;
      }
      out.add(AiPick(id, reason is String ? reason.trim() : ''));
      if (out.length >= max) break;
    }
    return out;
  } catch (_) {
    return const [];
  }
}

/// One dish scored by the model. [fit] is 0 (no fit) to 3 (excellent fit).
class AiRating {
  final String id;
  final int fit;
  final String reason;
  const AiRating(this.id, this.fit, this.reason);
}

/// Parses {"ratings":[{"id":"...","fit":0-3,"reason":"..."}]}.
/// Never trusts the model: unknown ids, duplicates, non-numeric scores and
/// bad shapes are dropped, and scores are clamped to 0..3.
List<AiRating> parseAiRatings(String? raw, Set<String> allowedIds) {
  if (raw == null || raw.trim().isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw.trim());
    final list = decoded is Map ? decoded['ratings'] : decoded;
    if (list is! List) return const [];
    final seen = <String>{};
    final out = <AiRating>[];
    for (final item in list) {
      if (item is! Map) continue;
      final id = item['id'];
      final fitRaw = item['fit'];
      final reason = item['reason'];
      if (id is! String || !allowedIds.contains(id) || !seen.add(id)) {
        continue;
      }
      if (fitRaw is! num) continue;
      final fit = fitRaw.round().clamp(0, 3).toInt();
      out.add(AiRating(id, fit, reason is String ? reason.trim() : ''));
    }
    return out;
  } catch (_) {
    return const [];
  }
}