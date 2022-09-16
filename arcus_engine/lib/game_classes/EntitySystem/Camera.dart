import 'dart:math';
import 'dart:ui';
import 'package:vector_math/vector_math.dart' as vectorMath;

class CameraProps {
  bool enabled = false;
  Size canvasSize = Size(0, 0);
  dynamic followObject;
  Size mapSize = Size(0, 0);
  Point<double> offset = Point(0.0, 0.0);

  CameraProps({
    required this.enabled,
    required this.canvasSize,
    required this.mapSize,
    offset,
    followObject,
  }) {
    //print("${followObject.left} ${followObject.top}");
    followObject = followObject;
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
    // Account for half of player w/h to make their rectangle centered
    x = clamp(cameraProps.followObject.position.x - cameraProps.canvasSize.width / 2 + cameraProps.followObject.size.width / 2, 0,
        cameraProps.mapSize.width - cameraProps.canvasSize.width);
    y = clamp(cameraProps.followObject.position.y - cameraProps.canvasSize.height / 2 + cameraProps.followObject.size.height / 2, 0,
        cameraProps.mapSize.height - cameraProps.canvasSize.height);
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
