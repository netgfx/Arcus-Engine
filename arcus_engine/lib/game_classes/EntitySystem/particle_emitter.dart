import 'dart:math';

import 'package:arcus_engine/game_classes/EntitySystem/vector_little.dart';
import 'package:flutter/rendering.dart';

class ParticleEmitter {
  Vector2 pos = Vector2(x: 0, y: 0);
  double angle = 0;
  double emitSize = 0;
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

  ParticleEmitter(
      {required this.pos,
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
      renderOrder}) {
    angle = angle ?? 0;
    emitSize = emitSize ?? 0;
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
  }
}
