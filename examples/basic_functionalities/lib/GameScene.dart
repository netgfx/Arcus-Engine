import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:arcus_engine/game_classes/EntitySystem/bitmap_font.dart';
import 'package:arcus_engine/game_classes/EntitySystem/particle_emitter.dart';
import 'package:arcus_engine/game_classes/EntitySystem/physics_body_simple.dart';
import 'package:arcus_engine/game_classes/EntitySystem/text_object.dart';
import 'package:arcus_engine/game_classes/EntitySystem/tilemap_controller.dart';
import 'package:arcus_engine/game_classes/EntitySystem/world.dart';
import 'package:arcus_engine/helpers/game_object.dart';
import 'package:arcus_engine/helpers/utils.dart';
import 'package:arcus_engine/helpers/vector_little.dart' as vec2;
import 'package:arcus_engine/helpers/sound_manager.dart';
import 'package:arcus_engine/helpers/vector_little.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:flutter_native_image/flutter_native_image.dart' as uiImage;
import 'package:arcus_engine/game_classes/EntitySystem/Camera.dart';
import 'package:arcus_engine/game_classes/EntitySystem/shape_maker.dart';
import 'package:arcus_engine/game_classes/EntitySystem/sprite.dart';
import 'package:arcus_engine/game_classes/EntitySystem/sprite_animator.dart';
import 'package:arcus_engine/game_classes/EntitySystem/group_controller.dart';
import 'package:arcus_engine/game_classes/EntitySystem/sprite_archetype.dart';
import 'package:arcus_engine/game_classes/sprite_driver.dart';
import 'package:arcus_engine/helpers/action_manager.dart';
import 'package:arcus_engine/helpers/sprite_cache.dart';
import 'package:arcus_engine/helpers/tween_manager.dart';
import 'package:performance/performance.dart';
import 'package:arcus_engine/helpers/math/SlowMoCurve.dart';

class GameScene extends StatefulWidget {
  GameScene({required Key key}) : super(key: key);

  @override
  _GameSceneState createState() => _GameSceneState();
}

class _GameSceneState extends State<GameScene> with TickerProviderStateMixin {
  late AnimationController _controller;
  BoxConstraints? viewportConstraints;

  //
  Map<String, dynamic> spriteCache = {};
  // entity stuff
  ActionManager actions = ActionManager();
  SpriteCache cache = SpriteCache();

  bool cacheReady = false;
  List<dynamic> spritesArr = [];
  late TweenManager _tween;

  ///
  @override
  void initState() {
    super.initState();
    _tween = TweenManager(ticker: this);
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    //_spriteController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    //_controller.addListener(() {setState(() {});}); no need to setState
    //_controller.drive(CurveTween(curve: Curves.bounceIn));
    //_spriteController.repeat();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.repeat();

      /// audio cache
      SoundManager.shared.addItem(
        "click",
        "assets/sounds/click.mp3",
      );
      // cache
      cache.addItem(
        "mage1",
        texturePath: "assets/mage1.png",
      );
      cache.addItem(
        "redblock",
        texturePath: "assets/red.png",
      );
      cache.addItem(
        "greyblock",
        texturePath: "assets/grey.png",
      );
      cache.addItem(
        "boom",
        texturePath: "assets/boom.png",
        dataPath: "assets/boom.json",
        delimiters: ["Boom-1"],
      );
      cache.addItem(
        "bat",
        texturePath: "assets/flying_monster.png",
        dataPath: "assets/flying_monster.json",
        delimiters: ["death/Death_animations", "fly/Fly2_Bats"],
      );
      cache.addItem(
        "mageFont",
        texturePath: "assets/fonts/mageGreen.png",
        dataPath: "assets/fonts/mageGreen.fnt",
        dataType: "xml",
      );
      cache.addItem(
        "tilemap",
        texturePath: "assets/tiles/tiles_packed.png",
        dataPath: "assets/tiles/tilemap.tmj",
        dataType: "tilemap",
      );

      cache.addItem(
        "bg",
        texturePath: "assets/bg_07.jpg",
      );

      var result = cache.loadItems();
      result.then((value) => {
            print("Items loaded? $value"),
            setState(() => {
                  cacheReady = true,
                }),
            init()
          });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    actions.actionController.close();
    super.dispose();
  }

