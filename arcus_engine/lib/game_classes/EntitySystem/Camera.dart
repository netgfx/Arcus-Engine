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
    this.followObject = followObject;
    this.offset = offset ?? Point(0.0, 0.0);
  }
}

class Camera {
  double x;
  double y;
  Point<double> offset = Point<double>(0.0, 0.0);
  CameraProps cameraProps;

  Camera(
      {required this.x, required this.y, required this.cameraProps, offset}) {
    this.offset = offset ?? Point<double>(0.0, 0.0);
  }

  void update() {
    this.focus();
  }

  focus() {
    // Account for half of player w/h to make their rectangle centered
    this.x = this.clamp(
        cameraProps.followObject.left -
            cameraProps.canvasSize.width / 2 +
            cameraProps.followObject.width / 2,
        0,
        cameraProps.mapSize.width - cameraProps.canvasSize.width);
    this.y = this.clamp(
        cameraProps.followObject.top -
            cameraProps.canvasSize.height / 2 +
            cameraProps.followObject.height / 2,
        0,
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
    return Rect.fromLTWH(this.offset.x + this.x, this.offset.y + this.y,
        this.cameraProps.canvasSize.width, this.cameraProps.canvasSize.height);
  }
}
