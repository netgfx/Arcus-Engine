import 'dart:html';
import 'dart:ui';

import 'dart:ui' as ui;
import 'package:arcus_engine/helpers/game_object.dart';
import 'package:arcus_engine/helpers/vector_little.dart';
import 'package:flutter/cupertino.dart';
import 'package:xml/xml.dart';

/// A single character in a [BitmapFont].
class BitmapFontCharacter {
  final int id;
  final int width;
  final int height;
  final int xoffset;
  final int yoffset;
  final int xadvance;
  final int page;
  final int channel;
  final int x;
  final int y;
  //final ui.Image image;

  BitmapFontCharacter(this.id, this.width, this.height, this.xoffset, this.yoffset, this.xadvance, this.page, this.x, this.y, this.channel) {}

  @override
  String toString() {
    final x = {'id': id, 'width': width, 'height': height, 'xoffset': xoffset, 'yoffset': yoffset, 'xadvance': xadvance, 'page': page, 'channel': channel};
    return 'Character $x';
  }
}

class BitmapFont {
  String targetText = "";
  Vector2 position = Vector2(x: 0, y: 0);
  String face = '';
  int size = 0;
  bool bold = false;
  bool italic = false;
  String charset = '';
  String unicode = '';
  int fontSize = 40;
  int stretchH = 0;
  bool smooth = false;
  bool antialias = false;
  List<int> padding = [];
  List<int> spacing = [];
  bool outline = false;
  int lineHeight = 0;
  int base = 0;
  num scaleW = 0;
  num scaleH = 0;
  int pages = 0;
  bool packed = false;
  String textureName;
  ui.Image? texture;
  XmlDocument? xmlData;
  int textureWidth = 0;
  int textureHeight = 0;
  double scale = 1.0;
  Size itemSize = Size(0, 0);
  String id = UniqueKey().toString();
  int zIndex = 0;
  bool _alive = false;
  bool startAlive = false;
  int letterSpacing = 5;
  Paint _paint = new Paint();

  Map<int, BitmapFontCharacter> characters = {};
  Map<int, Map<int, int>> kernings = {};

  BitmapFont({
    required this.targetText,
    required this.position,
    required this.textureName,
    startAlive,
  }) {
    if (startAlive == true) {
      alive = true;
    }

    setCache();
    if (xmlData != null) {
      _parseFnt(xmlData!, {0: texture});
      //print(characters);
    }
  }

  bool get alive {
    return _alive;
  }

  set alive(bool value) {
    _alive = value;
  }

  void update(
    Canvas canvas, {
    double elapsedTime = 0,
    double timestamp = 0.0,
    bool shouldUpdate = true,
  }) {
    if (xmlData == null) {
      setCache();
      if (xmlData != null) {
        if (characters.isEmpty) {
          _parseFnt(xmlData!, {0: texture});
        }
        //print(characters);
      }
    }

    if (characters.isNotEmpty) {
      scale = fontSize / size;
      List<BitmapFontCharacter> bitmapText = constructText();
      //print(bitmapText);
      var chars = [];
      double x = 0.0;
      var prevCharCode = null;
      double w = 0.0;
      for (BitmapFontCharacter item in bitmapText) {
        var kerning = 0;

        if (prevCharCode != null) {
          if (kernings[item.id] != null) {
            var prevKerning = kernings[item.id]![prevCharCode!];
            if (prevKerning != null) {
              kerning = prevKerning;
            } else {
              kerning = 0;
            }
          } else {
            kerning = 0;
          }
        }

        w += (item.xadvance + kerning + letterSpacing) * scale;

        chars.add(x + (item.xoffset + kerning + letterSpacing) * scale);

        x += (item.xadvance + kerning + letterSpacing) * scale;

        prevCharCode = item.id;
      }

      Map<String, dynamic> result = {
        "width": w,
        "end": 0,
        "chars": chars,
      };

      //print(result);

      // print them
      /// get camera position
      Rect cameraPos = Rect.fromLTWH(0, 0, 0, 0);
      if (GameObject.shared.world != null) {
        cameraPos = GameObject.shared.world!.getCamera().getCameraBounds();
      }

      int counter = 0;
      for (var item in bitmapText) {
        updateCanvas(canvas, position.x + result['chars'][counter] + cameraPos.left * -1, position.y + cameraPos.top * -1, scale, () {
          canvas.drawImageRect(
            this.texture!,
            Rect.fromLTWH(item.x.toDouble(), item.y.toDouble(), item.width.toDouble(), item.height.toDouble()),
            Rect.fromLTWH(
              0,
              0,
              item.width.toDouble(),
              item.height.toDouble(),
            ),
            _paint,
          );
        }, translate: false);

        counter += 1;
      }
    }
  }

  Iterable<XmlElement> _childElements(XmlNode n) => n.children.whereType<XmlElement>();

  void setCache() {
    Map<String, dynamic>? cacheItem = GameObject.shared.getSpriteCache().getItem(textureName);
    if (cacheItem != null) {
      texture = cacheItem["texture"];
      xmlData = cacheItem["fntData"];
      textureWidth = cacheItem["textureWidth"];
      textureHeight = cacheItem["textureHeight"];
      if (texture != null) {
        setSize();
      }
    }
  }

  void setSize() {
    ui.Image img = texture!;
    double aspectRatio = img.width / img.height;
    int height = (img.height * scale).round();
    int width = (height * aspectRatio).round();
    itemSize = Size(width.toDouble(), height.toDouble());
  }

