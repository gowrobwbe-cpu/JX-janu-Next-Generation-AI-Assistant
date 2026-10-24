import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/android_tool_models.dart';
import '../services/android_tool_router.dart';
import '../services/gemini_service.dart';
import '../services/secure_storage_service.dart';
import '../services/voice_service.dart';
import '../widgets/action_confirmation_dialog.dart';
import '../widgets/action_hud.dart';
import '../widgets/vrm_avatar_widget.dart';

class VoiceModeScreen extends StatefulWidget {
  const VoiceModeScreen({super.key});

  @override
  State<VoiceModeScreen> createState() => _VoiceModeScreenState();
}

class _VoiceModeScreenState extends State<VoiceModeScreen> {
  bool _isContinuousMode = true;
  String _statusText = 'Tap microphone to talk with JX';
  String _lastSpoken = '';
  String _jxReply = '';
  String _apiKey = '';
  String _model = 'gemini-1.5-flash';
  String _lang = 'Auto';

  final AndroidToolRouter _router = AndroidToolRouter.instance;
  ActionHUDState _currentHUD = ActionHUDState.idle();

  @override
  void initState() {
    super.initState();
    _loadConfig();
    _router.addHUDListener(_onHUDUpdate);
  }

  @override
  void dispose() {
    _router.removeHUDListener(_onHUDUpdate);
    super.dispose();
  }

  void _onHUDUpdate(ActionHUDState state) {
    if (mounted) {
      setState(() {
        _currentHUD = state;
      });
    }
  }

  Future<void> _loadConfig() async {
    final key = await SecureStorageService.instance.getGeminiApiKey() ?? '';
    final m = await SecureStorageService.instance.getGeminiModel() ?? 'gemini-1.5-flash';
    final l = await SecureStorageService.instance.getPreferredLanguage() ?? 'Auto';
    if (mounted) {
      setState(() {
        _apiKey = key;
        _model = m;
        _lang = l;
      });
    }
  }

  void _toggleListening() async {
    final voice = VoiceService.instance;
    if (voice.isListening) {
      await voice.stopListening();
      setState(() {
        _statusText = 'Voice session paused.';
      });
    } else {
      setState(() {
        _statusText = 'Listening to Gowrob...';
      });
      await voice.startListening(
        onResult: (recognized) async {
          setState(() {
            _lastSpoken = recognized;
            _statusText = 'JX is processing & executing...';
          });

          // Agentic execution with confirmation support
          final gemini = GeminiService(apiKey: _apiKey, modelName: _model, preferredLanguage: _lang);
          final res = await gemini.processAgenticPrompt(
            recognized,
            onConfirmationRequired: (call, risk, desc) async {
              return await ActionConfirmationDialog.show(
                context,
                toolCall: call,
                riskLevel: risk,
                description: desc,
              );
            },
          );

          setState(() {
            _jxReply = res.text;
            _statusText = 'JX Speaking...';
          });

          // Speak back result
          await voice.speak(res.text);

          if (_isContinuousMode && mounted) {
            setState(() {
              _statusText = 'Listening again...';
            });
            _toggleListening();
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFFFF007A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CONTINUOUS VOICE CONTROL',
          style: GoogleFonts.orbitron(
            color: const Color(0xFFFF007A),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.terminal, color: Color(0xFF00FFCC), size: 20),
            onPressed: () => Navigator.pushNamed(context, '/debug-tools'),
            tooltip: 'Tools Debugger',
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Avatar Section
                  Column(
                    children: [
                      VRMAvatarWidget(
                        emotion: 'cute',
                        isSpeaking: VoiceService.instance.isSpeaking,
                        width: 260,
                        height: 260,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _statusText,
                        style: GoogleFonts.orbitron(
                          color: const Color(0xFF00F2FE),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),

                  // Subtitles & Dialogue Feed
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121826),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFF007A).withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_lastSpoken.isNotEmpty) ...[
                          Text(
                            'Gowrob: $_lastSpoken',
                            style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const Divider(color: Colors.white12, height: 16),
                        ],
                        Text(
                          _jxReply.isEmpty ? "Say e.g. \"YouTube খোলো\" or \"volume বাড়াও\" 💕" : _jxReply,
                          style: GoogleFonts.rajdhani(
                            color: const Color(0xFFFF007A),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Microphone Trigger Button
                  GestureDetector(
                    onTap: _toggleListening,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF007A), Color(0xFF7000FF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF007A).withOpacity(0.6),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        VoiceService.instance.isListening ? LucideIcons.micOff : LucideIcons.mic,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action HUD Overlay
          ActionHUDOverlay(
            state: _currentHUD,
            onDismiss: () {
              setState(() {
                _currentHUD = ActionHUDState.idle();
              });
            },
          ),
        ],
      ),
    );
  }
}
