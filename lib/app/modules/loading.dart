import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.5),
      child: const Center(
        child: SpinKitThreeInOut(
          color: Color(0xFF001b94),
          size: 50.0,
        ),
      ),
    );
  }
}
