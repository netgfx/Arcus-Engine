import 'dart:core';
import 'dart:math';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:arcus_engine/game_classes/EntitySystem/Camera.dart';
import 'package:arcus_engine/game_classes/EntitySystem/enemy.dart';
import 'package:arcus_engine/game_classes/EntitySystem/sprite_animator.dart';
import 'package:arcus_engine/game_classes/EntitySystem/world.dart';
import 'package:arcus_engine/game_classes/EntitySystem/sprite_archetype.dart';
import 'package:arcus_engine/helpers/GameObject.dart';
import 'package:arcus_engine/helpers/Rectangle.dart';
import 'package:arcus_engine/helpers/action_manager.dart';
import 'package:arcus_engine/helpers/math/CubicBezier.dart';
import 'package:arcus_engine/helpers/sprite_cache.dart';
import 'dart:ui' as ui;
import 'package:vector_math/vector_math.dart' as vectorMath;
import "package:flutter/painting.dart" as painter;
import "../helpers//utils.dart";

class SpriteDriverCanvas extends CustomPainter {
  Color color = Colors.black;
  var index = 0;
  var offset = 0;
  AnimationController? controller;
  Canvas? canvas;
  int delay = 500;
  int currentTime = 0;
  int oldTimestamp = 0;
  int fps = 24;
  int printTime = DateTime.now().millisecondsSinceEpoch;
  int timeDecay = 0;
  final _random = new Random();
  int timeToLive = 24;
  double width = 100;
  double height = 100;
  int curveIndex = 0;
  var computedPoint = vectorMath.Vector2(0, 0);
  double computedAngle = 0.0;
  List<List<vectorMath.Vector2>> curve = [];
  List<CubicBezier> quadBeziers = [];
  Function? update;
  Paint _paint = new Paint();
  List<TDEnemy> enemies = [];
  BoxConstraints sceneSize = BoxConstraints(minWidth: 800, maxWidth: 1600, minHeight: 450, maxHeight: 900);

  ActionManager? actions;
  SpriteCache cache;
  var listenable;
  Rectangle worldBounds = Rectangle(x: 0, y: 0, width: 0, height: 0);
  TDWorld? _world = null;
  List<dynamic> sprites = [];
  bool shouldCheckEvent = false;
  Point<double> eventPoint = Point(0, 0);
  Camera? _camera;
  CameraProps? cameraProps;
  //

