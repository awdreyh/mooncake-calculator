import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cake_app2/ui/utils/helper.dart';

void main() {
  group('Helper.ratioToString', () {
    test('converts 0.4 to 4:6', () {
      expect(Helper.ratioToString(0.4), '4:6');
    });

    test('clamps values to a valid ratio range', () {
      expect(Helper.ratioToString(1.2), '10:0');
      expect(Helper.ratioToString(-0.1), '0:10');
    });
  });

  group('Helper.stringToRatio', () {
    test('parses 4:6 back to 0.4', () {
      expect(Helper.stringToRatio('4:6'), 0.4);
    });

    test('handles invalid values safely', () {
      expect(Helper.stringToRatio('invalid'), 0.0);
      expect(Helper.stringToRatio(''), 0.0);
    });
  });
}
