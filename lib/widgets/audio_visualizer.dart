import 'dart:math';
import 'package:flutter/material.dart';

class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;

  const AudioVisualizer({required this.isPlaying, super.key});

  @override
  _AudioVisualizerState createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBar(double height) {
    return Container(
      width: 4,
      height: height,
      margin: EdgeInsets.symmetric(horizontal: 2),
      color: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying) return SizedBox(height: 20);
    return SizedBox(
      height: 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              10,
              (_) => _buildBar(_random.nextDouble() * 20 + 10),
            ),
          );
        },
      ),
    );
  }
}
