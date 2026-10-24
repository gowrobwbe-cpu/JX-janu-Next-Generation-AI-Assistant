import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/vrm_avatar_widget.dart';
import '../../widgets/neon_components.dart';

class JXOnlineScreen extends StatelessWidget {
  const JXOnlineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                            BoxShadow(color: Color(0xFF00F2FE), blurRadius: 10, spreadRadius: 2),
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
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.settings, color: Color(0xFFFF007A), size: 20),
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Title Greeting
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'Hi Gowrob, ',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w300,
                    color: Colors.white70,
                  ),
                  children: [
                    TextSpan(
                      text: "I'm ready! 💕\n",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF007A),
                      ),
                    ),
                    TextSpan(
                      text: 'Your secure Android Personal Assistant & Companion',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF00F2FE),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3D VRM Anime Companion Avatar Widget
              const VRMAvatarWidget(
                emotion: 'happy',
                isSpeaking: false,
                width: 240,
                height: 240,
              ),

              const SizedBox(height: 24),

              // Primary Voice Talk Banner
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/voice'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF007A), Color(0xFF7000FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF007A).withOpacity(0.4),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.mic, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'TALK WITH JX',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4 Action Buttons Grid (CHAT, VISION, ACTIONS, SETTINGS)
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'CHAT',
                      icon: LucideIcons.messageSquare,
                      color: const Color(0xFF00F2FE),
                      onTap: () => Navigator.pushNamed(context, '/chat'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      label: 'VISION',
                      icon: LucideIcons.eye,
                      color: const Color(0xFFFF007A),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Camera Vision viewfinder launched! 📸')),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'ACTIONS',
                      icon: LucideIcons.zap,
                      color: const Color(0xFF7000FF),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Android Intent & Tool Engine Active ⚡')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      label: 'SETTINGS',
                      icon: LucideIcons.sliders,
                      color: Colors.white70,
                      onTap: () => Navigator.pushNamed(context, '/settings'),
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

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFF121826),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
