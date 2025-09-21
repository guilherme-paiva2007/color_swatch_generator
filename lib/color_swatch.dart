import 'dart:math';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'color_swatch/wrappers.dart';
export 'color_swatch/wrappers.dart';

const _stringModel = """import 'package:flutter/material.dart' show Color, MaterialColor;

abstract final class AppColors {
  \$0
}""";

const _colorModel = """static const \$n = MaterialColor(\$0, {
    50: Color(\$50),
    100: Color(\$100),
    200: Color(\$200),
    300: Color(\$300),
    400: Color(\$400),
    500: Color(\$500),
    600: Color(\$600),
    700: Color(\$700),
    800: Color(\$800),
    900: Color(\$900),
  });""";

final RegExp _nameRegExp = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$');
final RegExp _colorRegExp = RegExp(r'^[0-9a-fA-F]{6}$');

/// Implementação melhorada usando o algoritmo do color_palette_plus
MaterialColor generateSwatch(Color color) {
  return ColorPalette.generateSwatch(color);
}

String generateSwatchScript(List<String> colorsKeys) {
  final Iterable<MapEntry<String, MaterialColor>> colors = colorsKeys.map((k) {
    final split = k.split(":");

    if (split.length != 2) {
      throw ArgumentError("Color must be in the format 'name:hexValue'");
    }

    final name = split[0];
    final hex = split[1];

    if (name.isEmpty) throw ArgumentError("Color name cannot be empty");
    if (!_nameRegExp.hasMatch(name)) throw ArgumentError("Invalid color name: $name");
    if (!_colorRegExp.hasMatch(hex)) throw ArgumentError("Invalid hex color value: $hex");

    return MapEntry(name, generateSwatch(Color(int.parse("FF$hex", radix: 16))));
  });
  
  final List<String> colorStrings = [
    for (var MapEntry(key: name, value: color) in colors)
      _colorModel
      .replaceFirst("\$n", name)
      .replaceFirst("\$0", "0x${color.baseColor.value.toRadixString(16).toUpperCase()}")
        .replaceFirst("\$50", "0x${color.shade50.value.toRadixString(16).toUpperCase()}")
        .replaceFirst("\$100", "0x${color.shade100.value.toRadixString(16).toUpperCase()}")
        .replaceFirst("\$200", "0x${color.shade200.value.toRadixString(16).toUpperCase()}")
        .replaceFirst("\$300", "0x${color.shade300.value.toRadixString(16).toUpperCase()}")
        .replaceFirst("\$400", "0x${color.shade400.value.toRadixString(16).toUpperCase()}")
        .replaceFirst("\$500", "0x${color.shade500.value.toRadixString(16).toUpperCase()}")
        .replaceFirst("\$600", "0x${color.shade600.value.toRadixString(16).toUpperCase()}")
        .replaceFirst("\$700", "0x${color.shade700.value.toRadixString(16).toUpperCase()}")
        .replaceFirst("\$800", "0x${color.shade800.value.toRadixString(16).toUpperCase()}")
        .replaceFirst("\$900", "0x${color.shade900.value.toRadixString(16).toUpperCase()}"),
  ];

  return _stringModel.replaceFirst("\$0", colorStrings.join("\n\n  "));
}

Future<void> generateFile(String content, { String? fileName }) async {
  final Random random = Random.secure();
  const intRange = 16 << 4 << 4 << 4 << 4;

  String fSourceName = fileName ?? "color_swatch";
  String fname = "$fSourceName.dart";

  final dir = Directory(path.current);
  File file = File(path.join(dir.path, fname));

  while (await file.exists()) {
    print("file ${file.path} already exists");
    fname = "${fSourceName}_${random.nextInt(intRange).toRadixString(16)}.dart";
    file = File(path.join(dir.path, fname));
  }

  await file.create();

  final io = file.openWrite(mode: FileMode.write);

  io.write(content);
}