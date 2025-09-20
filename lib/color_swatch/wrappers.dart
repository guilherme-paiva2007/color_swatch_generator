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
  
  /// Gets the alpha value as a double between 0.0 and 1.0
  double get a => alpha / 255.0;
  
  /// Gets the red value as a double between 0.0 and 1.0
  double get r => red / 255.0;
  
  /// Gets the green value as a double between 0.0 and 1.0
  double get g => green / 255.0;
  
  /// Gets the blue value as a double between 0.0 and 1.0
  double get b => blue / 255.0;
  
  /// Computes the luminance of this color using the relative luminance formula
  /// Used for determining contrast ratios and text color selection
  double computeLuminance() {
    // Convert to linear RGB
    double toLinear(double component) {
      if (component <= 0.03928) {
        return component / 12.92;
      }
      return math.pow((component + 0.055) / 1.055, 2.4).toDouble();
    }
    
    final linearR = toLinear(r);
    final linearG = toLinear(g);
    final linearB = toLinear(b);
    
    // Calculate relative luminance
    return 0.2126 * linearR + 0.7152 * linearG + 0.0722 * linearB;
  }
}

/// HSL (Hue, Saturation, Lightness) color representation
/// Based on the color_palette_plus implementation for accurate color transformations
class HSL {
  final double h, s, l;
  
  HSL(this.h, this.s, this.l);
  
  /// Creates an HSL color with alpha channel
  HSL.fromAHSL(double a, double h, double s, double l) : h = h, s = s, l = l;
  
