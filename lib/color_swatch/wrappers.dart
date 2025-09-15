import 'dart:math' as math;

class Color {
  final int value;
  
  const Color(this.value);
  
  const Color.fromARGB(int a, int r, int g, int b)
      : value = ((a & 0xff) << 24) | ((r & 0xff) << 16) | ((g & 0xff) << 8) | ((b & 0xff) << 0);
  
  int get alpha => (0xff000000 & value) >> 24;
  int get red => (0x00ff0000 & value) >> 16;
  int get green => (0x0000ff00 & value) >> 8;
  int get blue => (0x000000ff & value) >> 0;
}

class HSL {
  final double h, s, l;
  
  HSL(this.h, this.s, this.l);
  
  static HSL fromColor(Color color) {
    final r = (color.red / 255.0);
    final g = (color.green / 255.0);
    final b = (color.blue / 255.0);
    
    final max = [r, g, b].reduce(math.max);
    final min = [r, g, b].reduce(math.min);
    final diff = max - min;
    
    final l = (max + min) / 2.0;
    
    if (diff == 0) {
      return HSL(0, 0, l);
    }
    
    final s = l > 0.5 ? diff / (2 - max - min) : diff / (max + min);
    
    double h;
    if (max == r) {
      h = ((g - b) / diff + (g < b ? 6 : 0)) / 6;
    } else if (max == g) {
      h = ((b - r) / diff + 2) / 6;
    } else {
      h = ((r - g) / diff + 4) / 6;
    }
    
    return HSL(h * 360, s, l);
  }
  
  HSL withLightness(double lightness) {
    return HSL(h, s, lightness);
  }
  
  Color toColor() {
    if (s == 0) {
      final gray = (l * 255).round().clamp(0, 255);
      return Color.fromARGB(255, gray, gray, gray);
    }
    
    final c = (1 - (2 * l - 1).abs()) * s;
    final x = c * (1 - ((h / 60) % 2 - 1).abs());
    final m = l - c / 2;
    
    double r = 0, g = 0, b = 0;
    
    if (h >= 0 && h < 60) {
      r = c; g = x; b = 0;
    } else if (h >= 60 && h < 120) {
      r = x; g = c; b = 0;
    } else if (h >= 120 && h < 180) {
      r = 0; g = c; b = x;
    } else if (h >= 180 && h < 240) {
      r = 0; g = x; b = c;
    } else if (h >= 240 && h < 300) {
      r = x; g = 0; b = c;
    } else if (h >= 300 && h < 360) {
      r = c; g = 0; b = x;
    }
    
    return Color.fromARGB(
      255,
      ((r + m) * 255).round().clamp(0, 255),
      ((g + m) * 255).round().clamp(0, 255),
      ((b + m) * 255).round().clamp(0, 255),
    );
  }
}

class MaterialColor {
  final int value;
  final Map<int, Color> swatch;
  
  const MaterialColor(this.value, this.swatch);
  
  Color get shade50 => swatch[50]!;
  Color get shade100 => swatch[100]!;
  Color get shade200 => swatch[200]!;
  Color get shade300 => swatch[300]!;
  Color get shade400 => swatch[400]!;
  Color get shade500 => swatch[500]!;
  Color get shade600 => swatch[600]!;
  Color get shade700 => swatch[700]!;
  Color get shade800 => swatch[800]!;
  Color get shade900 => swatch[900]!;
}

// Implementação simplificada do generateSwatch
MaterialColor generateSwatch(Color color) {
  final hsl = HSL.fromColor(color);
  return MaterialColor(color.value, {
    50: hsl.withLightness(0.95).toColor(),
    100: hsl.withLightness(0.9).toColor(),
    200: hsl.withLightness(0.8).toColor(),
    300: hsl.withLightness(0.7).toColor(),
    400: hsl.withLightness(0.6).toColor(),
    500: color,
    600: hsl.withLightness(0.4).toColor(),
    700: hsl.withLightness(0.3).toColor(),
    800: hsl.withLightness(0.2).toColor(),
    900: hsl.withLightness(0.1).toColor(),
  });
}