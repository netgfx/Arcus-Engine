import 'dart:html';

import 'package:flutter/foundation.dart';

class GamepadControl {
  Function onArrowPress;
  Function onButtonPress;
  List<Gamepad?> gamepads = [];
  var controllers = {};
  GamepadControl({
    required this.onArrowPress,
    required this.onButtonPress,
  }) {
    if (kIsWeb) {
      gamepads = window.navigator.getGamepads();

      window.addEventListener("gamepadconnected", connectHandler);
      window.addEventListener("gamepaddisconnected", disconnectHandler);
    }
  }

  connectHandler(dynamic event) {
    print("${event}");
  }

  disconnectHandler(dynamic event) {
    print("${event}");
  }

  checkButtons() {
    if (gamepads.length > 0) {
      var gp = gamepads[0];

      if (gp!.buttons != null) {
        if (gp.buttons!.isNotEmpty) {
          if (gp.buttons![0].pressed!) {
            print(gp.buttons![0]);
          }
        } else if (gp.buttons![1].pressed!) {
          print(gp.buttons![1]);
        }
      }

      if (gp.axes != null) {
        print(gp.axes);
      }
    }
  }

  scangamepads() {
    var gamepads = window.navigator.getGamepads();
    for (var gamepad in gamepads) {
      if (gamepad != null) {
        // Can be null if disconnected during the session
        if (gamepads.contains(gamepad.index)) {
          controllers[gamepad.index] = gamepad;
        } else {
          addgamepad(gamepad);
        }
      }
    }
  }

  addgamepad(gamepad) {
    controllers[gamepad.index] = gamepad;
  }
}
