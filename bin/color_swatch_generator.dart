import 'package:color_swatch_generator/color_swatch.dart';

/// Must run with a list of name:hexColor
/// 
/// Name cannot be empty
/// Name can only have alphanumeric and underscores
/// HexColors can only have hexadecimal digits and 6 characters

void main(List<String> params) async {
  await generateFile(generateSwatchScript(params));
}