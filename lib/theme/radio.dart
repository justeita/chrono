import 'package:clock_app/theme/types/color_scheme.dart';
import 'package:flutter/material.dart';

RadioThemeData getRadioTheme(ColorSchemeData colorScheme) {
  return RadioThemeData(
    fillColor: WidgetStateProperty.all(colorScheme.accent),
  );
}
