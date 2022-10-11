import 'dart:math';
import 'dart:ui';
import 'package:arcus_engine/game_classes/EntitySystem/physics_body_simple.dart';
import 'package:arcus_engine/game_classes/EntitySystem/tilemap_controller.dart';
import 'package:arcus_engine/game_classes/EntitySystem/world.dart';
import 'package:arcus_engine/helpers/game_object.dart';
import 'package:arcus_engine/helpers/vector_little.dart';
import 'package:flutter/widgets.dart';

import '../../helpers/Rectangle.dart';
import 'dart:ui' as ui;
import 'package:arcus_engine/game_classes/EntitySystem/sprite_archetype.dart';

class SpriteTile with SpriteArchetype {
  String _id = "";
  int textureWidth = 0;
  int textureHeight = 0;
  TDWorld? world = GameObject.shared.getWorld();
  double _angle = 0;
  bool _alive = false;
  Paint _paint = Paint();
  Offset _centerOffset = const Offset(0, 0);
  Function? _onCollide;
  Vector2 clipCoordinates = Vector2(x: 0, y: 0);
  List<TileObject> tiles = [];
  int tileSize = 0;
  bool pixelGraphics = false;

  ///
  SpriteTile({
    required this.tiles,
    required this.tileSize,
    textureName,
    position,
    startAlive,
    interactive,
    onEvent,
    scale,
    id,
    centerOffset,
    zIndex,
    pixelGraphics,
    enablePhysics,
    physicsProperties,
    onCollide,
  }) {
    this.textureName = textureName ?? "";
    this.position = position ?? const Point(0.0, 0.0);
    _centerOffset = centerOffset ?? const Offset(0, 0);
    this.interactive = interactive ?? false;
    this.onEvent = onEvent;
    this.pixelGraphics = pixelGraphics ?? false;
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
      ..isAntiAlias = !pixelGraphics;

    /// get camera position
    Rect cameraPos = Rect.fromLTWH(0, 0, 0, 0);
    if (GameObject.shared.world != null) {
      cameraPos = GameObject.shared.world!.getCamera().getCameraBounds();
    }

    Point<double> pos = Point(
      position.x - tileSize.toDouble() * scale,
      position.y - tileSize.toDouble() * scale,
    );
    renderSprite(canvas, pos, cameraPos, paint);
  }

  void renderSprite(Canvas canvas, Point<double> pos, Rect cameraPos, Paint paint) {
    double posX = pos.x + cameraPos.left * -1;
    double posY = pos.y + cameraPos.top * -1;
    int totalLength = tiles.length;

    canvas.drawAtlas(
        texture!,
        <RSTransform>[
          for (TileObject sprite in tiles)
            RSTransform.fromComponents(
              rotation: 0.0,
              scale: scale,
              // Center of the sprite relative to its rect
              anchorX: 0.0,
              anchorY: 0.0,
              // Location at which to draw the center of the sprite
              translateX: sprite.position.x * scale,
              translateY: sprite.position.y * scale,
            ),
        ],
        <Rect>[
          for (TileObject sprite in tiles)
            Rect.fromLTWH(sprite.texturePos.x.toDouble() * tileSize, sprite.texturePos.y.toDouble() * tileSize, tileSize.toDouble(), tileSize.toDouble()),
        ],
        null,
        null,
        null,
        paint);

    // Rect dst = Rect.fromLTWH(
    //   posX * scale,
    //   posY * scale,
    //   tileSize.toDouble() * scale,
    //   tileSize.toDouble() * scale,
    // );
    // canvas.drawImageRect(
    //   this.texture!,
    //   Rect.fromLTWH(clipCoordinates.x.toDouble() * tileSize, clipCoordinates.y.toDouble() * tileSize, tileSize.toDouble(), tileSize.toDouble()),
    //   dst,
    //   _paint,
    // );
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

  @override
  void updateCanvas(Canvas canvas, double? x, double? y, double? scale, double? rotation, VoidCallback callback, {bool translate = false}) {
    double _x = x ?? 0;
    double _y = y ?? 0;
    canvas.save();

    if (translate) {
      canvas.translate(_x, _y);
    }

    if (scale != null) {
      canvas.translate(_x, _y);
      canvas.scale(scale);
      canvas.translate(-_x, -_y);
    }

    if (rotation != null) {
      canvas.translate(_x, _y);
      canvas.rotate(rotation);
    }

    callback();
    canvas.restore();
  }
}
