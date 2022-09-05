import 'dart:math';

import 'package:arcus_engine/game_classes/EntitySystem/physics_body_simple.dart';
import 'package:arcus_engine/game_classes/EntitySystem/shape_maker.dart';
import 'package:arcus_engine/game_classes/EntitySystem/vector_little.dart';
import 'package:arcus_engine/helpers/GameObject.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

class Particle {
  String id = UniqueKey().toString();
  Vector2 pos = Vector2(x: 0, y: 0);
  double angle = 0;
  PhysicsBodyProperties physicsProperties = PhysicsBodyProperties();
  Color colorStart = const Color(0x000);
  Color colorEnd = const Color(0xfff);
  double scale = 0.0;
  double lifetime = 1.0;
  bool alive = false;
  Function? destroyCallback = null;
  double sizeStart = 0;
  double sizeEnd = 0;
  double fadeRate = 1.0;
  bool destroyed = false;
  double spawnTime = GameObject.shared.time;
  late ShapeMaker renderer;

  Particle({required this.pos, angle, physicsProperties, colorStart, colorEnd, sizeStart, sizeEnd, lifetime, fadeRate, spawnTime, destroyCallback}) {
    var p = min((GameObject.shared.time - spawnTime) / lifetime, 1);
    spawnTime = GameObject.shared.time;
    var radius = sizeStart + p * sizeEnd;
    var size = Vector2(x: radius, y: radius);
    renderer = ShapeMaker(
      type: ShapeType.Circle,
      physicsProperties: physicsProperties,
      enablePhysics: true,
      position: pos,
      size: size,
      radius: radius,
      startAlive: true,
    );
    destroyCallback = destroyCallback;
  }

  update(Canvas canvas, {double elapsedTime = 0, double timestamp = 0.0, bool shouldUpdate = true}) {
    var p = min((GameObject.shared.time - spawnTime) / lifetime, 1);
    var radius = sizeStart + p * sizeEnd;
    var size = Vector2(x: radius, y: radius);
    var fadeRate = this.fadeRate / 2;
    var color = Color.fromRGBO(
        (colorStart.red + p * colorEnd.red).toInt(),
        (colorStart.green + p * colorEnd.green).toInt(),
        (colorStart.blue + p * colorEnd.blue).toInt(),
        (colorStart.alpha + p * colorEnd.alpha) *
            (p < fadeRate
                ? p / fadeRate
                : p > 1 - fadeRate
                    ? (1 - p) / fadeRate
                    : 1)); // fade alpha

    final paint = Paint()
      ..color = color
      ..blendMode = ui.BlendMode.src
      ..style = PaintingStyle.fill;

    if (p == 1) {
      destroy();
    }
  }

  destroy() {
    print("destroyed");
    if (destroyCallback != null) {
      destroyCallback!(id);
    }
    alive = false;
    destroyed = true;
  }
}
