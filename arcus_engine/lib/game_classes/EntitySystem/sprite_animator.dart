import 'dart:convert';
import 'dart:math';

import 'package:arcus_engine/game_classes/EntitySystem/physics_body_simple.dart';
import 'package:arcus_engine/game_classes/EntitySystem/vector_little.dart';
import 'package:arcus_engine/game_classes/EntitySystem/world.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:arcus_engine/game_classes/EntitySystem/sprite_archetype.dart';
import 'package:arcus_engine/helpers/GameObject.dart';
import 'package:arcus_engine/helpers/action_manager.dart';
import 'package:arcus_engine/helpers/sprite_cache.dart';
import 'package:arcus_engine/helpers/utils.dart';

enum RepeatMode {
  Single,
  Repeat,
}

class SpriteAnimator with SpriteArchetype {
  int currentTime = 0;
  late ui.Image currentImage;
  String currentFrame = "";
  Map<String, List<Map<String, dynamic>>> spriteData = {};
  List<String> delimiters = [];
  double? fps = 250;
  RepeatMode loop;
  int currentIndex = 0;
  int textureWidth = 0;
  int textureHeight = 0;
  Paint _paint = new Paint();
  TDWorld? world = GameObject.shared.getWorld();
  bool? startAlive = false;
  int timeDecay = 0;
  Offset _centerOffset = Offset(0, 0);
  Function? _onCollide;

  // constructor
  SpriteAnimator({
    required textureName,
    required this.currentFrame,
    required this.loop,
    position,
    this.fps,
    this.startAlive,
    scale,
    zIndex,
    interactive,
    onEvent,
    id,
    centerOffset,
    enablePhysics,
    physicsProperties,
    onCollide,
  }) {
    this.position = position ?? Point(0.0, 0.0);
    this._centerOffset = centerOffset ?? Offset(0, 0);
    this.textureName = textureName;
    this.zIndex = zIndex ?? 0;
    this.interactive = interactive;
    this.onEvent = onEvent;
    this.timeDecay = (1 / (this.fps ?? 60) * 1000).round();
    this.scale = scale ?? 1.0;
    this.id = id ?? UniqueKey().toString();
    super.physicsBodyProperties = physicsProperties ?? PhysicsBodyProperties();
    if (startAlive == true) {
      alive = true;
    }
    this.enablePhysics = enablePhysics ?? false;
    if (this.enablePhysics == true) {
      setupPhysicsBody();
      _onCollide = onCollide;
    }
  }

  @override
  void update(
    Canvas canvas, {
    double elapsedTime = 0.0,
    double timestamp = 0.0,
    bool shouldUpdate = true,
  }) {
    if (alive == true) {
      if (this.texture == null) {
        setCache();
      }
      var img = spriteData[currentFrame]![currentIndex];
      Point<double> pos =
          Point(position.x - img["width"].toDouble() * scale * _centerOffset.dx, position.y - img["height"].toDouble() * scale * _centerOffset.dy);

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

      /// this component needs its own tick
      if (elapsedTime - this.currentTime >= timeDecay) {
        /// reset the time
        this.currentTime = elapsedTime.round();

        renderSprite(canvas, pos, img);

        if (shouldUpdate) {
          currentIndex++;
        }

        if (currentIndex >= spriteData[currentFrame]!.length) {
          if (this.loop == RepeatMode.Single) {
            this.alive = false;
          }
          currentIndex = 0;
        }
      } else {
        renderSprite(canvas, pos, img);
      }
    }
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
        physicsProperties: this.physicsBodyProperties,
        onCollision: onCollide,
      );
    }
  }

  void renderSprite(Canvas canvas, Point<double> pos, Map<String, dynamic> img) {
    updateCanvas(canvas, pos.x, pos.y, scale, () {
      canvas.drawImageRect(
        this.texture!,
        Rect.fromLTWH(img["x"].toDouble(), img["y"].toDouble(), img["width"].toDouble(), img["height"].toDouble()),
        Rect.fromLTWH(
          0,
          0,
          img["width"].toDouble(),
          img["height"].toDouble(),
        ),
        _paint,
      );
    }, translate: false);
  }

  void setCache() {
    Map<String, dynamic>? cacheItem = GameObject.shared.getSpriteCache().getItem(textureName);
    if (cacheItem != null) {
      this.texture = cacheItem["texture"];
      this.spriteData = cacheItem["spriteData"];
      var img = spriteData[currentFrame]![currentIndex];
      this.size = Size(img["width"].toDouble() * this.scale, img["height"].toDouble() * this.scale);
      print(this.size);
    }
  }

  setPosition(Point<double> value) {
    this.position = value;
  }

  Point<double> getPosition({bool centerPoint = false}) {
    var img = spriteData[currentFrame]![currentIndex];
    Point<double> pos = const Point(0, 0);
    if (centerPoint == true) {
      pos = Point(position.x - img["width"].toDouble() * scale / 2, position.y - img["height"].toDouble() * scale / 2);
    } else {
      pos = position;
    }

    return pos;
  }

  dynamic getProperty(String type) {
    switch (type) {
      case "scale":
        {
          return this.scale;
        }

      case "x":
        {
          return this.position.x;
        }

      case "y":
        {
          return this.position.y;
        }
    }
  }

  void setProperty(String type, dynamic value) {
    switch (type) {
      case "scale":
        {
          this.scale = value;
          break;
        }
      case "x":
        {
          this.position = Point(value, this.position.y);
          break;
        }

      case "y":
        {
          this.position = Point(this.position.x, value);
          break;
        }
    }
  }
}
