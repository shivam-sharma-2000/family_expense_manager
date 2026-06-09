import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  final email = "test@example.com";
  final emailHash = md5.convert(utf8.encode(email.trim().toLowerCase())).toString();
  print('https://www.gravatar.com/avatar/$emailHash?d=mp');
}
