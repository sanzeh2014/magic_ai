import 'package:flutter_test/flutter_test.dart';

int increment(int x) => x + 1;

void main() {
  test('increment adds one to the input', () {
    expect(increment(1), 2);
    expect(increment(-1), 0);
  });
}
