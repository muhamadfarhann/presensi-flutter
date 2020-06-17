import 'dart:math';
import 'package:flutter/material.dart';
import 'package:presensi/src/widget/custom_clipper.dart';

class BezierContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Transform.rotate(
        angle: -pi / 5,
        child: ClipPath(
        clipper: ClipPainter(),
        child: Container(
          height: MediaQuery.of(context).size.height * .50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF29B6FC), Color(0xFF2979FF)]
            ),
          ),
        ),
        ),
      ),
    );
  }
}