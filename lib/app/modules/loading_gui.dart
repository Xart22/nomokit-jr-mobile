import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingGui extends StatelessWidget {
  const LoadingGui({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF001b94),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SpinKitThreeInOut(
            color: Colors.white,
            size: 50.0,
          ),
          SizedBox(height: 20),
          Text(
            "Loading...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
