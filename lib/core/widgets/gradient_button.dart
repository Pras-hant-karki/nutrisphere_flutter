import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? startColor;
  final Color? endColor;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.startColor,
    this.endColor,
    this.width,
    this.height = 50,
    this.borderRadius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            startColor ?? Colors.blue,
            endColor ?? Colors.purple,
          ],
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          child: Center(
            child: Text(
              label,
              style: textStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