  void init() {
    List<dynamic> sprites = [];

    GroupController group = GroupController(
      position: Point(100.0, 100.0),
      startAlive: true,
    );
    group.zIndex = 1;
    group.enableDebug = true;

    group.addItem(
      const Point<double>(0.0, 0.0),
      Sprite(
        position: const Point<double>(0.0, 0.0),
        textureName: "mage1",
        startAlive: true,
        scale: 0.8,
        fitParent: false,
        enablePhysics: false,
        centerOffset: const Offset(0, 0),
      ),
    );

    sprites = [
      // Sprite(
      //   position: const Point<double>(100.0, 100.0),
      //   textureName: "mage1",
      //   scale: 0.2,
      //   zIndex: 2,
      //   enablePhysics: false,
      //   startAlive: true,
      //   fitParent: false,
      //   centerOffset: const Offset(0, 0),
      //   onCollide: (obj) {
      //     //print("collision with: ${obj}");
      //   },
      //   physicsProperties: PhysicsBodyProperties(
      //     velocity: Vector2(x: 0, y: 0),
      //     restitution: 0.6,
      //     friction: 0.95,
      //   ),
      // ),
      // Sprite(
      //     position: const Point<double>(250.0, 600.0),
      //     textureName: "greyblock",
      //     scale: 0.30,
      //     zIndex: 2,
      //     interactive: true,
      //     enablePhysics: true,
      //     startAlive: true,
      //     fitParent: false,
      //     centerOffset: const Offset(0, 0),
      //     physicsProperties: PhysicsBodyProperties(velocity: Vector2(x: 0, y: 0), restitution: 0.9, friction: 0.95, mass: 10, immovable: true),
      //     onEvent: (Point event, SpriteArchetype sprite) => {
      //           print("this greyblock is tapped"),
      //         }),
      // Sprite(
      //   position: const Point<double>(0.0, 0.0),
      //   textureName: "bg",
      //   startAlive: true,
      //   scale: 1.0,
      // ),
      SpriteAnimator(
        position: Point<double>(100.0, 100.0),
        textureName: "bat",
        currentFrame: "fly/Fly2_Bats",
        id: "bat",
        centerOffset: Offset(0.0, 0.0),
        loop: RepeatMode.Repeat,
        scale: 0.35,
        zIndex: 3,
        startAlive: true,
        fps: 24,
        enablePhysics: false,
        onEvent: (Point event, SpriteArchetype sprite) => changeText(),
        interactive: true,
      ),
      TextObject(
        id: "mainText",
        text: "Hello Arcus!",
        position: vec2.Vector2(x: 100, y: 100),
        fontSize: 56,
        color: Colors.green,
        startAlive: true,
        zIndex: 2,
        maxLines: 2,
        border: true,
        borderWidth: 1,
        borderColor: Colors.orange,
        maxWidth: 400,
        fontFamily: "IrishGrover",
      ),
      TilemapController(
        position: vec2.Vector2(x: 100, y: 100),
        cacheKey: "tilemap",
        startAlive: true,
      )
      // ParticleEmitter(
      //   pos: Vector2(x: 250.0, y: 320.0),
      //   emitSize: Vector2(x: 100, y: 100),
      //   sizeStart: 4,
      //   sizeEnd: 2,
      //   emitTime: 0.30, // in s
      //   emitRate: 300,
      //   emitConeAngle: pi,
      //   startColor: const Color.fromRGBO(255, 0, 128, 1),
      //   endColor: const Color.fromRGBO(255, 0, 0, 1),
      //   particleTime: 0.15,
      //   speed: 300,
      //   fadeRate: 0.98,
      //   randomness: 1,
      //   collideTiles: false,
      //   randomColorLinear: true,
      //   renderOrder: 1,
      //   startAlive: true,
      // ),
      // ShapeMaker(
      //   type: ShapeType.Rect,
      //   position: const Point<double>(200.0, 250.0),
      //   radius: 20,
      //   size: const Size(300, 10),
      //   zIndex: 1,
      //   interactive: false,
      //   paintOptions: {
      //     "color": Colors.red,
      //     "paintingStyle": ui.PaintingStyle.fill,
      //   },
      //   startAlive: true,
      //   enablePhysics: true,
      //   physicsProperties: PhysicsBodyProperties(velocity: Vector2(x: 0, y: 0), restitution: 0.9, friction: 0.95, mass: 1000, immovable: true),
      // ),
      //group,
      // BitmapFont(
      //   targetText: "Hello world!\nAnd then some!",
      //   position: vec2.Vector2(x: 100, y: 100),
      //   textureName: "mageFont",
      //   startAlive: true,
      // ),
    ];

    /// performance debug
    // for (var i = 0; i < 100; i++) {
    //   var shape = ShapeMaker(
    //     type: ShapeType.Rect,
    //     position: Point<double>(Utils.shared.rand(a: 0, b: 500), Utils.shared.rand(a: 50.0, b: 250.0)),
    //     radius: 20,
    //     size: const Size(300, 10),
    //     zIndex: 1,
    //     interactive: false,
    //     paintOptions: {
    //       "color": Colors.red,
    //       "paintingStyle": ui.PaintingStyle.fill,
    //     },
    //     startAlive: true,
    //     enablePhysics: false,
    //     batchDraw: false,
    //     physicsProperties: PhysicsBodyProperties(
    //       velocity: Vector2(x: 0, y: 0),
    //       restitution: 0.9,
    //       friction: 0.95,
    //       mass: 1000,
    //       immovable: true,
    //     ),
    //   );

    //   sprites.add(shape);
    // }
    setState(() {
      spritesArr = sprites;
    });
  }