  /// Constructor
  SpriteDriverCanvas({
    /// <-- The animation controller
    required this.controller,

    /// <-- Desired FPS
    required this.fps,
    required this.sprites,
    required this.width,
    required this.height,
    required this.cache,
    cameraProps,
    this.actions,
  }) : super(repaint: controller) {
    /// the delay in ms based on desired fps
    this.timeDecay = (1 / this.fps * 1000).round();
    this.cameraProps = cameraProps;

    /// calculate world bounds
    this.worldBounds = Rectangle(x: 0, y: 0, width: this.width, height: this.height);

    if (this._world == null) {
      this._world = TDWorld();
      this._world!.worldBounds = Size(this.worldBounds.width, this.worldBounds.height);
      this._world!.displayList = this.sprites;
      GameObject.shared.setWorld(this._world!);
    }
    GameObject.shared.setSpriteCache(this.cache);

    if (this.cameraProps != null) {
      if (this.cameraProps!.enabled == true) {
        this._camera = Camera(
          x: 0,
          y: 0,
          cameraProps: this.cameraProps!,
          offset: Point<double>(this.cameraProps!.offset.x, this.cameraProps!.offset.y),
        );
      }
    }

    // end of constructor
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    if (actions != null) {
      // add event listener
      addEventListener();
    }

    /// add canvas to World
    if (this._world != null) {
      this._world!.canvas = this.canvas;
      GameObject.shared.getWorld()!.canvas = this.canvas;
    }
    draw(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  void draw(Canvas canvas, Size size) {
    /// check if the controller is running
    if (this.controller != null) {
      if (this.controller!.lastElapsedDuration != null) {
        // camera
        if (_camera != null) {
          canvas.clipRect(
              Rect.fromLTWH(this.cameraProps!.offset.x, this.cameraProps!.offset.y, _camera!.getCameraBounds().width, _camera!.getCameraBounds().height));
          //Rect bounds = _camera!.getCameraBounds();
        }
        var lastElapsed = (controller!.lastElapsedDuration!.inMilliseconds - oldTimestamp) / 1000;
        oldTimestamp = controller!.lastElapsedDuration!.inMilliseconds;

        /// save to world
        GameObject.shared.time = controller!.lastElapsedDuration!.inMilliseconds.toDouble();

        /// in order to run in our required frames per second
        if (this.controller!.lastElapsedDuration!.inMilliseconds - this.currentTime >= timeDecay) {
          /// reset the time

          this.currentTime = this.controller!.lastElapsedDuration!.inMilliseconds;

          var results = [];
          for (var sprite in this.sprites) {
            if (sprite.alive == true) {
              //depth sort
              this.depthSort();
              // update
              sprite.update(
                canvas,
                elapsedTime: this.currentTime.toDouble(),
                timestamp: lastElapsed,
              );
              // check for events
              if (this.shouldCheckEvent == true) {
                if (sprite.interactive == true) {
                  // need to take depth into account
                  bool result = Utils.shared.containsRaw(
                    sprite.getPosition().x,
                    sprite.getPosition().y,
                    sprite.size.width,
                    sprite.size.height,
                    this.eventPoint.x,
                    this.eventPoint.y,
                  );

                  if (result == true) {
                    results.add(sprite);
                  }
                }
              }
            }
          }

          // set which one receives the event
          if (results.length > 0) {
            results.sort((a, b) => a.zIndex.compareTo(b.zIndex));

            results.last.onEvent(this.eventPoint, results.last);

            // reset
            this.shouldCheckEvent = false;
            this.eventPoint = Point<double>(0, 0);
          }
        } else {
          for (var item in this.sprites) {
            if (item.alive == true) {
              //depth sort
              this.depthSort();
              // update
              item.update(
                canvas,
                elapsedTime: this.currentTime.toDouble(),
                timestamp: lastElapsed,
                shouldUpdate: false,
              );
            }
          }
        }
      } else {
        print("no elapsed duration");
      }
    } else {
      print("no controller running");
    }

    // update camera
    if (this._camera != null) {
      this._camera!.update();
      //print("${this._camera!.getCameraBounds()}");
    }
  }

  void depthSort() {
    //if (this.sortChildrenFlag) {
    mergeSort(this.sprites, compare: Utils.shared.sortByDepth);
  }
  //}

  void addEventListener() async {
    actions!.addListener((event) => onAction(event));
  }

  void onAction(dynamic event) {
    // TODO: change to more meaningfull event names (enum?)
    if (event["type"] == "animation") {
      Point<double> coords = event["data"] as Point<double>;
      String spriteName = event["name"];
      String frame = event["frame"];
      //get a non alive sprite to re-use
      var sprite = this.sprites.cast<SpriteArchetype?>().firstWhere((element) {
        bool result = (element!.alive == false) && (element.textureName == spriteName);
        return result;
      }, orElse: () => null);
      if (sprite != null) {
        if (sprite is SpriteAnimator) {
          sprite.position = coords;
          sprite.alive = true;
          sprite.currentIndex = 0;
        }
      } else {
        addSpriteByType("TDSpriteAnimator", coords, spriteName, frame);
      }
    } else if (event["type"] == PointerEvents.CLICK) {
      // do a check on all elements that have interactive enabled and are alive
      this.shouldCheckEvent = true;
      this.eventPoint = Point(event["data"].x, event["data"].y);
    }
  }

  /**
   *  Append a new sprite object
   */
  void addSpriteByType(String type, Point<double> coords, String name, String frame) {
    if (type == "TDSpriteAnimator") {
      this.sprites.add(SpriteAnimator(
            position: coords,
            textureName: name,
            currentFrame: frame,
            loop: RepeatMode.Single,
            startAlive: true,
          ));
    }
  }
}