  /// Converts a Color to HSL color space
  /// Algorithm based on color_palette_plus for consistency
  static HSL fromColor(Color color) {
    final r = color.r;
    final g = color.g;
    final b = color.b;
    
    final max = math.max(r, math.max(g, b));
    final min = math.min(r, math.min(g, b));
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
  
  /// Creates a new HSL color with modified lightness
  HSL withLightness(double lightness) {
    return HSL(h, s, lightness.clamp(0.0, 1.0));
  }
  
  /// Creates a new HSL color with modified saturation
  HSL withSaturation(double saturation) {
    return HSL(h, saturation.clamp(0.0, 1.0), l);
  }
  
  /// Creates a new HSL color with modified hue
  HSL withHue(double hue) {
    return HSL(hue % 360, s, l);
  }
  
  /// Converts HSL back to RGB Color
  /// Algorithm matches color_palette_plus for consistency
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

/// Material Color swatch that contains different shades of a color
/// Replicates Flutter's MaterialColor but implemented in pure Dart
class MaterialColor {
  final int value;
  final Map<int, Color> swatch;
  
  const MaterialColor(this.value, this.swatch);
  
  /// Returns the original base color (preserved regardless of tone 500 adjustments)
  Color get baseColor => Color(value);
  
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
  
  /// Gets a shade by index, null if not found
  Color? operator [](int shade) => swatch[shade];
}

/// A utility class for generating color palettes and managing color transformations
/// Based on the color_palette_plus implementation
class ColorPalette {
  /// Valid shade indices for Material Design colors
  static const _validShadeIndices = {50, 100, 200, 300, 400, 500, 600, 700, 800, 900};
  
  /// Creates a MaterialColor swatch from a base color
  /// The algorithm uses Material 3 KeyColor for proper tone mapping
  /// The baseColor is preserved as the primary color value
  static MaterialColor generateSwatch(Color baseColor) {
    const white = Color(0xFFFFFFFF);
    final hslBase = HSL.fromColor(baseColor);

    // Generate dark base using HSL lightness adjustments (matches color_palette_plus)
    final darkBase = HSL.fromAHSL(
      baseColor.a,
      hslBase.h,
      hslBase.s,
      (hslBase.l * 0.6).clamp(0.0, 1.0), // Reduce lightness by 40%
    ).toColor();

    // Preserva a cor original como baseColor, independente do ajuste do tom 500
    final colorValue = (((baseColor.a * 255).round() & 0xff) << 24) | 
                      (((baseColor.r * 255).round() & 0xff) << 16) | 
                      (((baseColor.g * 255).round() & 0xff) << 8) | 
                      ((baseColor.b * 255).round() & 0xff);

    return MaterialColor(
      colorValue,
      _generateShadeMap(baseColor, white, darkBase),
    );
  }
  
  /// Generates a specific shade from a base color
  static Color getShade(Color baseColor, int shadeIndex) {
    if (!_validShadeIndices.contains(shadeIndex)) {
      throw ArgumentError('Invalid shade index. Must be one of: $_validShadeIndices');
    }
    return generateSwatch(baseColor)[shadeIndex]!;
  }
  
  /// Generates all shades for a given color
  static Map<int, Color> getAllShades(Color baseColor) {
    final MaterialColor swatch = generateSwatch(baseColor);
    return Map.unmodifiable({
      50: swatch[50]!,
      100: swatch[100]!,
      200: swatch[200]!,
      300: swatch[300]!,
      400: swatch[400]!,
      500: swatch[500]!,
      600: swatch[600]!,
      700: swatch[700]!,
      800: swatch[800]!,
      900: swatch[900]!,
    });
  }
  
  /// Generates a map of color shades using Material 3 KeyColor algorithm for proper tone mapping
  static Map<int, Color> _generateShadeMap(Color baseColor, Color lightBase, Color darkBase) {
    final hslBase = HSL.fromColor(baseColor);
    
    // Aplica valores fixos do Material 3 para garantir progressão correta
    final fixedLightnesses = {
      50: 0.95,   // Mais claro
      100: 0.88,
      200: 0.80,
      300: 0.70,
      400: 0.60,
      500: _findOptimalTone500(hslBase), // Tom calculado para o centro
      600: 0.40,
      700: 0.30,
      800: 0.20,
      900: 0.12,  // Mais escuro
    };
    
    return fixedLightnesses.map(
      (tone, lightness) => MapEntry(tone, _adjustLightness(hslBase, lightness))
    );
  }
  
  /// Encontra o tom 500 ideal baseado no Material 3 KeyColor algorithm
  /// Garante que o tom 500 esteja na faixa correta para manter a progressão
  static double _findOptimalTone500(HSL hsl) {
    final lightness = hsl.l;
    
    // Para cores extremamente claras (> 85%), força para um tom significativamente mais escuro
    if (lightness > 0.85) {
      return 0.45; // Tom fixo para manter progressão
    }
    
    // Para cores extremamente escuras (< 15%), força para um tom significativamente mais claro
    if (lightness < 0.15) {
      return 0.55; // Tom fixo para manter progressão
    }
    
    // Para cores muito claras (70-85%), ajusta para baixo
    if (lightness > 0.70) {
      return 0.50; // Tom padrão
    }
    
    // Para cores muito escuras (15-30%), ajusta para cima
    if (lightness < 0.30) {
      return 0.50; // Tom padrão  
    }
    
    // Para cores na faixa intermediária (30-70%), usa valor próximo ao original
    // mas força para a faixa de tom 500 (40-60%) para garantir progressão
    return lightness.clamp(0.40, 0.59); // 0.59 para ficar abaixo de 60%
  }

  /// Adjusts the lightness of an HSL color while maintaining hue and saturation
  /// Exactly matches the color_palette_plus implementation
  static Color _adjustLightness(HSL hslColor, double lightness) {
    return hslColor.withLightness(lightness.clamp(0.0, 1.0)).toColor();
  }
}

/// A class that provides methods for generating different types of color harmonies
/// Exactly replicates the ColorPalettes class from color_palette_plus
class ColorPalettes {
  /// Creates a monochromatic palette from a base color
  /// Generates colors with the same hue but different lightness values
  static List<Color> monochromatic(Color baseColor, {int steps = 5}) {
    if (steps < 2) {
      throw ArgumentError('Steps must be at least 2');
    }

    final hslColor = HSL.fromColor(baseColor);
    return List.generate(steps, (index) {
      final t = index / (steps - 1);
      // Perceptual lightness curve (quadratic ease-in) - matches color_palette_plus
      final lightness = 0.15 + 0.7 * t * t;
      return HSL.fromAHSL(
        baseColor.a,
        hslColor.h,
        hslColor.s,
        lightness.clamp(0.0, 1.0),
      ).toColor();
    });
  }

  /// Creates an analogous color palette from a base color
  /// Generates colors adjacent on the color wheel
  static List<Color> analogous(
    Color baseColor, {
    int steps = 3,
    double angle = 30,
  }) {
    if (steps < 1) {
      throw ArgumentError('Steps must be at least 1');
    }

    final hslColor = HSL.fromColor(baseColor);
    return List.generate(steps, (index) {
      final hueOffset = (index - (steps - 1) / 2) * angle;
      final hue = (hslColor.h + hueOffset) % 360;
      return HSL.fromAHSL(
        baseColor.a,
        hue,
        hslColor.s,
        hslColor.l,
      ).toColor();
    });
  }

  /// Creates a complementary color palette
  /// Generates the base color and its complement (opposite on color wheel)
  static List<Color> complementary(Color baseColor) {
    final hslColor = HSL.fromColor(baseColor);

    // Adjust complement lightness for better contrast (matches color_palette_plus)
    final complementLightness = hslColor.l > 0.5 
        ? hslColor.l * 0.8 
        : hslColor.l * 1.2;

    final complement = HSL.fromAHSL(
      baseColor.a,
      (hslColor.h + 180) % 360,
      hslColor.s,
      complementLightness.clamp(0.0, 1.0),
    ).toColor();

    return [
      baseColor,
      complement
    ];
  }
}

/// Theme brightness enumeration
enum Brightness {
  light,
  dark;
}

/// The type of color harmony to use when generating a color scheme
/// Matches the HarmonyType enum from color_palette_plus
enum HarmonyType {
  /// Creates colors that are adjacent on the color wheel
  analogous,

  /// Uses colors from opposite sides of the color wheel
  complementary,

  /// Uses variations of the same color with different lightness values
  monochromatic,
}

/// Semantic color roles that can be customized in Material 3 themes
/// Subset of the most commonly used roles from color_palette_plus
enum ColorRole {
  // Core colors
  primary,
  onPrimary,
  primaryContainer,
  onPrimaryContainer,
  secondary,
  onSecondary,
  secondaryContainer,
  onSecondaryContainer,
  tertiary,
  onTertiary,
  tertiaryContainer,
  onTertiaryContainer,
  
  // Error colors
  error,
  onError,
  errorContainer,
  onErrorContainer,
  
  // Neutral colors
  background,
  onBackground,
  surface,
  onSurface,
  surfaceContainer,
  outline,
  
  // Inverse colors
  inverseSurface,
  onInverseSurface,
  inversePrimary,
  
  // Shadow
  shadow,
  scrim,
}

/// Configuration for generating color schemes in Material 3 themes
/// Replicates the ColorSchemeConfig from color_palette_plus
class ColorSchemeConfig {
  /// The type of color harmony to use for generating secondary and tertiary colors
  final HarmonyType harmonyType;

  /// The angle between analogous colors in degrees
  final double analogousAngle;

  /// Number of steps for generating harmonious colors
  final int harmonySteps;

  /// Creates a configuration for color scheme generation
  const ColorSchemeConfig({
    this.harmonyType = HarmonyType.analogous,
    this.analogousAngle = 30,
    this.harmonySteps = 3,
  });
}

/// Configuration class for customizing theme generation
/// Simplified version of ThemeConfig from color_palette_plus
class ThemeConfig {
  /// The target brightness for the theme
  final Brightness brightness;

  /// Custom color mappings that override the default theme colors
  final Map<ColorRole, Color>? colorOverrides;

  /// Configuration for generating the color scheme
  final ColorSchemeConfig? colorSchemeConfig;

  /// Creates a configuration for theme generation
  const ThemeConfig({
    this.brightness = Brightness.light,
    this.colorOverrides,
    this.colorSchemeConfig,
  });

  /// Creates a copy of this configuration with dark brightness
  ThemeConfig copyWithDark() {
    return ThemeConfig(
      brightness: Brightness.dark,
      colorOverrides: colorOverrides,
      colorSchemeConfig: colorSchemeConfig,
    );
  }
}

/// A simplified color scheme representation for Material 3 themes
/// Contains the essential colors needed for a complete theme
class ColorScheme {
  final Brightness brightness;
  
  // Primary colors
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  
  // Secondary colors
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  
  // Tertiary colors
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  
  // Error colors
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  
  // Neutral colors
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceContainer;
  final Color outline;
  
  // Inverse colors
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color inversePrimary;
  
  // Shadow
  final Color shadow;
  final Color scrim;

  const ColorScheme({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceContainer,
    required this.outline,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
    required this.shadow,
    required this.scrim,
  });
}

/// Extension methods for generating themes based on Material 3 specifications
/// Replicates the ThemeGenerator from color_palette_plus
class ThemeGenerator {
  /// Generates a complete color scheme based on a primary color
  /// Follows the same algorithm as color_palette_plus
  static ColorScheme generateColorScheme(
    Color primaryColor, {
    ThemeConfig? config,
  }) {
    final effectiveConfig = config ?? const ThemeConfig();
    final colorScheme = _generateColorScheme(primaryColor, effectiveConfig);
    return colorScheme;
  }

  /// Generates both light and dark color schemes based on a primary color
  static ColorSchemePair generateColorSchemePair(
    Color primaryColor, {
    ThemeConfig? config,
  }) {
    final lightConfig = config ?? const ThemeConfig();
    final darkConfig = lightConfig.copyWithDark();

    return ColorSchemePair(
      light: generateColorScheme(primaryColor, config: lightConfig),
      dark: generateColorScheme(primaryColor, config: darkConfig),
    );
  }

  static ColorScheme _generateColorScheme(Color primaryColor, ThemeConfig config) {
    final MaterialColor swatch = ColorPalette.generateSwatch(primaryColor);
    final harmonyConfig = config.colorSchemeConfig ?? const ColorSchemeConfig();

    // Use swatch for primary color variants
    final primaryContainer = swatch[700]!;
    final onPrimaryContainer = _generateOnColor(primaryContainer);

    // Generate secondary and tertiary colors based on harmony type
    final List<Color> harmonicColors = _generateHarmonicColors(
      primaryColor,
      harmonyConfig,
    );

    final Color secondaryColor = harmonicColors.length > 1 ? harmonicColors[1] : primaryColor;
    final Color tertiaryColor = harmonicColors.length > 2 ? harmonicColors[2] : secondaryColor;

    // Apply any color overrides
    final colorOverrides = config.colorOverrides ?? {};

    // Generate surface colors
    final surfaceColor = _generateSurfaceColor(primaryColor, harmonicColors, config.brightness);

    // Generate default colors
    final defaultPrimary = swatch[500]!;
    final defaultError = _generateErrorColor(config.brightness);
    final defaultSurface = surfaceColor;

    return ColorScheme(
      brightness: config.brightness,
      // Primary colors
      primary: colorOverrides[ColorRole.primary] ?? defaultPrimary,
      onPrimary: colorOverrides[ColorRole.onPrimary] ?? _generateOnColor(defaultPrimary),
      primaryContainer: colorOverrides[ColorRole.primaryContainer] ?? primaryContainer,
      onPrimaryContainer: colorOverrides[ColorRole.onPrimaryContainer] ?? onPrimaryContainer,

      // Secondary colors
      secondary: colorOverrides[ColorRole.secondary] ?? secondaryColor,
      onSecondary: colorOverrides[ColorRole.onSecondary] ?? _generateOnColor(secondaryColor),
      secondaryContainer: colorOverrides[ColorRole.secondaryContainer] ?? ColorPalette.generateSwatch(secondaryColor)[700]!,
      onSecondaryContainer: colorOverrides[ColorRole.onSecondaryContainer] ?? _generateOnColor(ColorPalette.generateSwatch(secondaryColor)[700]!),

      // Tertiary colors
      tertiary: colorOverrides[ColorRole.tertiary] ?? tertiaryColor,
      onTertiary: colorOverrides[ColorRole.onTertiary] ?? _generateOnColor(tertiaryColor),
      tertiaryContainer: colorOverrides[ColorRole.tertiaryContainer] ?? ColorPalette.generateSwatch(tertiaryColor)[700]!,
      onTertiaryContainer: colorOverrides[ColorRole.onTertiaryContainer] ?? _generateOnColor(ColorPalette.generateSwatch(tertiaryColor)[700]!),

      // Error colors
      error: colorOverrides[ColorRole.error] ?? defaultError,
      onError: colorOverrides[ColorRole.onError] ?? _generateOnColor(defaultError),
      errorContainer: colorOverrides[ColorRole.errorContainer] ?? ColorPalette.generateSwatch(defaultError)[700]!,
      onErrorContainer: colorOverrides[ColorRole.onErrorContainer] ?? _generateOnColor(ColorPalette.generateSwatch(defaultError)[700]!),

      // Surface colors
      surface: colorOverrides[ColorRole.surface] ?? defaultSurface,
      onSurface: colorOverrides[ColorRole.onSurface] ?? _generateOnColor(defaultSurface),
      surfaceContainer: colorOverrides[ColorRole.surfaceContainer] ?? _adjustSurfaceContainer(defaultSurface, config.brightness),
      background: colorOverrides[ColorRole.background] ?? defaultSurface,
      onBackground: colorOverrides[ColorRole.onBackground] ?? _generateOnColor(defaultSurface),

      // Additional colors
      outline: colorOverrides[ColorRole.outline] ?? ColorPalette.generateSwatch(defaultSurface)[400]!,
      shadow: colorOverrides[ColorRole.shadow] ?? const Color(0xFF000000),
      scrim: colorOverrides[ColorRole.scrim] ?? const Color(0xFF000000),

      // Inverse colors
      inverseSurface: colorOverrides[ColorRole.inverseSurface] ?? _generateInverseSurface(defaultPrimary, config.brightness),
      onInverseSurface: colorOverrides[ColorRole.onInverseSurface] ?? _generateOnColor(config.brightness == Brightness.light ? const Color(0xFF000000) : const Color(0xFFFFFFFF)),
      inversePrimary: colorOverrides[ColorRole.inversePrimary] ?? ColorPalette.generateSwatch(defaultPrimary)[200]!,
    );
  }

  /// Generates an appropriate surface color based on primary color and brightness
  static Color _generateSurfaceColor(Color primaryColor, List<Color> harmonicColors, Brightness brightness) {
    final primaryHsl = HSL.fromColor(primaryColor);
    final primaryLightness = primaryHsl.l;

    // Use primary color lightness to determine surface color
    if (primaryLightness < 0.2) {
      return harmonicColors.length > 1 ? harmonicColors[1] : primaryColor;
    } else if (primaryLightness > 0.8) {
      return harmonicColors.length > 2 ? harmonicColors[2] : primaryColor;
    } else {
      return brightness == Brightness.light ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    }
  }

  static Color _adjustSurfaceContainer(Color surface, Brightness brightness) {
    // For pure black or white, maintain neutral gray values
    if (surface.value == 0xFF000000 || surface.value == 0xFFFFFFFF) {
      final grayValue = brightness == Brightness.light
          ? 0.95 // Slightly darker than white for light mode
          : 0.07; // Slightly lighter than black for dark mode
      return Color.fromARGB(
        255,
        (grayValue * 255).round(),
        (grayValue * 255).round(),
        (grayValue * 255).round(),
      );
    }

    final surfaceHsl = HSL.fromColor(surface);
    final adjustedLightness = brightness == Brightness.light 
        ? (surfaceHsl.l - 0.05).clamp(0.0, 1.0) 
        : (surfaceHsl.l + 0.05).clamp(0.0, 1.0);

    return surfaceHsl.withLightness(adjustedLightness).toColor();
  }

  /// Generates harmonic colors based on the configuration
  static List<Color> _generateHarmonicColors(
    Color primaryColor,
    ColorSchemeConfig config,
  ) {
    switch (config.harmonyType) {
      case HarmonyType.analogous:
        return ColorPalettes.analogous(
          primaryColor,
          steps: config.harmonySteps,
          angle: config.analogousAngle,
        );
      case HarmonyType.complementary:
        return ColorPalettes.complementary(primaryColor);
      case HarmonyType.monochromatic:
        return ColorPalettes.monochromatic(
          primaryColor,
          steps: config.harmonySteps,
        );
    }
  }

  /// Generates an appropriate contrasting color for text/icons on a background
  /// Public method for determining optimal text color based on background
  static Color generateOnColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }

  /// Generates an appropriate contrasting color for text/icons on a background
  static Color _generateOnColor(Color background) {
    return generateOnColor(background);
  }

  /// Generates an appropriate error color based on brightness
  static Color _generateErrorColor(Brightness brightness) {
    return brightness == Brightness.light
        ? const Color(0xFFB00020) // Material Design error color
        : const Color(0xFFCF6679); // Dark theme error color
  }

  /// Generates an inverse surface color
  static Color _generateInverseSurface(Color primary, Brightness brightness) {
    final primaryWithAlpha = Color.fromARGB(
      (0.05 * 255).round(),
      primary.red,
      primary.green,
      primary.blue,
    );
    
    final baseColor = brightness == Brightness.light 
        ? const Color(0xFF000000) 
        : const Color(0xFFFFFFFF);
    
    // Simple alpha blending approximation
    final alpha = primaryWithAlpha.a;
    final invAlpha = 1.0 - alpha;
    
    return Color.fromARGB(
      255,
      (primary.red * alpha + baseColor.red * invAlpha).round(),
      (primary.green * alpha + baseColor.green * invAlpha).round(),
      (primary.blue * alpha + baseColor.blue * invAlpha).round(),
    );
  }
}

/// A container for paired light and dark color schemes
/// Replicates the ThemePair concept from color_palette_plus
class ColorSchemePair {
  /// The light color scheme variant
  final ColorScheme light;

  /// The dark color scheme variant
  final ColorScheme dark;

  /// Creates a pair of light and dark color schemes
  const ColorSchemePair({
    required this.light,
    required this.dark,
  });
}