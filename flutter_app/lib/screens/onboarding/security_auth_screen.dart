import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/security_service.dart';
import '../../services/assistant_state_manager.dart';
import '../../widgets/vrm_avatar_widget.dart';
import '../../widgets/neon_components.dart';

class SecurityAuthScreen extends StatefulWidget {
  final VoidCallback? onAuthenticated;

  const SecurityAuthScreen({super.key, this.onAuthenticated});

  @override
  State<SecurityAuthScreen> createState() => _SecurityAuthScreenState();
}

class _SecurityAuthScreenState extends State<SecurityAuthScreen> with SingleTickerProviderStateMixin {
  bool _isAuthenticating = false;
  String? _errorMessage;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthenticate() async {
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    final result = await SecurityService.instance.authenticate(
      reason: 'Verify your identity to open JX Secure Personal Assistant',
    );

    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
    });

    if (result.success) {
      if (widget.onAuthenticated != null) {
        widget.onAuthenticated!();
      } else {
        await AssistantStateManager.instance.onAuthenticated();
      }
    } else {
      setState(() {
        _errorMessage = result.errorMessage ?? 'Authentication failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Column(
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'JX AI',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF00F2FE),
                      letterSpacing: 4,
                      shadows: [
                        Shadow(color: Color(0xFF00F2FE), blurRadius: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, py: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121826),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFF007A).withOpacity(0.4)),
                    ),
                    child: const Text(
                      'Secure Personal Assistant',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF007A),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),

              // Center Avatar & Biometric Glow
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 220 + (_pulseController.value * 20),
                            height: 220 + (_pulseController.value * 20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00F2FE).withOpacity(0.25 * _pulseController.value),
                                  blurRadius: 36,
                                  spreadRadius: 8,
                                ),
                                BoxShadow(
                                  color: const Color(0xFFFF007A).withOpacity(0.2 * (1 - _pulseController.value)),
                                  blurRadius: 36,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const VRMAvatarWidget(
                        emotion: 'cute',
                        width: 220,
                        height: 220,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.lock, size: 16, color: Color(0xFF00F2FE)),
                      const SizedBox(width: 8),
                      Text(
                        '🔐 Secure Access',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Biometric, Fingerprint, Pattern, or Device PIN via Android OS',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.white54),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.alertCircle, size: 14, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              // Bottom Authenticate Action
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isAuthenticating ? null : _handleAuthenticate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00F2FE),
                        foregroundColor: const Color(0xFF080C14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 8,
                        shadowColor: const Color(0xFF00F2FE).withOpacity(0.6),
                      ),
                      child: _isAuthenticating
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF080C14)),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'VERIFYING IDENTITY...',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.fingerprint, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'AUTHENTICATE',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Protected by Android Keystore & BiometricPrompt. No PINs stored.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.white30),
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
