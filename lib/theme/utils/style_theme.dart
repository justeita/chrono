
// ThemeData getThemeFromStyleTheme(ThemeData theme, StyleTheme styleTheme) {
//   ColorSchemeData colorSchemeData = appSettings
//       .getGroup("Appearance")
//       .getGroup("Colors")
//       .getSetting("Color Scheme")
//       .value;
//   RoundedRectangleBorder shape = RoundedRectangleBorder(
//     borderRadius: BorderRadius.circular(styleTheme.borderRadius),
//   );
//   return theme = theme.copyWith(
//     cardTheme: theme.cardTheme.copyWith(shape: shape),
//     bottomSheetTheme: getBottomSheetTheme(colorSchemeData, styleTheme),
//     timePickerTheme: theme.timePickerTheme.copyWith(
//       shape: shape,
//       dayPeriodShape: shape,
//       hourMinuteShape: shape,
//     ),
//     toggleButtonsTheme: theme.toggleButtonsTheme.copyWith(
//       borderRadius: BorderRadius.circular(styleTheme.borderRadius),
//     ),
//     snackBarTheme: getSnackBarTheme(colorSchemeData, styleTheme),
//     inputDecorationTheme: getInputTheme(colorSchemeData, styleTheme),
//     popupMenuTheme: getPopupMenuTheme(colorSchemeData, styleTheme),
//     extensions: [
//       theme.extension<ThemeStyleExtension>()?.copyWith(
//                 borderRadius: styleTheme.borderRadius,
//                 shadowElevation: styleTheme.shadowElevation,
//                 shadowBlurRadius: styleTheme.shadowBlurRadius,
//                 shadowOpacity: styleTheme.shadowOpacity,
//                 shadowSpreadRadius: styleTheme.shadowSpreadRadius,
//                 borderWidth: styleTheme.borderWidth,
//               ) ??
//           const ThemeStyleExtension(),
//     ],
//   );
// }
