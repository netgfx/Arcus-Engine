import 'dart:math';

import 'package:arcus_engine/game_classes/EntitySystem/particle.dart';
import 'package:arcus_engine/game_classes/EntitySystem/physics_body_simple.dart';
import 'package:arcus_engine/game_classes/EntitySystem/shape_maker.dart';
import 'package:arcus_engine/game_classes/EntitySystem/world.dart';
import 'package:arcus_engine/helpers/vector_little.dart';
import 'package:arcus_engine/helpers/game_object.dart';
import 'package:arcus_engine/helpers/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class ParticleEmitter {
  String id = UniqueKey().toString();
  Vector2 pos = Vector2(x: 0, y: 0);
  double angle = 0;
  Vector2 emitSize = Vector2(x: 0, y: 0);
  double emitTime = 0;
  int emitRate = 100;
  double emitConeAngle = pi;
  Color startColor = Color(0x000);
  Color endColor = Color(0xfff);
  double particleTime = 0.5;
  double sizeStart = 0.1;
  double sizeEnd = 1.0;
  double speed = 0.1;
  double angleSpeed = 0.5;
  int damping = 1;
  int angleDamping = 1;
  double gravityScale = 0;
  double particleConeAngle = pi;
  double fadeRate = 0.1;
  double randomness = 0.2;
  bool collideTiles = false;
  bool additive = false;
  bool randomColorLinear = true;
  int renderOrder = 0;
  List<dynamic> children = [];
  double spawnTime = 0;
  int particleEmitRateScale = 1;
  double emitTimeBuffer = 0;
  bool alive = false;
  bool destroyed = false;
  int zIndex = 99;
  bool interactive = false;
  ShapeType shape = ShapeType.Circle;
  TDWorld? world;
  int initialDelay = 1;
  PhysicsBodySimple? physicsBody;

  ParticleEmitter({
    required this.pos,
    angle,
    shape,
    emitSize,
    emitTime,
    emitRate,
    emitConeAngle,
    startColor,
    endColor,
    particleTime,
    sizeStart,
    sizeEnd,
    speed,
    angleSpeed,
    damping,
    angleDamping,
    gravityScale,
    particleConeAngle,
    fadeRate,
    randomness,
    collideTiles,
    additive,
    randomColorLinear,
    renderOrder,
    startAlive,
  }) {
    this.angle = angle ?? 0;
    this.shape = shape ?? ShapeType.Circle;
    this.emitSize = emitSize ?? Vector2(x: 0, y: 0);
    this.emitTime = emitTime ?? 0.5;
    this.emitRate = emitRate ?? 100;
    this.emitConeAngle = emitConeAngle ?? pi;
    this.startColor = startColor ?? Color(0x000);
    this.endColor = endColor ?? Color(0xfff);
    this.particleTime = particleTime ?? 0.5;
    this.sizeStart = sizeStart ?? 1.0;
    this.sizeEnd = sizeEnd ?? 1.0;
    this.speed = speed ?? 0.1;
    this.angleSpeed = angleSpeed ?? 0.5;
    this.damping = damping ?? 1;
    this.angleDamping = angleDamping ?? 1;
    this.gravityScale = gravityScale ?? 0;
    this.particleConeAngle = particleConeAngle ?? pi;
    this.fadeRate = fadeRate ?? 0.1;
    this.randomness = randomness ?? 0.2;
    this.collideTiles = collideTiles ?? false;
    this.additive = additive ?? false;
    this.randomColorLinear = randomColorLinear ?? true;
    this.renderOrder = renderOrder ?? 0;
    alive = startAlive ?? false;

    world = GameObject.shared.getWorld();

    ///
    spawnTime = GameObject.shared.time;
    children = [];
    collideTiles = true;

    /// make particles
    var particle;
    for (var i = 0; i < 100; i++) {
      particle = createParticle();

      children.add(particle);
    }
  }

  update(Canvas canvas, {double elapsedTime = 0, double timestamp = 0.0, bool shouldUpdate = true}) {
    if (GameObject.shared.time > initialDelay) {
      if (getAliveTime() <= emitTime) {
        // emit particles

        if (emitRate * particleEmitRateScale != 0) {
          var rate = (1 / emitRate) / particleEmitRateScale;

          for (emitTimeBuffer += GameObject.shared.timeDelta; emitTimeBuffer > 0; emitTimeBuffer -= rate) {
            emitParticle();
          }
        }
      } else {
        destroy();
      }
    }
    // } else {
    //   if (getAliveTime() <= emitTime) {
    //     spawnTime = GameObject.shared.time;
    //   } else {
    //     destroy();
    //   }
    //   //print(GameObject.shared.time);
    // }
  }

  getAliveTime() {
    var _timeElapsed = GameObject.shared.time - (spawnTime + initialDelay);
    return _timeElapsed;
  }

  destroy() {
    alive = false;
    destroyed = true;
    children.clear();
    print("destroyed emitter");
  }

  emitParticle() {
    if (alive == true) {
      var result = children.where((element) => element.alive == false && element.destroyed == false);
      if (result.isNotEmpty) {
        result.first.init();
      }
    }
  }

  createParticle({bool immediateRender = false}) {
    var pos = (Vector2(x: Utils.shared.rand(a: -.5, b: .5), y: Utils.shared.rand(a: -.5, b: .5))).multiply(emitSize).rotate(angle); // box emitter
    //Utils.shared.randInCircle(radius: emitSize.x * .5);

    // randomness scales each paremeter by a percentage
    var randomness = this.randomness;
    double randomizeScale(v) {
      return v + v * Utils.shared.rand(a: randomness, b: -randomness);
    }

    // randomize particle settings
    var particleTime = max(randomizeScale(this.particleTime), this.particleTime);
    var sizeStart = randomizeScale(this.sizeStart);
    var sizeEnd = randomizeScale(this.sizeEnd);
    var speed = randomizeScale(this.speed);
    var angleSpeed = randomizeScale(this.angleSpeed) * Utils.shared.randSign();
    var coneAngle = Utils.shared.rand(a: this.emitConeAngle, b: -this.emitConeAngle);
    var colorStart = Utils.shared.randColor(randomColorLinear, cA: startColor, cB: startColor);
    var colorEnd = Utils.shared.randColor(randomColorLinear, cA: endColor, cB: endColor);

    // build particle settings

    var particle = Particle(
      pos: this.pos.add(pos),
      parent: this,
      shape: shape,
      spawnTime: GameObject.shared.time.toDouble(),
      angle: angle + Utils.shared.rand(a: particleConeAngle, b: -particleConeAngle),
      enablePhysics: true,
      physicsProperties: PhysicsBodyProperties(
        velocity: Vector2(x: 0, y: 0).setAngle(a: angle + coneAngle, length: speed),
        //.setAngle(angle + coneAngle, a: speed),
        friction: 0.8,
        damping: damping,
        angleDamping: angleDamping,
        gravityScale: gravityScale,
        collideOnWorldBounds: true,
        collideSolidObjects: false,
        renderOrder: renderOrder,
        angleVelocity: angleSpeed,
        mass: 1,
        immovable: false,
        restitution: 0.86,
      ),
      lifetime: particleTime,
      sizeStart: sizeStart,
      sizeEnd: sizeEnd - sizeStart,
      fadeRate: fadeRate,
      colorStart: colorStart,
      startAlive: immediateRender,
      colorEnd: Utils.shared.subtractColor(colorEnd, colorStart),
      //destroyCallback: onParticleDestroy,
    );

    return particle;
  }

  onParticleDestroy(id) {
    //children.removeWhere((element) => element.id == id);
    //print("particle destroyed $id");
  }
}
