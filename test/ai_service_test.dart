import 'package:flutter_test/flutter_test.dart';
import 'package:farmtok/services/ai_service.dart';

void main() {
  group('AIService', () {
    test('getFarmingTip returns a valid tip', () async {
      final tip = await AIService.getFarmingTip();
      expect(tip, isNotEmpty);
      expect(tip, isA<String>());
    });
  });
}