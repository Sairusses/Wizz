import 'package:flutter/material.dart';

class CustomTabIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomPainter();
  }
}

class _CustomPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double tabWidth = configuration.size!.width;
    final double tabHeight = configuration.size!.height;

    final double fullWidth = tabWidth + 32;

    final Rect rect = Rect.fromLTWH(
      offset.dx - 16,
      offset.dy,
      fullWidth,
      tabHeight,
    );

    final RRect roundedRect = RRect.fromRectAndRadius(rect, Radius.circular(25));
    canvas.drawRRect(roundedRect, paint);

    // final Paint paint2 = Paint()
    //   ..color = Colors.white
    //   ..style = PaintingStyle.fill
    //   ..isAntiAlias = true;
    //
    // final Rect rect2 = Rect.fromLTWH(
    //   offset.dx,
    //   offset.dy + tabHeight - 15,
    //   tabWidth,
    //   7,
    // );
    // final RRect roundedRect2 = RRect.fromRectAndRadius(rect2, Radius.circular(25));
    // canvas.drawRRect(roundedRect2, paint2);
  }
}
