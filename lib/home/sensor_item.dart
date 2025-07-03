import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

class SensorItem extends StatefulWidget {
  final double width;
  final double height;
  final Widget child;
  const SensorItem({
    super.key,
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  State<SensorItem> createState() => _SensorItemState();
}

class _SensorItemState extends State<SensorItem> {
  final BorderRadius borderRadius = BorderRadius.circular(12);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          colors: [Color(0xffDBE0E7), Color(0xffF8FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xff3B4056).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        child: widget.child,
      ),
    );
  }
}
