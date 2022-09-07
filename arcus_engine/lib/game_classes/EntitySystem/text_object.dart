import 'dart:math';

import 'package:arcus_engine/helpers/vector_little.dart';
import 'package:flutter/material.dart';

class Text {
  String text = "";
  Vector2 position = Vector2(x: 0, y: 0);
  Size size = const Size(0, 0);
  late FontWeight fontWeight;
  late FontStyle fontStyle;
  late double opacity;
  late Color color;
  late double fontSize;
  late double lineHeight;
  late bool border;
  late double borderWidth;
  late Color borderColor;
  late Offset gradientOffsetStart;
  late Offset gradientOffsetEnd;
  late List<Color> gradientColors;
  late String fontFamily;
  double maxWidth = 0.0;
  double maxHeight = 0.0;
  int maxLines = 10;
  late Paint paint;
  Function? _onEvent;
  bool _interactive = false;
  String id = UniqueKey().toString();
  bool alive = false;
  int zIndex = 0;
  late TextSpan textSpan;
  late TextPainter textPainter;
  double angle = 0.0;

  /// constructor
  Text({
    required this.text,
    required this.position,
    fontWeight,
    fontStyle,
    opacity,
    color,
    fontSize,
    lineHeight,
    border,
    borderWidth,
    borderColor,
    gradientOffsetStart,
    gradientOffsetEnd,
    gradientColors,
    fontFamily,
    startAlive,
    zIndex,
    maxWidth,
    maxHeight,
    maxLines,
    angle,
  }) {
    this.fontWeight = fontWeight ?? FontWeight.normal;
    this.fontStyle = fontStyle ?? FontStyle.normal;
    this.opacity = opacity ?? 1;
    this.color = color ?? Colors.black;
    this.border = border ?? false;
    this.borderWidth = borderWidth ?? 0;
    this.borderColor = borderColor ?? Colors.black;
    this.gradientOffsetStart = gradientOffsetStart ?? const Offset(0.0, 0.0);
    this.gradientOffsetEnd = gradientOffsetEnd ?? const Offset(0.0, 0.0);
    this.gradientColors = gradientColors ?? [];
    alive = startAlive ?? false;
    this.zIndex = zIndex ?? 0;
    this.maxWidth = maxWidth ?? 0;
    this.maxHeight = maxHeight ?? 0;
    this.maxLines = maxLines ?? 10;
    this.angle = angle ?? 0.0;
    paint = Paint();

    // bordered
    if (border) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = borderColor;
    }

    /// text constructors
    textSpan = TextSpan(text: text, style: TextStyle());
    textPainter = TextPainter(text: textSpan, maxLines: maxLines);

    performLayout();
  }

  setText(String value) {
    text = value;
  }

  String getText() {
    return text;
  }

  bool get interactive {
    return _interactive;
  }

  void set interactive(bool value) {
    this._interactive = value;
  }

  void set onEvent(Function? value) {
    this._onEvent = value;
  }

  Function? get onEvent {
    return this._onEvent;
  }

  Point<double> getPosition() {
    Point<double> pos = Point(position.x - size.width / 2, position.y - size.height / 2);
    return pos;
  }

  performLayout() {
    textPainter.layout(minWidth: 0, maxWidth: maxWidth);
    size = textPainter.size;
  }

  void update(
    Canvas canvas, {
    double elapsedTime = 0,
    double timestamp = 0.0,
    bool shouldUpdate = true,
  }) {
    // /// Physics
    // if (enablePhysics == true && physicsBody == null) {
    //   setupPhysicsBody();
    // }
    // if (physicsBody != null) {
    //   physicsBody!.update(
    //     canvas,
    //     elapsedTime: elapsedTime,
    //     timestamp: timestamp,
    //     shouldUpdate: shouldUpdate,
    //   );

    /// apply the physics pos to the actual object
    //position = Point(physicsBody!.pos.x, physicsBody!.pos.y);
    //}

    /// calculate layout based on any possible changes between
    /// previous update and this one
    performLayout();
    updateCanvas(canvas, position.x, position.y, angle, () {
      textPainter.paint(canvas, Offset.zero);
    });
  }

  void updateCanvas(Canvas canvas, double? x, double? y, double? rotate, VoidCallback callback, {bool translate = false}) {
    double _x = x ?? 0;
    double _y = y ?? 0;
    canvas.save();

    if (translate) {
      canvas.translate(_x, _y);
    }

    if (rotate != null) {
      canvas.translate(_x, _y);
      canvas.rotate(rotate);
    }
    callback();
    canvas.restore();
  }
}
