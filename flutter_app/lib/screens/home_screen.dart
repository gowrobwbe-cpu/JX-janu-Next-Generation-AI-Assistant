import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/vrm_avatar_widget.dart';
import '../widgets/neon_components.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Status Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00F2FE),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Color(0xFF00F2FE), blurRadius: 8),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'JX AI • ONLINE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00F2FE),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.settings, color: Color(0xFFFF007A)),
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Title Greeting
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'Welcome Back, ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: Colors.white70,
                  ),
                  children: [
                    TextSpan(
                      text: 'Gowrob! 💕\n',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF007A),
                      ),
                    ),
                    TextSpan(
                      text: 'I am JX, your AI anime companion.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF00F2FE),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3D VRM Anime Companion Avatar Widget
              const VRMAvatarWidget(
                emotion: 'happy',
                isSpeaking: false,
                width: 250,
                height: 250,
              ),

              const SizedBox(height: 32),

              // Quick Voice Mode Launch Banner
              NeonContainer(
                borderColor: const Color(0xFFFF007A),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.mic, color: Color(0xFFFF007A), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'REAL-TIME VOICE MODE',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF007A),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Talk naturally in Bengali or English with continuous voice conversation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    NeonButton(
                      label: 'START VOICE CHAT',
                      icon: LucideIcons.volume2,
                      glowColor: const Color(0xFFFF007A),
                      onPressed: () => Navigator.pushNamed(context, '/voice'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Action Navigation Grid
              Row(
                children: [
                  Expanded(
                    child: NeonButton(
                      label: 'AI MESSENGER',
                      icon: LucideIcons.messageSquare,
                      glowColor: const Color(0xFF00F2FE),
                      onPressed: () => Navigator.pushNamed(context, '/chat'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeonButton(
                      label: 'SETTINGS',
                      icon: LucideIcons.sliders,
                      glowColor: const Color(0xFF7000FF),
                      isPrimary: false,
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Device Test Center & Control Engine Shortcut
              Row(
                children: [
                  Expanded(
                    child: NeonButton(
                      label: 'DEVICE TEST CENTER (22)',
                      icon: LucideIcons.cpu,
                      glowColor: const Color(0xFF00FFCC),
                      isPrimary: false,
                      onPressed: () => Navigator.pushNamed(context, '/device-test-center'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
