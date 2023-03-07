import 'dart:convert';
import 'package:flutter/services.dart';

class ColorsProvider {
  static final ColorsProvider _instance = ColorsProvider._();
  ColorsProvider._();
  static ColorsProvider get instance => _instance;

  List<String> pureColors = [];
  List<String> gradientColors = [];

  initialized() async {
    String pureColorsJsonString =
        await rootBundle.loadString('assets/jsons/pure_colors.json');
    List pureColorsJsonList = json.decode(pureColorsJsonString);
    List<String> pureColorsResult =
        pureColorsJsonList.map((m) => m.toString()).toList();
    pureColors = pureColorsResult;
    for (int i = 0; i < 38; i++) {
      gradientColors
          .add('assets/images/gradient_colors/gradient_color_$i.webp');
    }
  }

  static Color getColorFromHexString(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  static RGBAColor convertRGBAColorFromHexString(String hexColor) {
    String colorString = hexColor;
    if (hexColor.startsWith('#') && hexColor.length == 9) {
      colorString = colorString.replaceRange(0, 1, '0xff');
    }
    Color color = Color(int.parse(colorString));
    int red = color.red;
    int green = color.green;
    int blue = color.blue;
    int alpha = color.alpha;
    return RGBAColor(r: red, g: green, b: blue, a: alpha);
  }
}

class RGBAColor {
  final int r;
  final int g;
  final int b;
  final int a;

  RGBAColor({
    required this.r,
    required this.g,
    required this.b,
    required this.a,
  });
}