  List<BitmapFontCharacter> constructText() {
    List<BitmapFontCharacter> list = [];
    // use codeUnitAt
    List<String> stringList = targetText.split("");
    for (var character in stringList) {
      int char = character.codeUnitAt(0);
      BitmapFontCharacter? finalChar = characters[char];
      if (finalChar != null) {
        list.add(finalChar);
      }
    }

    //print(list.length);
    return list;
  }

  void _parseFnt(XmlDocument xml, Map<int, ui.Image?> fontPages) {
    /// Rather than check for children, which will also count whitespace as XmlText,
    /// The first child should have the name <font>.
    final docElements = _childElements(xml).toList();
    if (docElements.length != 1 || docElements[0].name.toString() != 'font') {
      throw Exception('Invalid font XML');
    }

    final font = docElements[0];

    for (var c in _childElements(font)) {
      final name = c.name.toString();
      if (name == 'info') {
        for (var a in c.attributes) {
          switch (a.name.toString()) {
            case 'face':
              face = a.value;
              break;
            case 'size':
              size = int.parse(a.value);
              break;
            case 'bold':
              bold = (int.parse(a.value) == 1);
              break;
            case 'italic':
              italic = (int.parse(a.value) == 1);
              break;
            case 'charset':
              charset = a.value;
              break;
            case 'unicode':
              unicode = a.value;
              break;
            case 'stretchH':
              stretchH = int.parse(a.value);
              break;
            case 'smooth':
              smooth = (int.parse(a.value) == 1);
              break;
            case 'antialias':
              antialias = (int.parse(a.value) == 1);
              break;
            case 'padding':
              final tk = a.value.split(',');
              padding = [];
              for (var t in tk) {
                padding.add(int.parse(t));
              }
              break;
            case 'spacing':
              final tk = a.value.split(',');
              spacing = [];
              for (var t in tk) {
                spacing.add(int.parse(t));
              }
              break;
            case 'outline':
              outline = (int.parse(a.value) == 1);
              break;
          }
        }
      } else if (name == 'common') {
        for (var a in c.attributes) {
          switch (a.name.toString()) {
            case 'lineHeight':
              lineHeight = int.parse(a.value);
              break;
            case 'base':
              base = int.parse(a.value);
              break;
            case 'scaleW':
              scaleW = int.parse(a.value);
              break;
            case 'scaleH':
              scaleH = int.parse(a.value);
              break;
            case 'pages':
              pages = int.parse(a.value);
              break;
            case 'packed':
              packed = (int.parse(a.value) == 1);
              break;
          }
        }
      } else if (name == 'pages') {
        print("pages was requested");
        // for (var page in _childElements(c)) {
        //   final id = int.parse(page.getAttribute('id')!);
        //   final filename = page.getAttribute('file');

        //   if (fontPages.containsKey(id)) {
        //     throw Exception('Duplicate font page id found: $id.');
        //   }

        //   if (arc != null) {
        //     final imageFile = _findFile(arc, filename);
        //     if (imageFile == null) {
        //       throw Exception('Font zip missing font page image '
        //           '$filename');
        //     }

        //     final image = PngDecoder().decodeImage(imageFile.content as List<int>);

        //     fontPages[id] = image;
        //   }
        // }
      } else if (name == 'kernings') {
        for (var kerning in _childElements(c)) {
          final first = int.parse(kerning.getAttribute('first')!);
          final second = int.parse(kerning.getAttribute('second')!);
          final amount = int.parse(kerning.getAttribute('amount')!);

          if (!kernings.containsKey(first)) {
            kernings[first] = {};
          }
          kernings[first]![second] = amount;
        }
      }
    }

    for (var c in _childElements(font)) {
      final name = c.name.toString();
      if (name == 'chars') {
        for (var char in _childElements(c)) {
          final id = int.parse(char.getAttribute('id')!);
          final x = int.parse(char.getAttribute('x')!);
          final y = int.parse(char.getAttribute('y')!);
          final width = int.parse(char.getAttribute('width')!);
          final height = int.parse(char.getAttribute('height')!);
          final xoffset = int.parse(char.getAttribute('xoffset')!);
          final yoffset = int.parse(char.getAttribute('yoffset')!);
          final xadvance = int.parse(char.getAttribute('xadvance')!);
          final page = int.parse(char.getAttribute('page')!);
          final chnl = int.parse(char.getAttribute('chnl')!);

          if (!fontPages.containsKey(page)) {
            throw Exception('Missing page image: $page');
          }

          final fontImage = fontPages[page];

          final ch = BitmapFontCharacter(id, width, height, xoffset, yoffset, xadvance, page, x, y, chnl);

          characters[id] = ch;

          final x2 = x + width;
          final y2 = y + height;
          var pi = 0;
          //final image = ch.image;
          for (var yi = y; yi < y2; ++yi) {
            for (var xi = x; xi < x2; ++xi) {
              //image[pi++] = fontImage!.getPixel(xi, yi);
            }
          }
        }
      }
    }
  }

  void updateCanvas(Canvas canvas, double? x, double? y, double? scale, ui.VoidCallback callback, {bool translate = false}) {
    double _x = x ?? 0;
    double _y = y ?? 0;
    canvas.save();

    if (translate) {
      canvas.translate(_x, _y);
    }

    if (scale != null) {
      canvas.translate(_x, _y);
      canvas.scale(scale);
    }
    callback();
    canvas.restore();
  }
}
