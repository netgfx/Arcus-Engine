import 'dart:math';
import 'dart:ui';
import 'dart:math' as math;
import 'package:arcus_engine/game_classes/EntitySystem/sprite_tile.dart';
import 'package:arcus_engine/helpers/game_object.dart';
import 'package:arcus_engine/helpers/vector_little.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;
import 'package:tiled/tiled.dart';

class TileObject {
  String layerName = "";
  int textureId = 0;
  Vector2 texturePos = Vector2(x: 0, y: 0);
  Vector2 position = Vector2(x: 0, y: 0);
  int blockSize = 0;

  TileObject({
    required this.layerName,
    required this.textureId,
    required this.texturePos,
    required this.position,
    required this.blockSize,
  });
}

class TilemapController {
  String id = UniqueKey().toString();
  Vector2 position = Vector2(x: 0, y: 0);
  double scale = 1.0;
  String cacheKey = "";
  ui.Image? texture;
  TiledMap? tileData;
  Function onEvent = () => {};
  int zIndex = 1;
  bool _alive = false;
  bool tilesAlive = false;
  bool _interactive = false;
  List<TileObject> tiles = [];
  Map<String, dynamic>? cacheData;
  List<SpriteTile> children = [];

  TilemapController({
    required this.position,
    required this.cacheKey,
    scale,
    startAlive,
    interactive,
    onEvent,
    zIndex,
  }) {
    this.scale = scale ?? 1.0;
    tilesAlive = startAlive ?? false;
    this.zIndex = zIndex ?? 1;
    this.onEvent = onEvent ?? () => {};
    _interactive = interactive ?? false;
    _alive = startAlive ?? false;
    setCache();
  }

  void update(
    Canvas canvas, {
    double elapsedTime = 0.0,
    double timestamp = 0.0,
    bool shouldUpdate = true,
  }) {
    if (cacheData == null) {
      setCache();
    }

    if (tiles.isEmpty) {
      parseTileData();
    } else {
      if (children.isNotEmpty) {
        var totalLength = children.length;
        //for (var i = 0; i < totalLength; i++) {
        SpriteTile tile = children[0];
        tile.update(canvas, elapsedTime: elapsedTime, timestamp: timestamp, shouldUpdate: shouldUpdate);
        //}
      }
    }

    /// make the tiles
  }

  void parseTileData() {
    if (cacheData != null) {
      if (cacheData!.isNotEmpty) {
        int blockSize = cacheData!["tileData"]["tilemap"]["tilewidth"];

        int columns = cacheData!["tileData"]["tilemap"]["width"];
        int rows = cacheData!["tileData"]["tilemap"]["height"];

        /// GUARD FIX - possibly only needed for web
        int gapsCount = (cacheData!["textureWidth"] / blockSize).ceil();
        if (gapsCount / blockSize >= 1) {
          gapsCount -= 1;
        }
        int spacesCount = (cacheData!["textureHeight"] / blockSize).ceil();
        if (spacesCount / blockSize >= 1) {
          spacesCount -= 1;
        }
        int realWidth = cacheData!["textureWidth"] - gapsCount;
        int realHeight = cacheData!["textureHeight"] - spacesCount;

        /// TODO: remove this when drawAtlas works correctly
        int textureColumns = (realWidth / blockSize).round();
        int textureRows = (realHeight / blockSize).round();
        int counter = 0;
        int totalLayers = cacheData!["tileData"]["tilemap"]["layers"].length;

        for (var l = 0; l < totalLayers; l++) {
          for (var i = 0; i < rows; i++) {
            for (var j = 0; j < columns; j++) {
              var texturePos = cacheData!["tileData"]["tilemap"]["layers"][l][counter] - 6;
              String layerName = "layer$l";
              if (texturePos < 0) {
                counter += 1;
                continue;
              }

              /// if not 0
              var textureCoords = Vector2(x: 0, y: 0);
              double ratio = textureColumns / textureRows;
              double posY = max(((texturePos / textureColumns).ceil() - 1), 0); //((texturePos + 1) % textureRows) - 1;
              double posX = ((texturePos) % textureColumns);

              //print("$posY, $posX");

              tiles.add(TileObject(
                layerName: layerName,
                textureId: texturePos,
                blockSize: blockSize,
                texturePos: Vector2(x: posX, y: posY),
                position: Vector2(x: j * blockSize, y: i * blockSize + 100),
              ));

              counter += 1;
            }
          }
        }
        //print(tiles);
        //for (var tile in tiles) {
        children.add(SpriteTile(
          tiles: tiles,
          tileSize: blockSize,
          scale: 4,
          textureName: cacheKey,
          pixelGraphics: true,
          //position: math.Point<double>(tile.position.x.toDouble(), tile.position.y.toDouble()),
          startAlive: true,
          interactive: false,
          enablePhysics: false,
          centerOffset: const Offset(0, 0),
        ));
        //}
      }
    }
  }

  void setCache() {
    Map<String, dynamic>? cacheItem = GameObject.shared.getSpriteCache().getItem(cacheKey);
    if (cacheItem != null) {
      cacheData = cacheItem;
    }
  }

  bool get alive {
    return _alive;
  }

  set alive(bool value) {
    _alive = value;
  }

  bool get interactive {
    return _interactive;
  }

  void set interactive(bool value) {
    this._interactive = value;
  }
}
