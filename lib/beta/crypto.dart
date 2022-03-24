import 'package:crypto/crypto.dart';
import 'dart:convert';

class Crypto {

  Crypto();

  String generateHash(String input)  {
    Hash hasher = sha256;
    var data = Utf8Encoder().convert(input);
    var response = hasher.convert(data);
    return response.toString();
  }

}