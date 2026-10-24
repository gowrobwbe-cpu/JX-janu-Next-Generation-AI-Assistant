import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/secure_storage_service.dart';
import '../../services/gemini_service.dart';
import '../../services/assistant_state_manager.dart';
import '../../models/assistant_state.dart';

class GeminiSetupScreen extends StatefulWidget {
  final VoidCallback? onConnected;

  const GeminiSetupScreen({super.key, this.onConnected});

  @override
  State<GeminiSetupScreen> createState() => _GeminiSetupScreenState();
}

class _GeminiSetupScreenState extends State<GeminiSetupScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _obscureKey = true;
  bool _isTesting = false;
  bool _isSaving = false;
  String? _testResult;
  bool _isTestSuccessful = false;

  String _selectedModel = 'gemini-1.5-flash';
  String _selectedLanguage = 'Auto';

  final List<String> _models = [
    'gemini-1.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-pro',
  ];

  final List<String> _languages = [
    'Auto',
    'বাংলা',
    'English',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingConfig();
  }

  Future<void> _loadExistingConfig() async {
    final key = await SecureStorageService.instance.getApiKey();
    final model = await SecureStorageService.instance.getSelectedModel();
    final lang = await SecureStorageService.instance.getLanguage();

    setState(() {
      if (key != null) _apiKeyController.text = key;
      _selectedModel = model;
      _selectedLanguage = lang;
      if (key != null && key.isNotEmpty) {
        _isTestSuccessful = true;
        _testResult = '✓ Saved Key Detected';
      }
    });
  }

  Future<void> _testConnection() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _testResult = '✕ Please enter your Gemini API Key first.';
        _isTestSuccessful = false;
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final res = await GeminiService.testConnection(
      apiKey: key,
      modelName: _selectedModel,
    );

    if (!mounted) return;

    setState(() {
      _isTesting = false;
      _isTestSuccessful = res.success;
      _testResult = res.message;
    });
  }

  Future<void> _connectJX() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _testResult = '✕ Gemini API key is required to connect JX.';
        _isTestSuccessful = false;
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Save encrypted to Android Keystore
    await SecureStorageService.instance.saveApiKey(key);
    await SecureStorageService.instance.saveSelectedModel(_selectedModel);
    await SecureStorageService.instance.saveLanguage(_selectedLanguage);

    if (!mounted) return;

    if (widget.onConnected != null) {
      widget.onConnected!();
    } else {
      AssistantStateManager.instance.setState(AssistantConnectionState.permissionsRequired);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'JX AI Brain',
          style: TextStyle(
            color: Color(0xFF00F2FE),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isTestSuccessful ? const Color(0xFF00F2FE).withOpacity(0.15) : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isTestSuccessful ? const Color(0xFF00F2FE) : Colors.redAccent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isTestSuccessful ? const Color(0xFF00F2FE) : Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isTestSuccessful ? 'Connected' : 'Not Connected',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _isTestSuccessful ? const Color(0xFF00F2FE) : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configure your Gemini neural engine to power JX\'s intelligence, voice replies, and tool interactions.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
              ),

              const SizedBox(height: 24),

              // API Key Field
              const Text(
                'GEMINI API KEY',
                style: TextStyle(
                  color: Color(0xFFFF007A),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _apiKeyController,
                obscureText: _obscureKey,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'AIzaSy...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF121826),
                  prefixIcon: const Icon(LucideIcons.key, color: Color(0xFFFF007A), size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureKey ? LucideIcons.eyeOff : LucideIcons.eye,
                      color: Colors.white54,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscureKey = !_obscureKey),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF007A)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Model Selector
              const Text(
                'MODEL SELECTION',
                style: TextStyle(
                  color: Color(0xFF00F2FE),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121826),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedModel,
                    dropdownColor: const Color(0xFF121826),
                    isExpanded: true,
                    icon: const Icon(LucideIcons.chevronDown, color: Color(0xFF00F2FE)),
                    items: _models.map((model) {
                      return DropdownMenuItem<String>(
                        value: model,
                        child: Text(
                          model,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedModel = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Language Selector
              const Text(
                'LANGUAGE',
                style: TextStyle(
                  color: Color(0xFF7000FF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121826),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    dropdownColor: const Color(0xFF121826),
                    isExpanded: true,
                    icon: const Icon(LucideIcons.chevronDown, color: Color(0xFF7000FF)),
                    items: _languages.map((lang) {
                      return DropdownMenuItem<String>(
                        value: lang,
                        child: Text(
                          lang,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLanguage = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Test Result Display
              if (_testResult != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _isTestSuccessful ? const Color(0xFF00F2FE).withOpacity(0.12) : Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isTestSuccessful ? const Color(0xFF00F2FE) : Colors.redAccent,
                    ),
                  ),
                  child: Text(
                    _testResult!,
                    style: TextStyle(
                      color: _isTestSuccessful ? const Color(0xFF00F2FE) : Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _isTesting ? null : _testConnection,
                        icon: _isTesting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00F2FE)),
                              )
                            : const Icon(LucideIcons.sparkles, size: 16),
                        label: const Text('TEST CONNECTION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00F2FE),
                          side: const BorderSide(color: Color(0xFF00F2FE)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _connectJX,
                        icon: const Icon(LucideIcons.arrowRight, size: 16),
                        label: const Text('CONNECT JX', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF007A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
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
