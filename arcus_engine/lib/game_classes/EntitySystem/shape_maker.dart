import "dart:math";
import "dart:ui";

import 'package:arcus_engine/game_classes/EntitySystem/physics_body_simple.dart';
import 'package:arcus_engine/helpers/vector_little.dart';
import 'package:arcus_engine/game_classes/EntitySystem/world.dart';
import 'package:arcus_engine/helpers/game_object.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;

enum ShapeType {
  Circle,
  Rect,
  RoundedRect,
  Triangle,
  Diamond,
  Pentagon,
  Hexagon,
  Octagon,
  Decagon,
  Dodecagon,
  Heart,
  Star5,
  Star6,
  Star7,
  Star8,
}

class ShapeMaker {
  ShapeType type = ShapeType.Rect;
  Size size = Size(20, 20);
  double radius = 0.0;
  double? angle = 0.0;
  Color _color = Color.fromARGB(255, 0, 0, 0);
  Paint paint = Paint();
  bool _alive = false;
  bool? startAlive = false;
  Point<double> position = Point(0, 0);
  int _zIndex = 0;
  bool _interactive = false;
  Function? _onEvent;
  String _id = "";
  dynamic _physicsBody = null;
  double scale = 1.0;
  bool enablePhysics = false;
  TDWorld? world = GameObject.shared.getWorld();
  PhysicsBodyProperties physicsBodyProperties = PhysicsBodyProperties();
  Function? _onCollide;

  ShapeMaker({
    required this.type,
    size,
    radius,
    position,
    angle,
    scale,
    paintOptions,
    startAlive,
    id,
    zIndex,
    interactive,
    enablePhysics,
    physicsProperties,
    onCollide,
  }) {
    this.size = size ?? Size(20, 20);
    this._color = Color.fromARGB(255, 0, 0, 0);
    this.radius = radius.toDouble() ?? 50.0;
    this.position = position;
    this.angle = angle ?? 0.0;
    this.scale = scale ?? 1.0;
    this.id = id ?? UniqueKey().toString();
    this.zIndex = zIndex ?? 0;
    this.interactive = interactive ?? false;
    this.enablePhysics = enablePhysics ?? false;
    //
    if (startAlive == true) {
      this.alive = true;
    }

    if (paintOptions != null) {
      this.paint = Paint()
        ..color = paintOptions["color"] ?? this._color
        ..style = paintOptions["paintingStyle"] ?? PaintingStyle.fill;
    } else {
      this.paint = Paint()
        ..color = this._color
        ..style = PaintingStyle.fill;
    }

    physicsBodyProperties = physicsProperties ?? PhysicsBodyProperties();
    if (startAlive == true) {
      alive = true;
    }

    this.enablePhysics = enablePhysics ?? false;
    if (this.enablePhysics == true) {
      setupPhysicsBody();
      _onCollide = onCollide;
    }
  }

  void update(
    Canvas canvas, {
    double elapsedTime = 0,
    double timestamp = 0.0,
    bool shouldUpdate = true,
  }) {
    /// Physics
    if (enablePhysics == true && physicsBody == null) {
      setupPhysicsBody();
    }
    if (physicsBody != null) {
      physicsBody!.update(
        canvas,
        elapsedTime: elapsedTime,
        timestamp: timestamp,
        shouldUpdate: shouldUpdate,
      );

      /// apply the physics pos to the actual object
      position = Point(physicsBody!.pos.x, physicsBody!.pos.y);
    }

    drawType(canvas, type);
  }

  ///
  setupPhysicsBody() {
    world = GameObject.shared.getWorld();
    if (world != null) {
      physicsBody = PhysicsBodySimple(
        object: this,
        pos: Vector2(x: position.x, y: position.y),
        world: world!,
        size: Vector2(x: size.width, y: size.height),
        physicsProperties: physicsBodyProperties,
        onCollision: _onCollide,
      );
    }
  }

  bool onCollide(dynamic item) {
    return true;
  }

