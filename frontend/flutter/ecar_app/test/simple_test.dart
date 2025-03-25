import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Simple boolean test', () {
    // A very simple test that should always pass
    expect(true, isTrue);
    expect(false, isFalse);
  });
  
  test('Simple arithmetic test', () {
    // A very simple arithmetic test
    expect(2 + 2, equals(4));
    expect(5 - 3, equals(2));
    expect(4 * 3, equals(12));
  });
} 