import 'dart:math';
import 'package:flutter/animation.dart';

class SlowMoCurve extends Curve {
  final double linearRatio;
  final double power;

  const SlowMoCurve({
    this.linearRatio = 0.7,
    this.power = 0,
  });

  @override
  double transformInternal(double t) {
    double ratio = min(1, linearRatio);

    var pow = ratio < 1
            ? power == 0
                ? power
                : 0.7
            : 0,
        p1 = (1 - ratio) / 2,
        p3 = p1 + ratio;
    //calcEnd = false;

    var r = t + (0.5 - t) * pow;
    double result = (t < p1
            ? r - (t = 1 - t / p1) * t * t * t * r
            : t > p3
                ? r + (t - r) * (t = (t - p3) / p1) * t * t * t
                : r)
        .toDouble();
    return result;
  }
}
