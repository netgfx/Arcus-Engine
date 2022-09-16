import 'dart:math';
import 'dart:ui';
import 'package:arcus_engine/game_classes/EntitySystem/world.dart';
import 'package:arcus_engine/helpers/game_object.dart';
import 'package:vector_math/vector_math.dart' as vectorMath;

class CameraProps {
  bool enabled = false;
  Size canvasSize = const Size(0, 0);
  dynamic followObject;
  Size mapSize = const Size(0, 0);
  Point<double> offset = const Point(0.0, 0.0);

  CameraProps({
    required this.enabled,
    required this.canvasSize,
    required this.mapSize,
    offset,
    followObject,
  }) {
    //print("${followObject.left} ${followObject.top}");
    this.followObject = followObject;
    this.offset = offset ?? const Point(0.0, 0.0);
  }
}

class Camera {
  double x;
  double y;
  Point<double> offset = const Point<double>(0.0, 0.0);
  CameraProps cameraProps;

  Camera({required this.x, required this.y, required this.cameraProps, offset}) {
    this.offset = offset ?? const Point<double>(0.0, 0.0);
  }

  void update() {
    focus();
  }

  focus() {
    if (cameraProps.followObject != null) {
      var followObject = cameraProps.followObject;

      /// get the follow object by ID
      if (followObject is String) {
        TDWorld? world = GameObject.shared.getWorld();
        if (world != null) {
          List<dynamic> objects = world.getObjectById(followObject);
          if (objects.isNotEmpty) {
            followObject = objects[0];
          }
        }
      }

      // Account for half of player w/h to make their rectangle centered
      x = clamp(followObject.position.x - cameraProps.canvasSize.width / 2 + followObject.size.width / 2, 0,
          cameraProps.mapSize.width - cameraProps.canvasSize.width);
      y = clamp(followObject.position.y - cameraProps.canvasSize.height / 2 + followObject.size.height / 2, 0,
          cameraProps.mapSize.height - cameraProps.canvasSize.height);
    }
  }

  double clamp(double coord, double min, double max) {
    if (coord < min) {
      return min;
    } else if (coord > max) {
      return max;
    } else {
      return coord;
    }
  }

  Rect getCameraBounds() {
    return Rect.fromLTWH(offset.x + x, offset.y + y, cameraProps.canvasSize.width, cameraProps.canvasSize.height);
  }
}
