import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/android_tool_models.dart';
import '../models/chat_message.dart';
import '../services/android_tool_router.dart';
import '../services/database_service.dart';
import '../services/gemini_service.dart';
import '../services/secure_storage_service.dart';
import '../services/voice_service.dart';
import '../widgets/action_confirmation_dialog.dart';
import '../widgets/action_hud.dart';
import '../widgets/vrm_avatar_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _apiKey = '';
  String _model = 'gemini-1.5-flash';
  String _lang = 'Auto';

  final AndroidToolRouter _router = AndroidToolRouter.instance;
  ActionHUDState _currentHUD = ActionHUDState.idle();

  @override
  void initState() {
    super.initState();
    _loadApiKeyAndMessages();
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

  Future<void> _loadApiKeyAndMessages() async {
    final key = await SecureStorageService.instance.getGeminiApiKey() ?? '';
    final m = await SecureStorageService.instance.getGeminiModel() ?? 'gemini-1.5-flash';
    final l = await SecureStorageService.instance.getPreferredLanguage() ?? 'Auto';
    final history = await DatabaseService.instance.getMessages();

    setState(() {
      _apiKey = key;
      _model = m;
      _lang = l;
      if (history.isNotEmpty) {
        _messages.addAll(history);
      } else {
        _messages.add(
          ChatMessage(
            id: 'welcome-1',
            text: "Hi Gowrob! 💕 I'm JX, your intelligent Android companion. You can ask me to open apps, search YouTube/Google, prepare WhatsApp messages, dial contacts, or adjust volume in Bengali or English!",
            sender: MessageSender.jx,
            timestamp: DateTime.now(),
            emotion: EmotionState.happy,
          ),
        );
      }
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage([String? overrideText]) async {
    final text = overrideText ?? _textController.text.trim();
    if (text.isEmpty) return;

    if (overrideText == null) _textController.clear();

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });

    await DatabaseService.instance.insertMessage(userMsg);
    _scrollToBottom();

    // Call Agentic Gemini Service
    final gemini = GeminiService(apiKey: _apiKey, modelName: _model, preferredLanguage: _lang);
    final result = await gemini.processAgenticPrompt(
      text,
      onConfirmationRequired: (call, risk, desc) async {
        return await ActionConfirmationDialog.show(
          context,
          toolCall: call,
          riskLevel: risk,
          description: desc,
        );
      },
    );

    final jxMsg = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: result.text,
      sender: MessageSender.jx,
      timestamp: DateTime.now(),
      emotion: EmotionState.cute,
    );

    setState(() {
      _messages.add(jxMsg);
      _isLoading = false;
    });

    await DatabaseService.instance.insertMessage(jxMsg);
    _scrollToBottom();

    // Speak response
    await VoiceService.instance.speak(result.text);
  }

  void _listenVoiceInput() async {
    final voice = VoiceService.instance;
    if (voice.isListening) {
      await voice.stopListening();
      setState(() {});
    } else {
      await voice.startListening(
        onResult: (text) {
          if (text.isNotEmpty) {
            _handleSendMessage(text);
          }
        },
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121826),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF00F2FE)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const VRMAvatarWidget(width: 36, height: 36, emotion: 'happy'),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JX AI Assistant',
                  style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Android Control Engine Active 💕',
                  style: GoogleFonts.rajdhani(fontSize: 11, color: const Color(0xFF00FFCC), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.terminal, color: Color(0xFF00FFCC), size: 20),
            onPressed: () => Navigator.pushNamed(context, '/debug-tools'),
            tooltip: 'Android Tools Tester',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Chat Messages List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg.sender == MessageSender.user;

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? const Color(0xFF00F2FE).withOpacity(0.18)
                              : const Color(0xFFFF007A).withOpacity(0.15),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 16),
                          ),
                          border: Border.all(
                            color: isUser ? const Color(0xFF00F2FE) : const Color(0xFFFF007A),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          msg.text,
                          style: GoogleFonts.rajdhani(
                            fontSize: 15,
                            color: Colors.white,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF007A)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'JX is executing for Gowrob...',
                        style: GoogleFonts.rajdhani(fontSize: 13, color: const Color(0xFFFF007A), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

              // Message Input Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                color: const Color(0xFF121826),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          VoiceService.instance.isListening ? LucideIcons.micOff : LucideIcons.mic,
                          color: VoiceService.instance.isListening ? Colors.redAccent : const Color(0xFFFF007A),
                        ),
                        onPressed: _listenVoiceInput,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'e.g. YouTube খোলো or search web...',
                            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                            filled: true,
                            fillColor: const Color(0xFF080C14),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: Color(0xFF00F2FE)),
                            ),
                          ),
                          onSubmitted: (_) => _handleSendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(LucideIcons.send, color: Color(0xFF00F2FE)),
                        onPressed: () => _handleSendMessage(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Action HUD
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
