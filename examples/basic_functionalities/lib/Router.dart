import 'package:flutter/material.dart';
import 'package:basic_functionalities/GameScene.dart';

import 'main.dart';

Map<String, Widget Function(BuildContext)> routes = {
  'Main': (context) => MyHomePage(
        title: "Shapes in the Dart",
        key: UniqueKey(),
      ),
  'GameScene': (context) => GameScene(
        key: UniqueKey(),
      ),
  //'MessageReply': (context) => MessageReply(key: UniqueKey()),
};