  void drawType(Canvas canvas, ShapeType type) {
    switch (type) {
      case ShapeType.Circle:
        drawCircle(canvas);
        break;
      case ShapeType.Rect:
        drawRect(canvas);
        break;
      case ShapeType.RoundedRect:
        drawRRect(canvas);
        break;
      case ShapeType.Triangle:
        drawPolygon(canvas, 3, initialAngle: 30);
        break;
      case ShapeType.Diamond:
        drawPolygon(canvas, 4, initialAngle: 0);
        break;
      case ShapeType.Pentagon:
        drawPolygon(canvas, 5, initialAngle: -18);
        break;
      case ShapeType.Hexagon:
        drawPolygon(canvas, 6, initialAngle: 0);
        break;
      case ShapeType.Octagon:
        drawPolygon(canvas, 8, initialAngle: 0);
        break;
      case ShapeType.Decagon:
        drawPolygon(canvas, 10, initialAngle: 0);
        break;
      case ShapeType.Dodecagon:
        drawPolygon(canvas, 12, initialAngle: 0);
        break;
      case ShapeType.Heart:
        drawHeart(canvas);
        break;
      case ShapeType.Star5:
        drawStar(canvas, 10, initialAngle: 15);
        break;
      case ShapeType.Star6:
        drawStar(canvas, 12, initialAngle: 0);
        break;
      case ShapeType.Star7:
        drawStar(canvas, 14, initialAngle: 0);
        break;
      case ShapeType.Star8:
        drawStar(canvas, 16, initialAngle: 0);
        break;
    }
  }

  void drawCircle(Canvas canvas) {
    updateCanvas(canvas, this.position.x, this.position.y, 0, () {
      canvas.drawCircle(Offset.zero, radius, paint);
    });
  }

  void drawRRect(Canvas canvas, {double? cornerRadius}) {
    updateCanvas(canvas, 0, 0, 0, () {
      Rect rect = Rect.fromLTWH(0, 0, this.size.width, this.size.height);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius ?? radius * 0.2)), this.paint);
    });
  }

  void drawPolygon(Canvas canvas, int num, {double initialAngle = 0}) {
    updateCanvas(canvas, 0, 0, 0, () {
      final Path path = Path();
      for (int i = 0; i < num; i++) {
        final double radian = vectorMath.radians(initialAngle + 360 / num * i.toDouble());
        final double x = radius * cos(radian);
        final double y = radius * sin(radian);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    });
  }

  void drawHeart(Canvas canvas) {
    updateCanvas(canvas, 0, 0, 0, () {
      final Path path = Path();

      path.moveTo(0, radius);

      path.cubicTo(-radius * 2, -radius * 0.5, -radius * 0.5, -radius * 1.5, 0, -radius * 0.5);
      path.cubicTo(radius * 0.5, -radius * 1.5, radius * 2, -radius * 0.5, 0, radius);

      canvas.drawPath(path, paint);
    });
  }

  void drawStar(Canvas canvas, int num, {double initialAngle = 0}) {
    updateCanvas(canvas, 0, 0, 0, () {
      final Path path = Path();
      for (int i = 0; i < num; i++) {
        final double radian = vectorMath.radians(initialAngle + 360 / num * i.toDouble());
        final double x = radius * (i.isEven ? 0.5 : 1) * cos(radian);
        final double y = radius * (i.isEven ? 0.5 : 1) * sin(radian);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, this.paint);
    });
  }

  void drawRect(Canvas canvas) {
    updateCanvas(canvas, this.position.x, this.position.y, this.angle, () {
      canvas.drawRect(Rect.fromLTWH(0, 0, this.size.width, this.size.height), this.paint);
    });
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

  bool get alive {
    return _alive;
  }

  set alive(bool value) {
    _alive = value;
  }

  dynamic get physicsBody {
    return _physicsBody;
  }

  set physicsBody(dynamic value) {
    _physicsBody = value;
  }

  void set zIndex(int value) {
    this._zIndex = value;
  }

  int get zIndex {
    return this._zIndex;
  }

  String get id {
    return this._id;
  }

  set id(String value) {
    this._id = value;
  }

  Point<double> getPosition() {
    Point<double> pos = Point(position.x - this.size.width / 2, position.y - this.size.height / 2);
    return pos;
  }

  dynamic getProperty(String type) {
    switch (type) {
      case "scale":
        {
          return scale;
        }

      case "x":
        {
          return position.x;
        }

      case "y":
        {
          return position.y;
        }

      case "rotation":
        {
          return angle;
        }
    }
  }

  void setProperty(String type, dynamic value) {
    switch (type) {
      case "scale":
        {
          scale = value;
          break;
        }
      case "x":
        {
          position = Point(value, position.y);
          break;
        }

      case "y":
        {
          position = Point(position.x, value);
          break;
        }
    }
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
