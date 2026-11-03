

import 'package:flutter_test/flutter_test.dart';
import 'package:ghar_ka_khana/services/khana_buddy_ai_parser.dart';

void main() {
  const allowed = {'a', 'b', 'c'};

  group('parseAiPicks', () {
    test('keeps valid ids in order', () {
      final r = parseAiPicks(
        '{"picks":[{"id":"b","reason":"Fits"},{"id":"a","reason":"Also"}]}',
        allowed,
      );
      expect(r.map((e) => e.id), ['b', 'a']);
      expect(r.first.reason, 'Fits');
    });

    test('drops invented ids and duplicates', () {
      final r = parseAiPicks(
        '{"picks":[{"id":"zzz","reason":"x"},{"id":"a","reason":"y"},'
        '{"id":"a","reason":"z"}]}',
        allowed,
      );
      expect(r.map((e) => e.id), ['a']);
    });

    test('bad or empty input returns empty list', () {
      expect(parseAiPicks(null, allowed), isEmpty);
      expect(parseAiPicks('not json', allowed), isEmpty);
      expect(parseAiPicks('{"picks":"oops"}', allowed), isEmpty);
    });
  });

  group('parseAiRatings', () {
    test('parses valid ratings', () {
      final r = parseAiRatings(
        '{"ratings":[{"id":"a","fit":3,"reason":"Great"},'
        '{"id":"b","fit":0,"reason":"No"}]}',
        allowed,
      );
      expect(r.length, 2);
      expect(r.first.id, 'a');
      expect(r.first.fit, 3);
      expect(r.first.reason, 'Great');
    });

    test('drops invented ids and duplicates', () {
      final r = parseAiRatings(
        '{"ratings":[{"id":"zzz","fit":3},{"id":"a","fit":2},'
        '{"id":"a","fit":3}]}',
        allowed,
      );
      expect(r.length, 1);
      expect(r.first.fit, 2);
    });

    test('clamps scores to 0..3', () {
      final r = parseAiRatings(
        '{"ratings":[{"id":"a","fit":9},{"id":"b","fit":-4}]}',
        allowed,
      );
      expect(r.firstWhere((e) => e.id == 'a').fit, 3);
      expect(r.firstWhere((e) => e.id == 'b').fit, 0);
    });

    test('skips entries with a missing or non-numeric fit', () {
      final r = parseAiRatings(
        '{"ratings":[{"id":"a"},{"id":"b","fit":"high"},{"id":"c","fit":2}]}',
        allowed,
      );
      expect(r.map((e) => e.id), ['c']);
    });

    test('bad or empty input returns empty list', () {
      expect(parseAiRatings(null, allowed), isEmpty);
      expect(parseAiRatings('', allowed), isEmpty);
      expect(parseAiRatings('not json', allowed), isEmpty);
      expect(parseAiRatings('{"ratings":"oops"}', allowed), isEmpty);
    });
  });
}