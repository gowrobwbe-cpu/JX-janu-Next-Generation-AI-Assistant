import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/user_memory.dart';
import '../services/database_service.dart';
import '../services/security_service.dart';
import '../services/secure_storage_service.dart';
import '../services/assistant_state_manager.dart';
import '../models/assistant_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  List<UserMemory> _memories = [];
  bool _saved = false;
  bool _appLockEnabled = false;
  String _selectedModel = 'gemini-1.5-flash';
  String _selectedLanguage = 'Auto';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final key = await SecureStorageService.instance.getGeminiApiKey() ?? '';
    final model = await SecureStorageService.instance.getGeminiModel() ?? 'gemini-1.5-flash';
    final lang = await SecureStorageService.instance.getPreferredLanguage() ?? 'Auto';
    final lock = await SecurityService.instance.isAppLockEnabled();
    final memories = await DatabaseService.instance.getAllMemories();

    setState(() {
      _apiKeyController.text = key;
      _selectedModel = model;
      _selectedLanguage = lang;
      _appLockEnabled = lock;
      _memories = memories;
    });
  }

  Future<void> _saveSettings() async {
    await SecureStorageService.instance.saveGeminiApiKey(_apiKeyController.text.trim());
    await SecureStorageService.instance.saveGeminiModel(_selectedModel);
    await SecureStorageService.instance.savePreferredLanguage(_selectedLanguage);
    await SecurityService.instance.setAppLockEnabled(_appLockEnabled);

    setState(() {
      _saved = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  Future<void> _toggleAppLock(bool value) async {
    if (value) {
      final res = await SecurityService.instance.authenticate(
        reason: 'Authenticate to enable JX App Lock',
      );
      if (res.success) {
        setState(() => _appLockEnabled = true);
        await SecurityService.instance.setAppLockEnabled(true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.errorMessage ?? 'Authentication required to enable lock.')),
          );
        }
      }
    } else {
      setState(() => _appLockEnabled = false);
      await SecurityService.instance.setAppLockEnabled(false);
    }
  }

  Future<void> _clearMemory() async {
    await DatabaseService.instance.clearAllMemory();
    await _loadSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All local conversation memory cleared!')),
      );
    }
  }

  Future<void> _resetOnboarding() async {
    await SecurityService.instance.setFirstRunCompleted(false);
    AssistantStateManager.instance.setState(AssistantConnectionState.authRequired);
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121826),
        title: Text(
          'Settings & Assistant Hub',
          style: GoogleFonts.orbitron(color: const Color(0xFF00F2FE), fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Phase 3 Android Control Engine Test Center Tile
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131424),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF00FFCC), width: 1.5),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF00FFCC).withOpacity(0.15), blurRadius: 16),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FFCC).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.cpu, color: Color(0xFF00FFCC), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ANDROID CONTROL ENGINE',
                          style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF00FFCC)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Test 12 native Android tools, intents & Accessibility',
                          style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/device-test-center'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FFCC),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'TEST 22',
                      style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // App Lock & Biometrics Section
            Text(
              'SECURITY & APP LOCK',
              style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF00F2FE), letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF121826),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('App Lock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Require Biometric/PIN on open', style: TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                      Switch(
                        value: _appLockEnabled,
                        activeColor: const Color(0xFF00F2FE),
                        onChanged: _toggleAppLock,
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 20),
                  const Row(
                    children: [
                      Icon(LucideIcons.shieldCheck, size: 16, color: Color(0xFF00F2FE)),
                      SizedBox(width: 8),
                      Text(
                        'Authentication: Biometric / Device Credential',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // API & Model Section
            Text(
              'GEMINI AI BRAIN CONFIGURATION',
              style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFFF007A), letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF121826),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gemini API Key (Stored in Android Keystore)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Enter your Gemini API key...',
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: const Color(0xFF080C14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Model', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedModel,
                    dropdownColor: const Color(0xFF121826),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF080C14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'gemini-1.5-flash', child: Text('gemini-1.5-flash (Fast & Responsive)')),
                      DropdownMenuItem(value: 'gemini-2.0-flash', child: Text('gemini-2.0-flash (Next-Gen)')),
                      DropdownMenuItem(value: 'gemini-1.5-pro', child: Text('gemini-1.5-pro (High Precision)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedModel = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Language Preference', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    dropdownColor: const Color(0xFF121826),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF080C14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Auto', child: Text('Auto (Detect Bengali / English)')),
                      DropdownMenuItem(value: 'বাংলা', child: Text('বাংলা (Bengali)')),
                      DropdownMenuItem(value: 'English', child: Text('English')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLanguage = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(LucideIcons.save, size: 16),
                      label: Text(_saved ? 'SAVED TO SECURE STORAGE!' : 'SAVE SETTINGS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00F2FE),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: _saveSettings,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Onboarding & Permissions Section
            Text(
              'FIRST-LAUNCH & PERMISSIONS',
              style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF7000FF), letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF121826),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.shieldAlert, color: Color(0xFF00F2FE)),
                    title: const Text('Launch Onboarding Flow', style: TextStyle(color: Colors.white, fontSize: 13)),
                    subtitle: const Text('Review Security, Gemini setup & Permission cards', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    trailing: const Icon(LucideIcons.chevronRight, color: Colors.white54, size: 18),
                    onTap: () {
                      AssistantStateManager.instance.setState(AssistantConnectionState.permissionsRequired);
                      Navigator.pushNamed(context, '/');
                    },
                  ),
                  const Divider(color: Colors.white10),
                  ListTile(
                    leading: const Icon(LucideIcons.rotateCcw, color: Color(0xFFFF007A)),
                    title: const Text('Reset First-Run State', style: TextStyle(color: Color(0xFFFF007A), fontSize: 13)),
                    subtitle: const Text('Re-trigger initial setup from scratch', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    onTap: _resetOnboarding,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Local Memory System Inspector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LOCAL SQLITE MEMORY',
                  style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF00F2FE)),
                ),
                TextButton.icon(
                  icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.redAccent),
                  label: const Text('CLEAR ALL', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  onPressed: _clearMemory,
                ),
              ],
            ),
            const SizedBox(height: 8),

            _memories.isEmpty
                ? const Text('No stored memory records found.', style: TextStyle(color: Colors.white38))
                : Column(
                    children: _memories.map((m) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121826),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.key,
                                  style: const TextStyle(color: Color(0xFFFF007A), fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  m.value,
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.x, size: 16, color: Colors.white38),
                              onPressed: () async {
                                await DatabaseService.instance.deleteMemory(m.key);
                                _loadSettings();
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
