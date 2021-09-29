
//@dart=2.10
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focussss',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List<FocusNode> focusNode = [];
  final stackKey = GlobalKey();
  IndicatorController indicatorController;

  @override
  void initState() {
    super.initState();
    indicatorController = IndicatorController(this);
    for (var i = 0; i < 5; i++) {
      final node = FocusNode();
      focusNode.add(node);
      node.addListener(() {
        insert(node);
      });
    }
  }

  void insert(FocusNode node) {
    if (!node.hasFocus) {
      return;
    }
    final nodeRenderBox = node.context.findRenderObject() as RenderBox;
    final stackRenderBox =
    stackKey.currentContext.findRenderObject() as RenderBox;
    final stackPosition = stackRenderBox.localToGlobal(Offset.zero);
    if (stackPosition == null) {
      return;
    }
    final nodePosition = nodeRenderBox.globalToLocal(stackPosition);
    final height = nodeRenderBox.size.height;
    final position = Offset(
      -nodePosition.dx - 30,
      -nodePosition.dy + height / 2,
    );
    indicatorController.updatePosition(position);
  }

  @override
  void dispose() {
    for (final element in focusNode) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 250),
          child: AnimatedBuilder(
            animation: indicatorController,
            builder: (context, child) {
              return Indicator(
                key: stackKey,
                position: indicatorController.position,
                previousPositions: indicatorController.previousPositions,
                child: child,
              );
            },
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Name'),
                ),
                NameField(focusNode: focusNode[0]),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Email'),
                ),
                EmailField(focusNode: focusNode[1]),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Password'),
                ),
                PasswordField(focusNode: focusNode[2]),
                RememberMeCheckbox(focusNode: focusNode[3]),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    focusNode: focusNode[4],
                    onPressed: () {},
                    child: const Text('Save'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RememberMeCheckbox extends StatelessWidget {
  const RememberMeCheckbox({
    Key key,
    @required this.focusNode,
  }) : super(key: key);

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          focusNode: focusNode,
          value: false,
          onChanged: (_) {},
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Remember me'),
        ),
      ],
    );
  }
}

class PasswordField extends StatelessWidget {
  const PasswordField({
    Key key,
    @required this.focusNode,
  }) : super(key: key);

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      decoration: const InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide.none),
        filled: true,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value != null && value.length < 5) {
          return 'Oh no, password too short';
        }
        return null;
      },
    );
  }
}

class EmailField extends StatelessWidget {
  const EmailField({
    Key key,
    @required this.focusNode,
  }) : super(key: key);

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      decoration: const InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide.none),
        filled: true,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value != null && !value.contains('@')) {
          return 'Oh no, @ is missing';
        }
        return null;
      },
    );
  }
}

class NameField extends StatelessWidget {
  const NameField({
    Key key,
    @required this.focusNode,
  }) : super(key: key);

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      decoration: const InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide.none),
        filled: true,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value != null && value.isEmpty) {
          return 'Oh no, wrong name';
        }
        return null;
      },
    );
  }
}



class Indicator extends StatelessWidget {
  const Indicator({
    Key key,
    @required this.position,
    @required this.previousPositions,
    @required this.child,
  }) : super(key: key);

  final Offset position;
  final List<Offset> previousPositions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: IndicatorPainter(position, previousPositions),
      child: child,
    );
  }
}

class IndicatorPainter extends CustomPainter {
  IndicatorPainter(this.position, this.previousPositions);

  final Offset position;
  final List<Offset> previousPositions;

  @override
  void paint(Canvas canvas, Size size) {
    if (position == null) {
      return;
    }

    final curve = Path();
    if (previousPositions.isNotEmpty) {
      final start = previousPositions[0];
      curve.moveTo(start.dx, start.dy);

      for (final point in previousPositions) {
        curve.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(
      curve,
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4,
    );
    canvas.drawCircle(position, 10, Paint()..color = Colors.blue);
  }

  @override
  bool shouldRepaint(covariant IndicatorPainter oldDelegate) {
    return true;
  }
}

class IndicatorController extends ChangeNotifier {
  IndicatorController(TickerProvider vsync) : _vsync = vsync {
    _animationController = AnimationController(
      vsync: vsync,
      duration: moveDuration,
      upperBound: 1,
    );
  }

  final TickerProvider _vsync;
  AnimationController _animationController;
  final Duration moveDuration = const Duration(milliseconds: 300);

  Offset _targetPosition;
  Offset _initialPosition;
  Offset position;
  List<Offset> previousPositions = [];

  void updatePosition(Offset newPosition) {
    if (_initialPosition == null) {
      _initialPosition = newPosition;
    } else {
      _initialPosition = position;
    }
    _targetPosition = newPosition;

    _startAnimation();
  }

  void _startAnimation() {
    _animationController.reset();
    _animationController.removeListener(_onTick);
    _animationController.addListener(_onTick);
    _animationController.forward();
  }

  void _onTick() {
    final yTween = Tween<double>(
      begin: _initialPosition.dy,
      end: _targetPosition.dy,
    );
    final xTween = Tween<double>(
      begin: _initialPosition.dx,
      end: _targetPosition.dx,
    );
    final curve = CurveTween(curve: Curves.easeInOut);
    final yAnimation = _animationController.drive(curve).drive(yTween);
    final yDistance = yAnimation.value;
    final absXDistance = (_initialPosition.dx - _targetPosition.dx).abs();
    final sinCurve = SineCurve(count: 0.5, multiplier: 20 + absXDistance / 3);
    final curveAnimation = CurveTween(curve: sinCurve);
    final xAnimation = _animationController.drive(curveAnimation);
    final xPosition = _animationController.drive(xTween);
    final xOffset = -xAnimation.value;
    final xDistance = xPosition.value;

    position = Offset(xDistance + xOffset, yDistance);
    if (previousPositions.length > 10) {
      previousPositions.removeAt(0);
    }
    previousPositions.add(position);

    if ((position - _targetPosition).distanceSquared <= 1.0) {
      _stopAnimation();
    }
    notifyListeners();
  }

  Ticker _ticker;
  void _stopAnimation() {
    if (previousPositions.isNotEmpty) {
      _ticker ??= _vsync.createTicker(settleDown);
      if (_ticker.isActive) {
        return;
      }
      _ticker?.start();
    }
  }

  void settleDown(Duration elapsed) {
    if (previousPositions.isNotEmpty) {
      previousPositions.removeAt(0);
      notifyListeners();
    } else {
      _ticker?.stop();
      _ticker?.dispose();
      _ticker = null;
    }
  }
}

class SineCurve extends Curve {
  const SineCurve({this.count = 3, this.multiplier = 20});

  final double count;
  final double multiplier;

  @override
  double transformInternal(double t) {
    var val = sin(count * 2 * pi * t) * multiplier;
    return val;
  }
}
