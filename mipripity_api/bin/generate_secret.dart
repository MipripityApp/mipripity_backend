import 'dart:math';
import 'dart:convert';

void main() {
  final random = Random.secure();
  final values = List<int>.generate(32, (i) => random.nextInt(256));
  final secret = base64Url.encode(values);
  print('Generated JWT Secret: $secret');
}