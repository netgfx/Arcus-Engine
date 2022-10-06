import 'dart:convert';
import 'dart:io';
import 'package:xml/xml.dart';
import 'package:async/async.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:arcus_engine/helpers/utils.dart';
import 'package:tiled/tiled.dart';

class SpriteCache {
  String textureLoadState = "none";
  final Map<String, dynamic> _cache = {};
  final FutureGroup _group = FutureGroup();
  // constructor
  SpriteCache() {}

  /**
   * Add item to the loader queue
   */
  void addItem(
    String key, {
    String? texturePath,
    String dataPath = "",
    List<String>? delimiters,
    String dataType = "",
  }) {
    _cache[key] = {
      "loadedState": "none",
      "texturePath": texturePath,
      "dataPath": dataPath,
      "dataType": dataType,
      "texture": null,
      "spriteData": null,
      "delimiters": delimiters,
    };
  }

  /**
   * Initiate the loading of the added sprites and textures
   * 
   * returns bool
   */
  Future<bool> loadItems() async {
    _cache.forEach((key, item) {
      if (item["loadedState"] == "none") {
        if (item["dataPath"] == null || item["dataPath"] == "") {
          // load static img
          _group.add(loadImage(key));
        } else {
          if (item["dataType"] == "" || item["dataType"].toLowerCase() == "json") {
            _group.add(loadSprite(key));
          } else if (item["dataType"].toLowerCase() == "xml") {
            _group.add(loadBitmapFont(key));
          } else if (item["dataType"].toLowerCase() == "tilemap") {
            _group.add(loadTilemap(key));
          }
        }
      }
    });

    _group.close();
    var val = await _group.future;

    return true;
  }

  /**
   * Load a sprite, texture first and then .json metadata
   */
  Future<void> loadSprite(String key) async {
    _cache[key]["loadedState"] = "loading";
    String texturePath = _cache[key]["texturePath"];
    String dataPath = _cache[key]["dataPath"];
    String? dataType = _cache[key]["dataType"];
    final ByteData data = await rootBundle.load(texturePath);
    _cache[key]["texture"] = await Utils.shared.imageFromBytes(data);

    if (dataPath != "") {
      var data = await loadJsonData(dataPath);
      _cache[key]["spriteData"] = parseJSON(key, data);

      _cache[key]["loadedState"] = "done";
    } else {
      _cache[key]["loadedState"] = "none";
    }
  }

  Future<void> loadBitmapFont(String key) async {
    _cache[key]["loadedState"] = "loading";
    String texturePath = _cache[key]["texturePath"];
    String dataPath = _cache[key]["dataPath"];
    final ByteData data = await rootBundle.load(texturePath);
    _cache[key]["texture"] = await Utils.shared.imageFromBytes(data);
    _cache[key]["textureWidth"] = _cache[key]["texture"]!.width;
    _cache[key]["textureHeight"] = _cache[key]["texture"]!.height;
    if (dataPath != "") {
      var data = await loadXMLData(dataPath);
      _cache[key]["fntData"] = data;

      _cache[key]["loadedState"] = "done";
    } else {
      _cache[key]["loadedState"] = "none";
    }
  }

  Future<void> loadTilemap(String key) async {
    _cache[key]["loadedState"] = "loading";
    String texturePath = _cache[key]["texturePath"];
    String dataPath = _cache[key]["dataPath"];
    final ByteData data = await rootBundle.load(texturePath);
    _cache[key]["texture"] = await Utils.shared.imageFromBytes(data);
    _cache[key]["textureWidth"] = _cache[key]["texture"]!.width;
    _cache[key]["textureHeight"] = _cache[key]["texture"]!.height;
    if (dataPath != "") {
      var data = await loadTileXMLData(dataPath);
      _cache[key]["tileData"] = parseTiledJSON(key, data);

      _cache[key]["loadedState"] = "done";
    } else {
      _cache[key]["loadedState"] = "none";
    }
  }

