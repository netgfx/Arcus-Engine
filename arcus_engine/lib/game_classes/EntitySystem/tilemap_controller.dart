import 'dart:ui';

import 'package:arcus_engine/game_classes/EntitySystem/sprite_tile.dart';
import 'package:arcus_engine/helpers/game_object.dart';
import 'package:arcus_engine/helpers/vector_little.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;
import 'package:tiled/tiled.dart';

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
  List<Map<String, dynamic>> tiles = [];
  Map<String, dynamic>? cacheData;

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

    if (tiles.length == 0) {
      parseTileData();
    }

    /// make the tiles
  }

  void parseTileData() {
    if (cacheData != null) {
      if (cacheData!.isNotEmpty) {
        int columns = cacheData!["tileData"]["width"];
        var rows = cacheData!["tileData"]["height"];
        int textureColumns = cacheData!["textureWidth"] / columns;
        int textureRows = cacheData!["textureHeight"] / rows;
        int counter = 0;
        for (var i = 0; i < rows; i++) {
          for (var j = 0; j < columns; j++) {
            var texturePos = cacheData!["tileData"]["layers"][counter];

            if (texturePos == 0) {
              counter += 1;
              continue;
            }

            /// if not 0
            var textureCoords = Vector2(x: 0, y: 0);
            double ratio = textureColumns / textureRows;
            double modY = (texturePos - 1) % textureRows;
            double posX1 = textureColumns.toDouble() * modY;
            double diff = (posX1 - texturePos).abs();
            double posX = (textureColumns - diff);
            print("$modY, $posX");
            counter += 1;
            tiles.add({"texturePos": Vector2(x: posX, y: modY)});
          }
        }
      }
    }
  }

  void setCache() {
    Map<String, dynamic>? cacheItem =
        GameObject.shared.getSpriteCache().getItem(cacheKey);
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
