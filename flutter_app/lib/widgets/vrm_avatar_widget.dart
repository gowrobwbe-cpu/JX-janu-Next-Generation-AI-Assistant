import 'package:flutter/material.dart';
import 'dart:math' as math;

class VRMAvatarWidget extends StatefulWidget {
  final String emotion;
  final bool isSpeaking;
  final double width;
  final double height;

  const VRMAvatarWidget({
    super.key,
    this.emotion = 'happy',
    this.isSpeaking = false,
    this.width = 240,
    this.height = 240,
  });

  @override
  State<VRMAvatarWidget> createState() => _VRMAvatarWidgetState();
}

class _VRMAvatarWidgetState extends State<VRMAvatarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isBlinking = false;

  @override
  void initState() {
    super.initState()
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Random blinking timer
    _startBlinkLoop();
  }

  void _startBlinkLoop() async {
    while (mounted) {
      await Future.delayed(Duration(milliseconds: 2000 + math.Random().nextInt(3000)));
      if (mounted) {
        setState(() => _isBlinking = true);
        await Future.delayed(const Duration(milliseconds: 150));
        if (mounted) {
          setState(() => _isBlinking = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getEmotionGlow() {
    switch (widget.emotion) {
      case 'cute':
      case 'happy':
        return const Color(0xFFFF007A);
      case 'excited':
      case 'playful':
        return const Color(0xFF7000FF);
      case 'thinking':
        return const Color(0xFFFFB800);
      default:
        return const Color(0xFF00F2FE);
    }
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = _getEmotionGlow();

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Neon Halo Ring
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = 1.0 + (widget.isSpeaking ? math.sin(_controller.value * math.pi * 8) * 0.08 : math.sin(_controller.value * math.pi * 2) * 0.03);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.width * 0.85,
                  height: widget.height * 0.85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withOpacity(0.5),
                        blurRadius: widget.isSpeaking ? 30 : 18,
                        spreadRadius: widget.isSpeaking ? 8 : 4,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 3D VRM Anime Character Canvas / Container
          Container(
            width: widget.width * 0.8,
            height: widget.height * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  glowColor.withOpacity(0.25),
                  const Color(0xFF121826),
                  const Color(0xFF080C14),
                ],
              ),
              border: Border.all(
                color: glowColor.withOpacity(0.8),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: CustomPaint(
                painter: AnimeAvatarPainter(
                  emotion: widget.emotion,
                  isSpeaking: widget.isSpeaking,
                  isBlinking: _isBlinking,
                  glowColor: glowColor,
                ),
              ),
            ),
          ),

          // VRM 3D Engine Ready Watermark
          Positioned(
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: glowColor.withOpacity(0.5)),
              ),
              child: Text(
                'VRM 3D • JX COMPANION',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: glowColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimeAvatarPainter extends CustomPainter {
  final String emotion;
  final bool isSpeaking;
  final bool isBlinking;
  final Color glowColor;

  AnimeAvatarPainter({
    required this.emotion,
    required this.isSpeaking,
    required this.isBlinking,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Hair Background Glow
    final hairPaint = Paint()..color = const Color(0xFFFF007A);
    canvas.drawCircle(center - const Offset(0, 10), size.width * 0.35, hairPaint);

    // Face Skin Base
    final skinPaint = Paint()..color = const Color(0xFFFFE0D0);
    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(0, 5),
        width: size.width * 0.5,
        height: size.height * 0.52,
      ),
      skinPaint,
    );

    // Eyes (Anime style)
    final eyePaint = Paint()..color = const Color(0xFF00F2FE);
    final pupilPaint = Paint()..color = const Color(0xFF0B0F19);

    if (isBlinking) {
      // Blinking Eyes
      final blinkPaint = Paint()
        ..color = const Color(0xFF333333)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      canvas.drawLine(center + const Offset(-25, -10), center + const Offset(-10, -10), blinkPaint);
      canvas.drawLine(center + const Offset(10, -10), center + const Offset(25, -10), blinkPaint);
    } else {
      // Open Eyes
      canvas.drawOval(
        Rect.fromCenter(center: center + const Offset(-18, -10), width: 14, height: 20),
        eyePaint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: center + const Offset(18, -10), width: 14, height: 20),
        eyePaint,
      );

      // Pupils
      canvas.drawCircle(center + const Offset(-18, -10), 4, pupilPaint);
      canvas.drawCircle(center + const Offset(18, -10), 4, pupilPaint);

      // Eye Highlights
      final highlightPaint = Paint()..color = Colors.white;
      canvas.drawCircle(center + const Offset(-20, -13), 2.5, highlightPaint);
      canvas.drawCircle(center + const Offset(16, -13), 2.5, highlightPaint);
    }

    // Cute Cheeks Blush
    final blushPaint = Paint()..color = const Color(0xFFFF4D8D).withOpacity(0.5);
    canvas.drawOval(Rect.fromCenter(center: center + const Offset(-28, 6), width: 14, height: 8), blushPaint);
    canvas.drawOval(Rect.fromCenter(center: center + const Offset(28, 6), width: 14, height: 8), blushPaint);

    // Mouth (Lip sync & animation)
    final mouthPaint = Paint()
      ..color = const Color(0xFFFF007A)
      ..style = isSpeaking ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.5;

    if (isSpeaking) {
      canvas.drawOval(
        Rect.fromCenter(center: center + const Offset(0, 22), width: 12, height: 14),
        mouthPaint,
      );
    } else {
      final path = Path();
      path.moveTo(center.dx - 8, center.dy + 20);
      path.quadraticBezierTo(center.dx, center.dy + 26, center.dx + 8, center.dy + 20);
      canvas.drawPath(path, mouthPaint);
    }

    // Anime Hair Bangs
    final bangPaint = Paint()..color = const Color(0xFFFF007A);
    final bangPath = Path();
    bangPath.moveTo(center.dx - 35, center.dy - 35);
    bangPath.quadraticBezierTo(center.dx - 15, center.dy - 10, center.dx - 5, center.dy - 20);
    bangPath.quadraticBezierTo(center.dx + 15, center.dy - 10, center.dx + 35, center.dy - 35);
    bangPath.quadraticBezierTo(center.dx, center.dy - 55, center.dx - 35, center.dy - 35);
    canvas.drawPath(bangPath, bangPaint);
  }

  @override
  bool shouldRepaint(covariant AnimeAvatarPainter oldDelegate) {
    return oldDelegate.emotion != emotion ||
        oldDelegate.isSpeaking != isSpeaking ||
        oldDelegate.isBlinking != isBlinking ||
        oldDelegate.glowColor != glowColor;
  }
}
