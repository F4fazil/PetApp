import 'dart:convert';
import 'package:flutter/services.dart';

import 'Animal.dart';

Future<List<Animal>> loadAnimals(String fileName) async {
  final String jsonString = await rootBundle.loadString('assets/data/$fileName');
  final List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((item) => Animal.fromJson(item)).toList();
}