  void changeText() {
    print("I'm tapped!!!");
    TDWorld? world = GameObject.shared.getWorld();
    if (world != null) {
      List<dynamic> text = world.getObjectById("mainText");
      if (text.length > 0) {
        (text[0] as TextObject).setText("${text[0].text}!");
      }
    }
    SoundManager.shared.playTrack("click");
    _tween.addTween(
      TweenOptions(
        target: "mainText",
        //collection: sprites,
        property: "scale",
        to: 1.0,
        from: 0.1,
        autostart: true,
        animationProperties: AnimationProperties(
          duration: 1000,
          delay: 0.05,
          ease: const SlowMoCurve(linearRatio: 0.25, power: 0.9),
        ),
      ),
      () => {print("tween complete!")},
      null,
    );
  }

  void playFly() {
    setState(() {
      //batFirstFrame = "fly/Fly2_Bats";
      //batLoop = true;
    });
  }

  void playExplode() {
    setState(() {
      //batFirstFrame = "death/Death_animations";
      //batLoop = false;
    });
  }

  void onTap(BuildContext context, TapDownDetails details) {
    //checkCollision();
    // setState(() {
    //   lightSource = Point(details.localPosition.dx, details.localPosition.dy);
    // });
    // early iteration, sprite should be responsible for sending events
    //actions.sendAnimation(details.localPosition.dx, details.localPosition.dy, "boom", "Boom-1");
    actions.sendClick(details.localPosition.dx, details.localPosition.dy);
  }

  void onPanStart(BuildContext context, DragStartDetails details) {
    actions.sendDragStart(details.localPosition.dx, details.localPosition.dy);
  }

  void onPanUpdate(BuildContext context, DragUpdateDetails details) {
    actions.sendDragMove(details.localPosition.dx, details.localPosition.dy);
  }

  void onPanEnd(BuildContext context, DragEndDetails details) {
    actions.sendDragEnd();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPerformanceOverlay(
      child: Scaffold(
          backgroundColor: ui.Color.fromARGB(255, 17, 17, 17),
          body: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
            this.viewportConstraints = viewportConstraints;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => onTap(context, details),
              onPanStart: (details) => onPanStart(context, details),
              onPanUpdate: (details) => onPanUpdate(context, details),
              onPanEnd: (details) => onPanEnd(context, details),
              child: Stack(children: [
                this.cacheReady == false
                    ? Center(
                        child: CircularProgressIndicator(
                        key: UniqueKey(),
                        strokeWidth: 10,
                      ))
                    : Positioned(
                        top: 0,
                        left: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0, left: 0),
                          child: Stack(children: [
                            RepaintBoundary(
                              child: CustomPaint(
                                key: UniqueKey(),
                                isComplex: true,
                                willChange: false,
                                painter: SpriteDriverCanvas(
                                  controller: _controller,
                                  fps: 60,
                                  sprites: spritesArr,
                                  cache: cache,
                                  actions: cache.isEmpty() ? null : actions,
                                  width: viewportConstraints.maxWidth,
                                  height: viewportConstraints.maxHeight,
                                  cameraProps: CameraProps(
                                    enabled: true,
                                    canvasSize: Size(viewportConstraints.maxWidth, viewportConstraints.maxHeight),
                                    mapSize: Size(
                                      viewportConstraints.maxWidth,
                                      viewportConstraints.maxHeight,
                                    ),
                                    followObject: "bat",
                                    offset: const Point<double>(0.0, 0.0),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
              ]),
            );
            //);
          })),
    );
  }
}
