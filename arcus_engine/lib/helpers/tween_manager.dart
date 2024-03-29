import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';

class AnimationProperties {
  int duration = 100;
  Curve ease = Curves.linear;
  int delay = 0;
  AnimationProperties({duration, ease, delay}) {
    this.duration = duration ?? 100;
    this.ease = ease ?? Curves.linear;
    this.delay = delay ?? 0;
  }
}

class TweenOptions {
  String property;
  dynamic target;
  AnimationProperties? animationProperties;
  dynamic to;
  dynamic from;
  List<dynamic> collection = [];
  bool autostart = false;

  TweenOptions(
      {required this.target,
      required this.property,
      required this.to,
      collection,
      from,
      autostart,
      animationProperties}) {
    this.animationProperties = animationProperties ?? AnimationProperties();
    this.autostart = autostart ?? false;
    this.from = from ?? null;
    this.collection = collection ?? [];
  }

  getOptions() {
    return this;
  }
}

class TweenManager {
  // we could avoid this by creating our own ticker !?
  TickerProvider ticker;
  TweenManager({required this.ticker});

  /**
   * {duration, target, property, end, ease}
   */
  AnimationController addTween(
      TweenOptions options, Function? completeFn, Function? updateFn) {
    AnimationController controller = AnimationController(
        vsync: this.ticker,
        duration: Duration(
            milliseconds: options.animationProperties!.duration.toInt()));

    // find the target via ID
    var target = options.collection
        .firstWhere((element) => element.id == options.target);

    var tween = Tween(
      begin: options.from ?? target.getProperty(options.property),
      end: options.to,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(options.animationProperties!.delay.toDouble(), 1.0,
          curve: options.animationProperties!.ease),
    ));

    tween.addListener(() => {
          target.setProperty(options.property, tween.value),
          if (updateFn != null)
            {
              updateFn(),
            }
        });

    if (completeFn != null) {
      tween.addStatusListener((status) =>
          onStatus(status, controller, tween, completeFn, updateFn));
    }

    // auto start?
    // TODO: Add repeat support
    if (options.autostart == true) {
      controller.forward();
    }

    // let the user manage it
    return controller;
  }

  void onStatus(
    AnimationStatus status,
    AnimationController controller,
    Animation<Object> tween,
    Function completeFn,
    Function? updateFn,
  ) {
    if (status == AnimationStatus.completed) {
      completeFn();
      controller.dispose();
      if (updateFn != null) {
        tween.removeListener(() => updateFn);
      }
      tween.removeStatusListener((status) =>
          onStatus(status, controller, tween, completeFn, updateFn));
    }
  }
}
