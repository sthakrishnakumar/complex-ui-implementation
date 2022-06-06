import 'dart:math';

import 'package:flutter/material.dart';

class FlipDrawer extends StatefulWidget {
  const FlipDrawer({Key? key}) : super(key: key);

  @override
  State<FlipDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<FlipDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  bool? canBeDragged;
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  void toggle() => animationController.isDismissed
      ? animationController.forward()
      : animationController.reverse();

  final double maxSlide = 225.0;
  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft =
        animationController.isDismissed && details.globalPosition.dx < 0;
    bool isDragCloseFromRight =
        animationController.isCompleted && details.globalPosition.dx > 225.0;

    canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (canBeDragged!) {
      double delta = details.primaryDelta! / maxSlide;
      animationController.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (animationController.isDismissed || animationController.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= 365.0) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.width;
      animationController.fling(velocity: visualVelocity);
    } else if (animationController.value < 0.5) {
      // close();
    } else {
      // open();
    }
  }

  double dragPosition = 0;
  @override
  Widget build(BuildContext context) {
    var myDrawer = Container(
      color: Colors.blue,
    );
    var myChild = Container(
      color: Colors.yellow,
    );
    return GestureDetector(
      onTap: toggle,
      // onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: (details) => setState(() {
        dragPosition -= details.delta.dx;
        dragPosition %= 360;
      }),
      // onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, _) {
          double slide = maxSlide * animationController.value;
          double scale = 1 - (animationController.value * 0.3);

          return Stack(
            children: [
              myDrawer,
              Transform.translate(
                offset: Offset(maxSlide * (animationController.value - 1), 0),
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(-pi / 2 * (1 - animationController.value)),
                  alignment: Alignment.centerLeft,
                  child: myChild,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
