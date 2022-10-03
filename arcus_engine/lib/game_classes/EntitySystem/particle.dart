import 'dart:async';
import 'dart:math';

import 'package:arcus_engine/game_classes/EntitySystem/particle_emitter.dart';
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
  Color colorStart = Color.fromRGBO(0, 0, 0, 1);
  Color colorEnd = Color.fromRGBO(255, 255, 255, 1);
  double scale = 0.0;
  double lifetime = 1.0;
  bool _alive = true;
  Function? destroyCallback = null;
  double sizeStart = 0;
  double sizeEnd = 0;
  double fadeRate = 1.0;
  bool destroyed = false;
  int zIndex = 99;
  PhysicsBodySimple? physicsBody;
  bool enablePhysics = false;
  double spawnTime = GameObject.shared.time;
  late ShapeMaker renderer;
  TDWorld? world;
  bool interactive = false;
  ShapeType shape = ShapeType.Circle;
  var paint = Paint();
  bool debug = false;
  ParticleEmitter parent;
  double p = 0.0;

  Particle({
    required this.pos,
    required this.parent,
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
    this.destroyCallback,
  }) {
    this.angle = angle ?? 0;
    this.colorStart = colorStart ?? Color.fromRGBO(0, 0, 0, 1);
    this.colorEnd = colorEnd ?? Color.fromRGBO(255, 255, 255, 1);
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
    spawnTime = GameObject.shared.time;
    p = min((GameObject.shared.time - spawnTime) / lifetime, 1);

    var radius = sizeStart + p * sizeEnd;
    var size = Vector2(x: radius, y: radius);
    _alive = startAlive ?? false;
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
  }

  init() {
    if (destroyed == true) {
      return;
    }
    p = min((GameObject.shared.time - spawnTime) / lifetime, 1);
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
      batchDraw: true,
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
    //print("$alive, $p");

    if (shouldUpdate == true) {
      p = min((GameObject.shared.time - spawnTime) / lifetime, 1);
    }

    var radius = sizeStart + p * sizeEnd;
    var size = Vector2(x: radius, y: radius);
    var _fadeRate = fadeRate / 2;
    Color color = Color.fromRGBO(
        (colorStart.red + p * colorEnd.red).toInt(),
        (colorStart.green + p * colorEnd.green).toInt(),
        (colorStart.blue + p * colorEnd.blue).toInt(),
        (colorStart.opacity + p * colorEnd.opacity) *
            (p < _fadeRate
                ? p / _fadeRate
                : p > 1 - _fadeRate
                    ? (1 - p) / _fadeRate
                    : 1)); // fade alpha

    paint
      ..color = color
      //..blendMode = ui.BlendMode.src
      ..style = PaintingStyle.fill;
    renderer.paint = paint;
    renderer.update(canvas, elapsedTime: elapsedTime, timestamp: timestamp, shouldUpdate: shouldUpdate);

    if (p >= 1) {
      destroy();
      //return;
    }
  }

  destroy() {
    //print("destroyed");
    alive = false;
    var timer;
    if (parent.destroyed) {
      var world = GameObject.shared.getWorld();
      if (world != null) {
        print("P is: ${p}");
        timer = Timer(
            Duration(milliseconds: 2000),
            () => {
                  // print(">>>>> $id"),
                  debug = true,
                  alive = false,
                  //TODO: destroy them
                  //destroyed = true,
                  renderer.alive = false,
                  timer.cancel(),
                });

        //world.remove(this, null);
      }
    }

    if (destroyCallback != null) {
      destroyCallback!(id);
    }
  }

  bool get alive {
    return _alive;
  }

  set alive(bool value) {
    _alive = value;
  }
}
