import 'package:arcus_engine/game_classes/EntitySystem/world.dart';
import 'dart:ui' as ui;

import 'package:arcus_engine/helpers/math/CubicBezier.dart';
import 'package:arcus_engine/helpers/sprite_cache.dart';

class GameObject {
  static GameObject shared = GameObject._();
  GameObject._();

  static GameObject get instance => shared;

  ///
  TDWorld? world = null;
  double time = 0;
  int frameRate = 60;
  double timeDelta = 1 / 60;
  List<CubicBezier> cubicBeziers = [];
  Map<String, ui.Image> imageCache = {};
  SpriteCache spriteCache = SpriteCache();

  ///

  setWorld(TDWorld value) {
    this.world = value;
  }

  TDWorld? getWorld() {
    return this.world;
  }

  setSpriteCache(SpriteCache value) {
    this.spriteCache = value;
  }

  SpriteCache getSpriteCache() {
    return this.spriteCache;
  }

  void setCubicBeziers(List<CubicBezier> value) {
    this.cubicBeziers = value;
  }

  List<CubicBezier> getCubicBeziers() {
    return this.cubicBeziers;
  }

  setCacheValue(String key, ui.Image value) {
    imageCache[key] = value;
  }

  ui.Image? getCacheValue(String key) {
    return imageCache[key];
  }
}
