import 'package:clock_app/theme/types/color_scheme.dart';
import 'package:flutter/material.dart';

SwitchThemeData getSwitchTheme(ColorSchemeData colorScheme) {
  return SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? colorScheme.card : Colors.white),
    trackColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? colorScheme.accent
            : colorScheme.onBackground.withValues(alpha: 0.3)),
    overlayColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? colorScheme.accent
            : colorScheme.onBackground.withValues(alpha: 0.3)),
    trackOutlineColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? colorScheme.accent
            : Colors.transparent),
    splashRadius: 0,
  );
}
