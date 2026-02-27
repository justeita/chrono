import 'package:flutter/material.dart';
import 'dart:ui' as ui;

Size calcTextSize(String text, TextStyle style) {
  // String text = '0' * length;
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.linear(ui
                .PlatformDispatcher.instance.views.first.devicePixelRatio >
            0
        ? MediaQueryData.fromView(ui.PlatformDispatcher.instance.views.first)
            .textScaler
            .scale(1)
        : 1.0),
  )..layout();
  return textPainter.size;
}

Size calcTextSizeFromLength(int length, TextStyle style) {
  return calcTextSize('0' * length, style);
}
