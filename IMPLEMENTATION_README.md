# Color Palette Generator - Implementação do Esquema color_palette_plus

Esta implementação replica completamente o esquema de geração de paletas do pacote `color_palette_plus`, porém usando apenas Dart puro, sem dependências do Flutter.

## 🎯 Funcionalidades Implementadas

### 1. **Material Design Color Swatches**
- Geração de tons de 50 a 900 seguindo as especificações do Material Design
- Algoritmo baseado em HSL para transições naturais de cor
- Valores de luminosidade idênticos ao `color_palette_plus`

### 2. **Paletas de Harmonia de Cores**

#### **Monocromática**
- Gera cores com o mesmo matiz mas diferentes valores de luminosidade
- Curva de luminosidade perceptual (quadrática) para melhor distribuição visual
- Exemplo: diferentes tons de azul do mais claro ao mais escuro

#### **Análoga**
- Gera cores adjacentes no círculo cromático
- Ângulo configurável entre as cores (padrão: 30°)
- Mantém saturação e luminosidade da cor base

#### **Complementar**
- Gera a cor base e sua complementar (oposta no círculo cromático)
- Ajuste automático de luminosidade para melhor contraste
- Ideal para criar ênfase e interesse visual

### 3. **Sistema de Temas Material 3**
- Geração automática de esquemas de cores completos
- Suporte a temas claros e escuros
- Cores semânticas: primary, secondary, tertiary, surface, background, error
- Sistema de cores "on" para garantir contraste adequado

### 4. **Algoritmos de Cores Avançados**
- **Conversão HSL ↔ RGB**: Implementação precisa para manipulação de cores
- **Cálculo de Luminância**: Para determinar contraste e legibilidade
- **Geração de Cores "On"**: Preto ou branco baseado na luminância de fundo
- **Ajuste de Superfícies**: Variações sutis para diferentes elevações

## 🔧 Classes Principais

### `Color`
- Representação básica de cor em RGB
- Métodos para acessar componentes (red, green, blue, alpha)
- Cálculo de luminância relativa

### `HSL`
- Espaço de cor HSL (Hue, Saturation, Lightness)
- Conversões precisas de/para RGB
- Métodos para ajustar matiz, saturação e luminosidade

### `ColorPalette`
- Geração de Material Swatches
- Métodos utilitários para tons específicos
- Algoritmos baseados no `color_palette_plus`

### `ColorPalettes`
- Paletas de harmonia (monocromática, análoga, complementar)
- Implementação exata dos algoritmos do pacote original

### `ThemeGenerator`
- Geração de esquemas de cores Material 3
- Suporte a configurações personalizadas
- Diferentes tipos de harmonia para secondary/tertiary

### `ColorScheme`
- Representação completa de esquema de cores
- Todas as cores semânticas do Material 3
- Suporte a temas claros e escuros

## 📊 Algoritmos Replicados

### Material Swatch (50-900)
```dart
// Valores de luminosidade exatos do color_palette_plus
50:  0.95 (mais claro)
100: 0.88
200: 0.80
300: 0.70
400: 0.60
500: [cor original] 
600: 0.40
700: 0.30
800: 0.20
900: 0.12 (mais escuro)
```

### Paleta Monocromática
```dart
// Curva de luminosidade perceptual
lightness = 0.15 + 0.7 * t * t
// onde t = index / (steps - 1)
```

### Paleta Análoga
```dart
// Cálculo do matiz
hue = (baseHue + offset * angle) % 360
// offset = (index - (steps - 1) / 2) * angle
```

### Paleta Complementar
```dart
// Matiz complementar
complementHue = (baseHue + 180) % 360
// Ajuste de luminosidade para contraste
complementLightness = baseLightness > 0.5 ? baseLightness * 0.8 : baseLightness * 1.2
```

## 🎨 Exemplo de Uso

```dart
import 'package:color_swatch_generator/color_swatch.dart';

void main() {
  // Cor base
  final baseColor = Color(0xFF2196F3); // Azul Material
  
  // 1. Material Swatch
  final swatch = ColorPalette.generateSwatch(baseColor);
  print('Shade 500: ${swatch[500]}'); // Cor original
  print('Shade 100: ${swatch[100]}'); // Mais claro
  print('Shade 900: ${swatch[900]}'); // Mais escuro
  
  // 2. Paletas de Harmonia
  final monoColors = ColorPalettes.monochromatic(baseColor, steps: 5);
  final analogousColors = ColorPalettes.analogous(baseColor, steps: 3, angle: 30);
  final complementaryColors = ColorPalettes.complementary(baseColor);
  
  // 3. Esquema de Cores Material 3
  final lightScheme = ThemeGenerator.generateColorScheme(
    baseColor,
    config: ThemeConfig(
      brightness: Brightness.light,
      colorSchemeConfig: ColorSchemeConfig(
        harmonyType: HarmonyType.analogous,
        analogousAngle: 30,
        harmonySteps: 3,
      ),
    ),
  );
  
  print('Primary: ${lightScheme.primary}');
  print('Secondary: ${lightScheme.secondary}');
  print('Surface: ${lightScheme.surface}');
}
```

## ✨ Vantagens da Implementação

1. **Puro Dart**: Sem dependências do Flutter, pode ser usado em qualquer projeto Dart
2. **Fidelidade**: Algoritmos idênticos ao `color_palette_plus`
3. **Completo**: Todas as funcionalidades principais implementadas
4. **Flexível**: Configurações personalizáveis para diferentes necessidades
5. **Documentado**: Código bem comentado e explicado

## 🔍 Comparação com color_palette_plus

| Funcionalidade | color_palette_plus | Esta Implementação |
|----------------|--------------------|--------------------|
| Material Swatch | ✅ | ✅ |
| Paletas Monocromáticas | ✅ | ✅ |
| Paletas Análogas | ✅ | ✅ |
| Paletas Complementares | ✅ | ✅ |
| Temas Material 3 | ✅ | ✅ |
| Sem Flutter | ❌ | ✅ |
| Dart Puro | ❌ | ✅ |

## 🧪 Testes

Execute o arquivo de teste para ver todas as funcionalidades em ação:

```bash
dart run lib/test.dart
```

O teste demonstra:
- Geração de Material Swatch com todos os tons
- Paletas monocromáticas, análogas e complementares
- Esquemas de cores claros e escuros
- Diferentes tipos de harmonia
- Análise de contraste e luminância

## 📈 Algoritmos de Qualidade

### Cálculo de Luminância Relativa
Segue a fórmula padrão W3C para acessibilidade:
```
L = 0.2126 * R + 0.7152 * G + 0.0722 * B
```

### Contraste Automático
Determina automaticamente se usar texto preto ou branco baseado na luminância de fundo:
```dart
textColor = backgroundLuminance > 0.5 ? black : white
```

### Cores de Erro Material Design
- **Tema Claro**: `#B00020`
- **Tema Escuro**: `#CF6679`

---

**Implementação completa e fiel do esquema color_palette_plus em Dart puro! 🎨**
