import 'dart:core';
import 'dart:math';
import 'dart:collection';

import 'package:arcus_engine/game_classes/EntitySystem/particle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:arcus_engine/game_classes/EntitySystem/Camera.dart';
import 'package:arcus_engine/game_classes/EntitySystem/sprite_animator.dart';
import 'package:arcus_engine/game_classes/EntitySystem/world.dart';
import 'package:arcus_engine/game_classes/EntitySystem/sprite_archetype.dart';
import 'package:arcus_engine/helpers/game_object.dart';
import 'package:arcus_engine/helpers/rectangle.dart';
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
  double frame = 0;
/** How many seconds each frame lasts, engine uses a fixed time step
 *  @default 1/60 */
  double timeDelta = 1 / 60;
  int printTime = DateTime.now().millisecondsSinceEpoch;
  int timeDecay = 0;
  int timeToLive = 24;
  double width = 100;
  double height = 100;
  int curveIndex = 0;
  var computedPoint = vectorMath.Vector2(0, 0);
  double computedAngle = 0.0;
  List<List<vectorMath.Vector2>> curve = [];
  Function? update;
  BoxConstraints sceneSize = const BoxConstraints(minWidth: 800, maxWidth: 1600, minHeight: 450, maxHeight: 900);

  ActionManager? actions;
  SpriteCache cache;
  late var listenable;
  Rectangle worldBounds = Rectangle(x: 0, y: 0, width: 0, height: 0);
  TDWorld? _world;
  List<dynamic> sprites = [];
  bool shouldCheckEvent = false;
  Point<double> eventPoint = const Point(0, 0);
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
    timeDecay = (1 / fps * 1000).round();
    timeDelta = 1 / fps;
    GameObject.shared.timeDelta = timeDelta;
    this.cameraProps = cameraProps;

    /// calculate world bounds
    worldBounds = Rectangle(x: 0, y: 0, width: width, height: height);

    if (_world == null) {
      _world = TDWorld();
      _world!.worldBounds = Size(worldBounds.width, worldBounds.height);
      _world!.displayList = sprites;
    }
    GameObject.shared.setSpriteCache(cache);

    if (this.cameraProps != null) {
      if (this.cameraProps!.enabled == true) {
        _camera = Camera(
          x: 0,
          y: 0,
          cameraProps: this.cameraProps!,
          offset: Point<double>(this.cameraProps!.offset.x, this.cameraProps!.offset.y),
        );

        _world?.setCamera(_camera!);
      }
    }

    /// after it is complete with references
    if (_world != null) {
      GameObject.shared.setWorld(_world!);
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
    if (_world != null) {
      _world!.canvas = this.canvas;
      GameObject.shared.getWorld()!.canvas = this.canvas;
    }
    draw(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void draw(Canvas canvas, Size size) {
    /// check if the controller is running
    if (controller != null) {
      if (controller!.lastElapsedDuration != null) {
        // camera
        if (_camera != null) {
          canvas.clipRect(Rect.fromLTWH(
            cameraProps!.offset.x,
            cameraProps!.offset.y,
            _camera!.getCameraBounds().width,
            _camera!.getCameraBounds().height,
          ));
          //Rect bounds = _camera!.getCameraBounds();
        }
        var lastElapsed = (controller!.lastElapsedDuration!.inMilliseconds - oldTimestamp) / 1000;
        oldTimestamp = controller!.lastElapsedDuration!.inMilliseconds;

        GameObject.shared.frameTime = controller!.lastElapsedDuration!.inMilliseconds.toDouble();

        /// in order to run in our required frames per second
        if (controller!.lastElapsedDuration!.inMilliseconds - currentTime >= timeDecay) {
          /// reset the time
          /// save to world
          GameObject.shared.time = ++frame / fps;
          currentTime = controller!.lastElapsedDuration!.inMilliseconds;

          /// combine local list and global display list
          if (_world != null) {
            List<dynamic> finalList = [];
            finalList = [...sprites, ..._world!.displayList];
            sprites = finalList.unique((item) => item.id);
          }

          var results = [];
          for (var item in sprites) {
            if (item.alive == true) {
              //depth sort
              depthSort();

              // update
              item.update(
                canvas,
                elapsedTime: currentTime.toDouble(),
                timestamp: lastElapsed,
              );
              // check for events
              if (shouldCheckEvent == true) {
                if (item.interactive == true) {
                  /// get camera position
                  Rect cameraPos = Rect.fromLTWH(0, 0, 0, 0);
                  if (_camera != null) {
                    cameraPos = _camera!.getCameraBounds();
                  }
                  // need to take depth into account
                  bool result = Utils.shared.containsRaw(
                    item.getPosition().x + (cameraPos.left * -1),
                    item.getPosition().y + (cameraPos.top * -1),
                    item.size.width,
                    item.size.height,
                    eventPoint.x,
                    eventPoint.y,
                  );

                  if (result == true) {
                    results.add(item);
                  }
                }
              }
            } else {
              try {
                if (item.destroyed == true) {
                  // remove destroyed item
                  sprites.removeWhere((element) => element.id == item.id);
                  if (_world != null) {
                    _world!.remove(item, null);
                  }
                }
              } catch (e) {
                /// no property
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
          for (var item in sprites) {
            if (item.alive == true) {
              //depth sort
              depthSort();
              // update
              item.update(
                canvas,
                elapsedTime: currentTime.toDouble(),
                timestamp: lastElapsed,
                shouldUpdate: false,
              );
            } else {
              try {
                if (item.destroyed == true) {
                  // remove destroyed item
                  sprites.removeWhere((element) => element.id == item.id);
                  if (_world != null) {
                    _world!.remove(item, null);
                  }
                }
              } catch (e) {
                /// no property
              }
            }
          }
        }
      } else {
        print("no elapsed duration");
        // for (var item in sprites) {
        //   if (item.alive == true) {
        //     //     //depth sort
        //     depthSort();
        //     //     // update
        //     item.update(
        //       canvas,
        //       elapsedTime: currentTime.toDouble(),
        //       timestamp: 0,
        //       shouldUpdate: false,
        //     );
        //   }
        // }
      }
    } else {
      print("no controller running");
    }

    // update camera
    if (_camera != null) {
      _camera!.update();
      //print("${_camera!.getCameraBounds()} ${GameObject.shared.world!.getCamera().getCameraBounds()}");
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
