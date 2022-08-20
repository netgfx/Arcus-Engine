import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fast_poisson_disk_sampling/fast_poisson_disk_sampling.dart';
import 'package:lottie/lottie.dart';
import 'package:statsfl/statsfl.dart';
import 'Router.dart';

void main() {
  runApp(Padding(
      padding: EdgeInsets.only(top: 50),
      child: StatsFl(
          height: 60, align: Alignment.topCenter, maxFps: 60, child: MyApp())));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      initialRoute: "GameScene",
      routes: routes,
      home: MyHomePage(
        title: 'Shapes in the Dart',
        key: UniqueKey(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required Key key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  Offset position = Offset(10, 10);
  final containerKey1 = GlobalKey();
  final containerKey2 = GlobalKey();
  late RenderBox maskArea;
  List<List<double>> points = [];
  String currentLevel = "level1";
  Color bgColor = Color.fromARGB(255, 148, 23, 183);
  Map<String, Map<String, dynamic>> currentNodes = {};
  double timerValue = 1.0;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      var p = FastPoissonDiskSampling(
          shape: Size(
              (MediaQuery.of(context).size.width - 50).ceil().toDouble(),
              (MediaQuery.of(context).size.height - 210).ceil().toDouble()),
          radius: 190,
          maxTries: 50,
          minDistance: 0,
          rng: null);

      setState(() {
        points = p.fill();
      });
    });
  }

  /// animate the timer value
  void animateValue() {
    AnimationController controller = AnimationController(
        duration: const Duration(milliseconds: 15000), vsync: this);
    Animation<double> progress =
        Tween<double>(begin: 1, end: 0).animate(controller);
    progress.addListener(() {
      setState(() {
        timerValue = progress.value;
      });
    });
    progress.addStatusListener((status) {
      //check if status is complete and if all shapes have been found
      if (status == AnimationStatus.completed) {
        bool haveShapeUnmarked = false;
      }
    });
    controller.forward();
  }

  void showVictoryAlert() {}

  void showLossAlert() {}

  void _onPanStart(BuildContext context, DragStartDetails details) {
    print(details.globalPosition.dy);
  }

  void _onPanEnd(BuildContext context, DragEndDetails details) {
    print(details.velocity);
  }

  void _onPanCancel(BuildContext context) {
    print("Pan canceled !!");
  }

  bool checkCollision(RenderBox box1, Size box2Size, Offset box2Offset) {
    bool result = false;
    if (containerKey1.currentContext != null) {
      //RenderBox box1 = containerKey1.currentContext!.findRenderObject() as RenderBox;
      //RenderBox box2 = containerKey2.currentContext!.findRenderObject() as RenderBox;

      final size1 = box1.size;
      final size2 = box2Size;

      var position1 = box1.localToGlobal(Offset(0, -76));
      //position1 = Offset(position1.dx + size1.width * 0.5, position1.dy + size1.height * 0.5);
      var position2 = box2Offset;
      //position2 = Offset(position2.dx + size2.width * 0.5, position2.dy + size2.height * 0.5);
      Rect rect1 = position1 & size1;
      Rect rect2 = position2 & size2;

      final collide = (position1.dx < position2.dx + size2.width &&
          position1.dx + size1.width > position2.dx &&
          position1.dy < position2.dy + size2.height &&
          position1.dy + size1.height > position2.dy);

      final overlap = rectOverlap(rect1, rect2);

      if (overlap == true) {
        print(
            '\nContainers collide: $position1, $size1, $position2, $size2, $collide $overlap <<<<<<<<\n');
      } else {
        //print('\nContainers collide: $position1, $position2\n');
      }
      result = overlap;
    }

    return result;
  }

  bool rectOverlap(Rect A, Rect B) {
    bool xOverlap = valueInRange(A.center.dx.toInt(), B.center.dx.toInt(),
            B.center.dx.toInt() + (B.width * 0.5).toInt()) ||
        valueInRange(B.center.dx.toInt(), A.center.dx.toInt(),
            A.center.dx.toInt() + (A.width * 0.5).toInt());

    bool yOverlap = valueInRange(A.center.dy.toInt(), B.center.dy.toInt(),
            B.center.dy.toInt() + (B.height * 0.5).toInt()) ||
        valueInRange(B.center.dy.toInt(), A.center.dy.toInt(),
            A.center.dy.toInt() + (A.height * 0.5).toInt());

    return xOverlap && yOverlap;
  }

  bool valueInRange(int value, int min, int max) {
    return (value >= min) && (value <= max);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return GestureDetector(
            onPanStart: (details) => _onPanStart(context, details),
            //onPanUpdate: (details) => _onPanUpdate(context, details, position),
            onPanEnd: (details) => _onPanEnd(context, details),
            onPanCancel: () => _onPanCancel(context),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      height: viewportConstraints.maxHeight - 80,
                      child: Stack(children: [])),
                  LinearProgressIndicator(
                    value: timerValue,
                    backgroundColor: Colors.purple,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                    minHeight: 5.0,
                  ),
                ]));
      }),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
