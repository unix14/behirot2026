import 'package:flutter/material.dart';

class WhatsAppIcon extends StatelessWidget {
  final double size;

  const WhatsAppIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(color: Color(0xFF25D366), shape: BoxShape.circle),
          ),
          Positioned(
            bottom: size * 0.04,
            left: size * 0.05,
            child: Transform.rotate(
              angle: 0.6,
              child: Container(
                width: size * 0.32,
                height: size * 0.32,
                decoration: const BoxDecoration(color: Color(0xFF25D366), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(2))),
              ),
            ),
          ),
          Center(
            child: Transform.rotate(
              angle: -0.1,
              child: Icon(Icons.call_rounded, color: Colors.white, size: size * 0.58),
            ),
          ),
        ],
      ),
    );
  }
}
