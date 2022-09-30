import 'dart:math';

import 'package:arcus_engine/game_classes/EntitySystem/physics_body_simple.dart';
import 'package:arcus_engine/game_classes/EntitySystem/shape_maker.dart';
import 'package:arcus_engine/game_classes/EntitySystem/world.dart';
import 'package:arcus_engine/helpers/vector_little.dart';
import 'package:arcus_engine/helpers/game_object.dart';
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
  bool alive = true;
  Function? destroyCallback = null;
  double sizeStart = 0;
  double sizeEnd = 0;
  double fadeRate = 1.0;
  bool destroyed = false;
  int zIndex = 0;
  PhysicsBodySimple? physicsBody;
  bool enablePhysics = false;
  double spawnTime = GameObject.shared.time;
  late ShapeMaker renderer;
  TDWorld? world;
  bool interactive = false;
  ShapeType shape = ShapeType.Circle;
  var paint = Paint();
  Particle({
    required this.pos,
    shape,
    angle,
    enablePhysics,
    physicsProperties,
    colorStart,
    colorEnd,
    sizeStart,
    sizeEnd,
    lifetime,
    fadeRate,
    spawnTime,
    startAlive,
    destroyCallback,
  }) {
    this.angle = angle ?? 0;
    this.colorStart = colorStart ?? Color.fromRGBO(0, 0, 0, 1);
    this.colorEnd = colorEnd ?? Color.fromRGBO(0, 0, 0, 1);
    this.enablePhysics = enablePhysics ?? false;
    this.physicsProperties = physicsProperties ?? PhysicsBodyProperties();
    this.sizeStart = sizeStart ?? 0;
    this.sizeEnd = sizeEnd ?? 0;
    this.lifetime = lifetime ?? 1.0;
    this.fadeRate = fadeRate ?? 0.1;
    this.spawnTime = spawnTime ?? GameObject.shared.time;
    this.destroyCallback = destroyCallback;
    this.shape = shape ?? ShapeType.Circle;
    //print("${GameObject.shared.time}, $spawnTime, $lifetime");
    world = GameObject.shared.getWorld();
    var p = min((GameObject.shared.time - spawnTime) / lifetime, 1);
    spawnTime = GameObject.shared.time;
    var radius = sizeStart + p * sizeEnd;
    var size = Vector2(x: radius, y: radius);
    alive = startAlive ?? false;
    renderer = ShapeMaker(
      type: shape,
      physicsProperties: physicsProperties,
      enablePhysics: this.enablePhysics,
      position: Point<double>(pos.x, pos.y),
      size: Size(size.x, size.y),
      radius: radius,
      startAlive: true,
      batchDraw: true,
    );
    physicsBody = renderer.physicsBody;
    this.destroyCallback = destroyCallback;
  }

  init() {
    var p = min((GameObject.shared.time - spawnTime) / lifetime, 1);
    spawnTime = GameObject.shared.time;
    var radius = sizeStart + p * sizeEnd;
    var size = Vector2(x: radius, y: radius);
    renderer = ShapeMaker(
      type: shape,
      physicsProperties: physicsProperties,
      enablePhysics: enablePhysics,
      position: Point<double>(pos.x, pos.y),
      size: Size(size.x, size.y),
      radius: radius,
      startAlive: true,
      batchDraw: false,
    );
    physicsBody = renderer.physicsBody;
    alive = true;

    var world = GameObject.shared.getWorld();
    if (world != null) {
      if (world.getObjectById(id).isEmpty) {
        world.add(this, null);
      }
    }
  }

  update(Canvas canvas, {double elapsedTime = 0, double timestamp = 0.0, bool shouldUpdate = true}) {
    if (shouldUpdate == false) {
      renderer.update(canvas, elapsedTime: elapsedTime, timestamp: timestamp, shouldUpdate: shouldUpdate);
      return;
    }

    var p = min((GameObject.shared.time - spawnTime) / lifetime, 1);

    ///physicsBody = renderer.physicsBody;
    if (p == 1) {
      destroy();
    }

    var radius = sizeStart + p * sizeEnd;
    var size = Vector2(x: radius, y: radius);
    var fadeRate = this.fadeRate / 2;
    Color color = Color.fromRGBO(
        (colorStart.red + p * colorEnd.red).toInt(),
        (colorStart.green + p * colorEnd.green).toInt(),
        (colorStart.blue + p * colorEnd.blue).toInt(),
        (colorStart.opacity + p * colorEnd.opacity) *
            (p < fadeRate
                ? p / fadeRate
                : p > 1 - fadeRate
                    ? (1 - p) / fadeRate
                    : 1)); // fade alpha

    paint
      ..color = color
      //..blendMode = ui.BlendMode.src
      ..style = PaintingStyle.fill;

    renderer.paint = paint;
    renderer.update(canvas, elapsedTime: elapsedTime, timestamp: timestamp, shouldUpdate: shouldUpdate);
  }

  destroy() {
    //print("destroyed");
    alive = false;
    destroyed = true;

    if (destroyCallback != null) {
      destroyCallback!(id);
    }

    if (world != null) {
      //world!.remove(this, null);
    }
  }
}
