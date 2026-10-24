import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/assistant_state_manager.dart';
import '../../models/assistant_state.dart';
import '../../widgets/vrm_avatar_widget.dart';

class JXConnectingScreen extends StatefulWidget {
  final VoidCallback? onOnline;

  const JXConnectingScreen({super.key, this.onOnline});

  @override
  State<JXConnectingScreen> createState() => _JXConnectingScreenState();
}

class _JXConnectingScreenState extends State<JXConnectingScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Listen to state changes
    AssistantStateManager.instance.addListener(_handleStateChange);
  }

  void _handleStateChange() {
    if (AssistantStateManager.instance.state == AssistantConnectionState.online) {
      if (widget.onOnline != null) {
        widget.onOnline!();
      }
    }
  }

  @override
  void dispose() {
    AssistantStateManager.instance.removeListener(_handleStateChange);
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AssistantStateManager.instance,
      builder: (context, child) {
        final initSteps = AssistantStateManager.instance.initSteps;

        return Scaffold(
          backgroundColor: const Color(0xFF080C14),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Title
                  Column(
                    children: [
                      const Text(
                        'JX AI',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF00F2FE),
                          letterSpacing: 4,
                          shadows: [
                            Shadow(color: Color(0xFF00F2FE), blurRadius: 16),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF007A),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Color(0xFFFF007A), blurRadius: 8),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'CONNECTING...',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF007A),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Center Neural Rings & Avatar
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Rotating Neural Ring
                      RotationTransition(
                        turns: _rotationController,
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.3), width: 1.5),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 0,
                                left: 120,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00F2FE),
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Color(0xFF00F2FE), blurRadius: 6)],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 120,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF007A),
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Color(0xFFFF007A), blurRadius: 6)],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Inner Pulsing Glow
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 210 + (_pulseController.value * 16),
                            height: 210 + (_pulseController.value * 16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00F2FE).withOpacity(0.2 * _pulseController.value),
                                  blurRadius: 28,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Center VRM Avatar
                      const VRMAvatarWidget(
                        emotion: 'surprised',
                        width: 190,
                        height: 190,
                      ),
                    ],
                  ),

                  // Live Sequential Checklist Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121826),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(LucideIcons.activity, size: 14, color: Color(0xFF00F2FE)),
                            SizedBox(width: 8),
                            Text(
                              'SYSTEM INITIALIZATION CHECKLIST',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00F2FE),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Grid of checklist items
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: initSteps.entries.map((entry) {
                            final isDone = entry.value;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDone ? const Color(0xFF00F2FE).withOpacity(0.12) : const Color(0xFF080C14),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDone ? const Color(0xFF00F2FE).withOpacity(0.6) : Colors.white12,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isDone ? LucideIcons.checkCircle2 : LucideIcons.circleDot,
                                    size: 13,
                                    color: isDone ? const Color(0xFF00F2FE) : Colors.white38,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      color: isDone ? Colors.white : Colors.white54,
                                      fontSize: 11,
                                      fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Waveform Status
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF007A)),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Calibrating Gemini Neural Channels & Android Bridge...',
                        style: TextStyle(fontSize: 11, color: Colors.white54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
