import 'dart:math';

import 'package:arcus_engine/game_classes/EntitySystem/particle.dart';
import 'package:arcus_engine/game_classes/EntitySystem/physics_body_simple.dart';
import 'package:arcus_engine/game_classes/EntitySystem/vector_little.dart';
import 'package:arcus_engine/helpers/GameObject.dart';
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

  ParticleEmitter({
    required this.pos,
    angle,
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
    angle = angle ?? 0;
    emitSize = emitSize ?? Vector2(x: 0, y: 0);
    emitTime = emitTime ?? 0;
    emitRate = emitRate ?? 100;
    emitConeAngle = emitConeAngle ?? pi;
    startColor = startColor ?? Color(0x000);
    endColor = endColor ?? Color(0xfff);
    particleTime = particleTime ?? 0.5;
    sizeStart = sizeStart ?? 0.1;
    sizeEnd = sizeEnd ?? 1.0;
    speed = speed ?? 0.1;
    angleSpeed = angleSpeed ?? 0.5;
    damping = damping ?? 1;
    angleDamping = angleDamping ?? 1;
    gravityScale = gravityScale ?? 0;
    particleConeAngle = particleConeAngle ?? pi;
    fadeRate = fadeRate ?? 0.1;
    randomness = randomness ?? 0.2;
    collideTiles = collideTiles ?? false;
    additive = additive ?? false;
    randomColorLinear = randomColorLinear ?? true;
    renderOrder = renderOrder ?? 0;
    alive = startAlive ?? false;

    ///
    spawnTime = GameObject.shared.time;
    children = [];
    collideTiles = true;
  }

  update(Canvas canvas, {double elapsedTime = 0, double timestamp = 0.0, bool shouldUpdate = true}) {
    if (emitTime == 0 || getAliveTime() <= emitTime) {
      // emit particles
      if (emitRate * particleEmitRateScale != 0) {
        var rate = 1 / emitRate / particleEmitRateScale;
        for (emitTimeBuffer += GameObject.shared.timeDelta; emitTimeBuffer > 0; emitTimeBuffer -= rate) {
          emitParticle();
        }
      }
    } else {
      destroy();
    }
  }

  getAliveTime() {
    return GameObject.shared.time - spawnTime;
  }

  destroy() {
    alive = false;
    destroyed = true;
    print("destroyed emitter");
  }

  emitParticle() {
    print("emitting particle");
    var pos = (Vector2(x: Utils.shared.rand(a: -.5, b: .5), y: Utils.shared.rand(a: -.5, b: .5))).multiply(emitSize).rotate(angle); // box emitter
    //Utils.shared.randInCircle(radius: emitSize.x * .5);

    // randomness scales each paremeter by a percentage
    var randomness = this.randomness;
    randomizeScale(v) {
      return v + v * Utils.shared.rand(a: randomness, b: -randomness);
    }

    // randomize particle settings
    var particleTime = randomizeScale(this.particleTime);
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
        angle: angle + Utils.shared.rand(a: particleConeAngle, b: -particleConeAngle),
        physicsProperties: PhysicsBodyProperties(
          velocity: (Vector2(x: 0, y: 0)).setAngle(angle + coneAngle, a: speed),
          friction: 0.8,
          damping: damping,
          angleDamping: angleDamping,
          gravityScale: gravityScale,
          collideOnWorldBounds: true,
          collideSolidObjects: true,
          renderOrder: renderOrder,
          angleVelocity: angleSpeed,
          mass: 1,
          restitution: 0.86,
        ),
        lifetime: particleTime,
        sizeStart: sizeStart,
        sizeEnd: sizeEnd - sizeStart,
        fadeRate: fadeRate,
        colorStart: colorStart,
        colorEnd: colorEnd.subtract(colorStart),
        destroyCallback: onParticleDestroy);

    return particle;
  }

  onParticleDestroy(id) {
    print("particle destroyed $id");
  }
}
