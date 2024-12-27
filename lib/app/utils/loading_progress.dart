import 'package:flutter/material.dart';

class LoadingProgressIndicator extends StatelessWidget {
  final double value;
  final String? label;
  final bool showCancelButton;
  final void Function()? onCancel;

  LoadingProgressIndicator({
    Key? key,
    double? value,
    this.label,
    this.showCancelButton = false,
    this.onCancel,
  })  : value = value ?? 0,
        super(key: key) {
    if (value != null && value > 1) {
      throw ArgumentError("Value must between 0 and 1");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 8,
          ),
          LinearProgressIndicator(
            backgroundColor: Colors.blue.withOpacity(0.25),
            color: Colors.blue,
            value: value,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            label ?? "Uploading ${(value * 100).toInt()}%",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          showCancelButton
              ? Theme(
                  data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                    primary: Colors.red, // header background color
                    onPrimary: Colors.white, // header text color
                  )),
                  child: ElevatedButton(
                    onPressed: onCancel,
                    child: const Text("Batalkan"),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
