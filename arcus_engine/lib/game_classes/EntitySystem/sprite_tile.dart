import 'dart:math';
import 'dart:ui';
import 'package:arcus_engine/game_classes/EntitySystem/physics_body_simple.dart';
import 'package:arcus_engine/game_classes/EntitySystem/world.dart';
import 'package:arcus_engine/helpers/game_object.dart';
import 'package:arcus_engine/helpers/vector_little.dart';
import 'package:flutter/widgets.dart';

import '../../helpers/rectangle.dart';
import 'dart:ui' as ui;
import 'package:arcus_engine/game_classes/EntitySystem/sprite_archetype.dart';

class SpriteTile with SpriteArchetype {
  String _id = "";
  int textureWidth = 0;
  int textureHeight = 0;
  TDWorld? world = GameObject.shared.getWorld();
  double _angle = 0;
  bool _alive = false;
  Offset _centerOffset = const Offset(0, 0);
  Function? _onCollide;
  Vector2 clipCoordinates = Vector2(x: 0, y: 0);

  ///
  SpriteTile({
    required this.clipCoordinates,
    textureName,
    position,
    startAlive,
    interactive,
    onEvent,
    scale,
    id,
    centerOffset,
    zIndex,
    enablePhysics,
    physicsProperties,
    onCollide,
  }) {
    this.textureName = textureName ?? "";
    this.position = position ?? const Point(0.0, 0.0);
    _centerOffset = centerOffset ?? const Offset(0, 0);
    this.interactive = interactive ?? false;
    this.onEvent = onEvent;
    this.scale = scale ?? 1.0;
    this.id = id ?? UniqueKey().toString();
    this.zIndex = zIndex ?? 0;
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

  @override
  String get id {
    return _id;
  }

  @override
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
  void update(
    Canvas canvas, {
    double elapsedTime = 0,
    double timestamp = 0.0,
    bool shouldUpdate = true,
  }) {
    if (texture == null) {
      setCache();
    }

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
    if (texture != null) {
      drawSprite(canvas);
    }
  }

  void drawSprite(Canvas canvas) {
    var paint = new Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = false;

    /// get camera position
    Rect cameraPos = Rect.fromLTWH(0, 0, 0, 0);
    if (GameObject.shared.world != null) {
      cameraPos = GameObject.shared.world!.getCamera().getCameraBounds();
    }

    Point<double> pos = Point(
      position.x - textureWidth.toDouble() * scale * _centerOffset.dx,
      position.y - textureHeight.toDouble() * scale * _centerOffset.dy,
    );
    renderSprite(canvas, pos, cameraPos, paint);
  }

  void renderSprite(Canvas canvas, Point<double> pos, Rect cameraPos, Paint paint) {
    updateCanvas(canvas, pos.x + cameraPos.left * -1, pos.y + cameraPos.top * -1, scale, angle, () {
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
    }, translate: true);
  }

  void setCache() {
    Map<String, dynamic>? cacheItem = GameObject.shared.getSpriteCache().getItem(textureName);
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
    return Rectangle(x: position.x, y: position.y, width: _size.width, height: _size.height);
  }

  Rectangle getBounds() {
    Size _size = getSize();
    return Rectangle(x: position.x, y: position.y, width: _size.width, height: _size.height);
  }

  ui.Image? get textureImage {
    return texture;
  }

  @override
  double get angle {
    return _angle;
  }

  @override
  set angle(double value) {
    _angle = value;
  }

  @override
  bool get alive {
    return _alive;
  }

  @override
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
