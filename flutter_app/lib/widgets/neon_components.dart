import 'package:flutter/material.dart';

class NeonButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color glowColor;
  final bool isPrimary;

  const NeonButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.glowColor = const Color(0xFF00F2FE),
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(isPrimary ? 0.4 : 0.15),
            blurRadius: isPrimary ? 16 : 8,
            spreadRadius: isPrimary ? 2 : 0,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? glowColor.withOpacity(0.18) : const Color(0xFF121826),
          foregroundColor: glowColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: glowColor, width: 1.5),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: glowColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: glowColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NeonContainer extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double padding;

  const NeonContainer({
    super.key,
    required this.child,
    this.borderColor = const Color(0xFF00F2FE),
    this.padding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: const Color(0xFF121826).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.12),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}
