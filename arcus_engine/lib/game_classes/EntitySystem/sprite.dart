import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arcus_engine/game_classes/EntitySystem/world.dart';
import 'package:arcus_engine/game_classes/EntitySystem/physics_body_simple.dart';
import 'package:arcus_engine/game_classes/EntitySystem/sprite_archetype.dart';
import 'package:arcus_engine/game_classes/EntitySystem/vector_little.dart';
import 'package:arcus_engine/helpers/GameObject.dart';
import 'package:arcus_engine/helpers/sprite_cache.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;
import "package:bezier/bezier.dart";
import "../../helpers/utils.dart";
import "../../helpers/Rectangle.dart";
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';

class Sprite with SpriteArchetype {
  double scale = 1.0;
  String _id = "";
  ui.Image? texture;
  Size size = Size(0, 0);
  int textureWidth = 0;
  int textureHeight = 0;
  TDWorld? world = GameObject.shared.getWorld();
  String textureName = "";
  double _angle = 0;
  Canvas? canvas;
  bool _alive = false;
  bool? startAlive = false;
  bool? _fitParent = true;
  Offset _centerOffset = Offset(0, 0);
  Function? _onCollide = null;
  PhysicsBodyProperties physicsBodyProperties = PhysicsBodyProperties();

  ///
  Sprite({
    required this.textureName,
    position,
    this.startAlive,
    interactive,
    onEvent,
    scale,
    id,
    fitParent,
    centerOffset,
    zIndex,
    enablePhysics,
    physicsProperties,
    onCollide,
  }) {
    this.position = position ?? Point(0.0, 0.0);
    _centerOffset = centerOffset ?? Offset(0, 0);
    this.interactive = interactive ?? false;
    this.onEvent = onEvent ?? null;
    this.scale = scale ?? 1.0;
    this.id = id ?? UniqueKey().toString();
    this.zIndex = zIndex ?? 0;
    this.physicsBodyProperties = physicsProperties ?? PhysicsBodyProperties();
    if (startAlive == true) {
      alive = true;
    }
    _fitParent = fitParent ?? true;
    this.enablePhysics = enablePhysics ?? false;
    if (this.enablePhysics == true) {
      setupPhysicsBody();
      _onCollide = onCollide ?? () {};
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

  Size getSize() {
    return size;
  }

  String get id {
    return _id;
  }

  set id(String value) {
    _id = value;
  }

  void setSize() {
    ui.Image img = texture!;
    double aspectRatio = img.width / img.height;
    int height = (img.height * scale).round();
    int width = (height * aspectRatio).round();
    size = Size(width.toDouble(), height.toDouble());
  }

  @override
  void update(Canvas canvas,
      {double elapsedTime = 0, bool shouldUpdate = true}) {
    if (texture == null) {
      setCache();
    }

    /// Physics
    if (enablePhysics == true && physicsBody == null) {
      setupPhysicsBody();
    }
    if (physicsBody != null) {
      physicsBody!
          .update(canvas, elapsedTime: elapsedTime, shouldUpdate: shouldUpdate);

      /// apply the physics pos to the actual object
      position = Point(physicsBody!.pos.x, physicsBody!.pos.y);
    }
    if (texture != null) {
      drawSprite(canvas);
    }
  }

  void drawSprite(Canvas canvas) {
    var paint = new Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = false;

    if (_fitParent == true) {
      Size fitSize = Size(size.width, size.height);

      updateCanvas(canvas, position.x, position.y, scale, () {
        if (GameObject.shared.world != null) {
          Size bounds = GameObject.shared.getWorld()!.worldBounds;
          final FittedSizes sizes = applyBoxFit(BoxFit.cover, size, bounds);
          final Rect inputSubrect =
              Alignment.center.inscribe(sizes.source, Offset.zero & size);
          final Rect outputSubrect = Alignment.center
              .inscribe(sizes.destination, Offset.zero & bounds);
          canvas.drawImageRect(texture!, inputSubrect, outputSubrect, paint);
        }
      });
    } else {
      Point<double> pos = Point(
        position.x - textureWidth.toDouble() * scale * _centerOffset.dx,
        position.y - textureHeight.toDouble() * scale * _centerOffset.dy,
      );
      renderSprite(canvas, pos, paint);
    }
  }

  void renderSprite(Canvas canvas, Point<double> pos, Paint paint) {
    updateCanvas(canvas, position.x, position.y, scale, () {
      canvas.drawImageRect(
        texture!,
        Rect.fromLTWH(0, 0, textureWidth.toDouble(), textureHeight.toDouble()),
        Rect.fromLTWH(
          0,
          0,
          textureWidth.toDouble(),
          textureHeight.toDouble(),
        ),
        paint,
      );
    }, translate: false);
  }

  void setCache() {
    Map<String, dynamic>? cacheItem =
        GameObject.shared.getSpriteCache().getItem(textureName);
    if (cacheItem != null) {
      texture = cacheItem["texture"];
      textureWidth = cacheItem["textureWidth"];
      textureHeight = cacheItem["textureHeight"];
      if (texture != null) {
        setSize();
      }
    }
  }

  Rectangle getRect() {
    Size _size = getSize();
    return Rectangle(
        x: position.x, y: position.y, width: _size.width, height: _size.height);
  }

  Rectangle getBounds() {
    Size _size = getSize();
    return Rectangle(
        x: position.x, y: position.y, width: _size.width, height: _size.height);
  }

  ui.Image? get textureImage {
    return texture;
  }

  double get angle {
    return _angle;
  }

  set angle(double value) {
    _angle = value;
  }

  bool get alive {
    return _alive;
  }

  set alive(bool value) {
    _alive = value;
  }

  Point<double> get center {
    Size size = getSize();

    return Point(position.x + size.width * 0.5, position.y + size.height * 0.5);
  }

  Point<double> getPosition() {
    return position;
  }

  @override
  bool onCollide(item) {
    /// run our own collide fn
    if (_onCollide != null) {
      _onCollide!(item);
    }
    return super.onCollide(item);
  }
}