  /**
   * Load the json metadata of the sprite atlas
   */
  Future<Map<String, dynamic>> loadJsonData(String path) async {
    var jsonText = await rootBundle.loadString(path);
    Map<String, dynamic> data = json.decode(jsonText);
    return data;
  }

  Future<XmlDocument> loadXMLData(String path) async {
    var xmlText = await rootBundle.loadString(path);
    final data = XmlDocument.parse(xmlText);

    return data;
  }

  /// TODO: add robust implementation
  Future<Map<String, dynamic>> loadTileXMLData(String path) async {
    var jsonText = await rootBundle.loadString(path);

    Map<String, dynamic> data = json.decode(jsonText);
    //final TiledMap data = TileMapParser.parseJson(xmlText);
    //.parseTmx(xmlText, [CustomTsxProvider()]);

    return data;
  }

  /**
   * Parse the json metadata into proper dictionary structure
   */
  Map<String, List<Map<String, dynamic>>> parseJSON(String key, Map<String, dynamic> data) {
    Map<String, List<Map<String, dynamic>>> sprites = {};
    List<String> delimiters = _cache[key]["delimiters"];
    for (var key in delimiters) {
      sprites[key] = [];
      data["frames"].forEach((innerKey, value) {
        final frameData = value['frame'];
        final int x = frameData['x'];
        final int y = frameData['y'];
        final int width = frameData['w'];
        final int height = frameData['h'];
        final int sourceWidth = value['sourceSize']['w'];
        final int sourceHeight = value['sourceSize']['h'];
        if ((innerKey as String).contains(key) == true) {
          sprites[key]!.add({
            "x": x,
            "y": y,
            "width": width,
            "height": height,
            "sourceWidth": sourceWidth,
            "sourceHeight": sourceHeight,
          });
        }
      });
    }

    return sprites;
  }

  /**
   * Parse the json metadata into proper dictionary structure
   */
  Map<String, Map<String, dynamic>> parseTiledJSON(String key, Map<String, dynamic> data) {
    Map<String, Map<String, dynamic>> sprites = {};

    sprites[key] = {};
    data.forEach((innerKey, value) {
      // final int width = value['width'];
      // final int height = value['height'];
      // final List<int> layerData = value['layers']['data'];
      // final int tileWidth = value["tilewidth"];
      // final int tileHeight = value["tileheight"];
      // final String renderorder = value["renderorder"];

      /// we only support top-right for now
      if (innerKey == "layers") {
        List<dynamic> data = [];
        for (var i = 0; i < value.length; i++) {
          data.add(value[i]["data"]);
        }
        sprites[key]![innerKey] = data;
      } else {
        sprites[key]![innerKey] = value;
      }
    });

    return sprites;
  }

  /**
   * Load a single image
   */
  Future<void> loadImage(String key) async {
    /// cache these externally
    String texturePath = _cache[key]["texturePath"];
    final ByteData data = await rootBundle.load(texturePath);
    _cache[key]["texture"] = await Utils.shared.imageFromBytes(data);
    // making sure we got something back
    if (_cache[key]["texture"] != null) {
      _cache[key]["textureWidth"] = _cache[key]["texture"]!.width;
      _cache[key]["textureHeight"] = _cache[key]["texture"]!.height;
      _cache[key]["loadedState"] = "done";
    } else {
      _cache[key]["loadedState"] = "none";
    }
  }

  /**
   * Get an item from the cache
   */
  Map<String, dynamic>? getItem(String key) {
    return _cache[key];
  }

  /**
   * Check if the cache is empty
   */
  bool isEmpty() {
    return _cache.isEmpty;
  }
}

class CustomTsxProvider extends TsxProvider {
  @override
  Parser getSource(String fileName) {
    final xml = File(fileName).readAsStringSync();
    final node = XmlDocument.parse(xml).rootElement;
    return XmlParser(node);
  }

  @override
  // TODO: implement filename
  String get filename => throw UnimplementedError();

  @override
  Parser? getCachedSource() {
    // TODO: implement getCachedSource
    throw UnimplementedError();
  }
}
