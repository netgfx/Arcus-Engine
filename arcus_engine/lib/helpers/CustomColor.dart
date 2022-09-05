import 'package:arcus_engine/helpers/utils.dart';
import 'dart:math';

/** 
 * Color object (red, green, blue, alpha) with some helpful functions
 * @example
 * let a = new Color;             // white
 * let b = new Color(1, 0, 0);    // red
 * let c = new Color(0, 0, 0, 0); // transparent black
 */
class CustomColor {
  int r = 0;
  int g = 0;
  int b = 0;
  int a = 1;

  /** Create a color with the components passed in, white by default
     *  @param {Number} [red=1]
     *  @param {Number} [green=1]
     *  @param {Number} [blue=1]
     *  @param {Number} [alpha=1] */
  CustomColor({required this.r, required this.g, required this.b, required this.a}) {}

  /** Returns a new color that is a copy of this
     * @return {Color} */
  copy() {
    return CustomColor(r: this.r, g: this.g, b: this.b, a: this.a);
  }

  /** Returns a copy of this color plus the color passed in
     * @param {Color} color
     * @return {Color} */
  add(CustomColor c) {
    return CustomColor(r: this.r + c.r, g: this.g + c.g, b: this.b + c.b, a: this.a + c.a);
  }

  /** Returns a copy of this color minus the color passed in
     * @param {Color} color
     * @return {Color} */
  subtract(CustomColor c) {
    return CustomColor(r: this.r - c.r, g: this.g - c.g, b: this.b - c.b, a: this.a - c.a);
  }

  /** Returns a copy of this color times the color passed in
     * @param {Color} color
     * @return {Color} */
  multiply(CustomColor c) {
    return CustomColor(r: this.r * c.r, g: this.g * c.g, b: this.b * c.b, a: this.a * c.a);
  }

  /** Returns a copy of this color divided by the color passed in
     * @param {Color} color
     * @return {Color} */
  divide(CustomColor c) {
    return CustomColor(r: (this.r / c.r).round(), g: (this.g / c.g).round(), b: (this.b / c.b).round(), a: (this.a / c.a).round());
  }

  /** Returns a copy of this color scaled by the value passed in, alpha can be scaled separately
     * @param {Number} scale
     * @param {Number} [alphaScale=scale]
     * @return {Color} */
  scale(s, {a = 1.0}) {
    return CustomColor(r: (this.r * s).round(), g: (this.g * s).round(), b: (this.b * s).round(), a: (this.a * a).round());
  }

  /** Returns a copy of this color clamped to the valid range between 0 and 1
     * @return {Color} */
  clamp() {
    return CustomColor(
        r: Utils.shared.clamp(this.r.toDouble(), 0, 1).toInt(),
        g: Utils.shared.clamp(this.g.toDouble(), 0, 1).toInt(),
        b: Utils.shared.clamp(this.b.toDouble(), 0, 1).toInt(),
        a: Utils.shared.clamp(this.a.toDouble(), 0, 1).toInt());
  }

  /** Returns a new color that is p percent between this and the color passed in
     * @param {Color}  color
     * @param {Number} percent
     * @return {Color} */
  lerp(CustomColor c, double p) {
    return this.add(c.subtract(this).scale(Utils.shared.clamp(p, 0, 1)));
  }

  /** Sets this color given a hue, saturation, lightness, and alpha
     * @param {Number} [hue=0]
     * @param {Number} [saturation=0]
     * @param {Number} [lightness=1]
     * @param {Number} [alpha=1]
     * @return {Color} */
  setHSLA({h = 0, s = 0, l = 1, a = 1}) {
    var q = l < .5 ? l * (1 + s) : l + s - l * s,
        p = 2 * l - q,
        f = (p, q, t) => (t = ((t % 1) + 1) % 1) < 1 / 6
            ? p + (q - p) * 6 * t
            : t < 1 / 2
                ? q
                : t < 2 / 3
                    ? p + (q - p) * (2 / 3 - t) * 6
                    : p;

    this.r = f(p, q, h + 1 / 3);
    this.g = f(p, q, h);
    this.b = f(p, q, h - 1 / 3);
    this.a = a;
    return this;
  }

  /** Returns this color expressed in hsla format
     * @return {Array} */
  getHSLA() {
    var r = this.r;
    var g = this.g;
    var b = this.b;
    var a = this.a;
    var _max = max(r, g);
    _max = max(_max, b);
    var _min = min(r, g);
    _min = min(_min, b);
    var l = (_max + _min) / 2;

    var h = 0;
    var s = 0;
    if (_max != _min) {
      var d = _max - _min;
      s = (l > .5 ? d / (2 - _max - _min) : d / (_max + _min)) as int;
      if (r == max)
        h = ((g - b) / d + (g < b ? 6 : 0)) as int;
      else if (g == max)
        h = ((b - r) / d + 2) as int;
      else if (b == max) h = ((r - g) / d + 4) as int;
    }

    return [h / 6, s, l, a];
  }

  /** Returns a new color that has each component randomly adjusted
     * @param {Number} [amount=.05]
     * @param {Number} [alphaAmount=0]
     * @return {Color} */
  mutate({amount = .05, alphaAmount = 0}) {
    return CustomColor(
            r: (r + Utils.shared.rand(a: amount, b: -amount)).toInt(),
            g: (g + Utils.shared.rand(a: amount, b: -amount)).toInt(),
            b: (b + Utils.shared.rand(a: amount, b: -amount)).toInt(),
            a: (a + Utils.shared.rand(a: alphaAmount, b: -alphaAmount)).toInt())
        .clamp();
  }

  /** Returns this color expressed as an CSS color value
     * @return {String} */
  toString() {
    return "rgb(${this.r * 255 | 0},${this.g * 255 | 0},${this.b * 255 | 0},${this.a})";
  }

  /** Returns this color expressed as 32 bit integer RGBA value
     * @return {Number} */
  rgbaInt() {
    return (this.r * 255 | 0) + (this.g * 255 << 8) + (this.b * 255 << 16) + (this.a * 255 << 24);
  }
}
