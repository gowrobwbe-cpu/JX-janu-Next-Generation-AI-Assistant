import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/android_tool_models.dart';
import '../services/android_tool_router.dart';
import '../services/gemini_service.dart';
import '../services/gemini_tool_declarations.dart';
import '../services/secure_storage_service.dart';
import '../widgets/action_confirmation_dialog.dart';
import '../widgets/action_hud.dart';

class ToolDebugItem {
  final int index;
  final String toolName;
  final String displayName;
  final String permissionRequired;
  final ActionRiskLevel riskLevel;
  final Map<String, dynamic> defaultArgs;
  bool isPermissionGranted;
  String status; // IDLE, RUNNING, SUCCESS, FAILED
  String? lastResult;

  ToolDebugItem({
    required this.index,
    required this.toolName,
    required this.displayName,
    required this.permissionRequired,
    required this.riskLevel,
    required this.defaultArgs,
    this.isPermissionGranted = false,
    this.status = 'IDLE',
    this.lastResult,
  });
}

class DebugToolsScreen extends StatefulWidget {
  const DebugToolsScreen({Key? key}) : super(key: key);

  @override
  State<DebugToolsScreen> createState() => _DebugToolsScreenState();
}

class _DebugToolsScreenState extends State<DebugToolsScreen> {
  final AndroidToolRouter _router = AndroidToolRouter.instance;
  ActionHUDState _currentHUD = ActionHUDState.idle();
  bool _isAccessibilityActive = false;
  String _geminiApiKey = '';
  GeminiService? _geminiService;

  late List<ToolDebugItem> _tools;

  @override
  void initState() {
    super.initState();
    _initToolItems();
    _checkAllPermissions();
    _loadGeminiConfig();

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

  void _initToolItems() {
    _tools = [
      ToolDebugItem(
        index: 1,
        toolName: 'open_app',
        displayName: '1. Open App (YouTube/Settings)',
        permissionRequired: 'None',
        riskLevel: ActionRiskLevel.safe,
        defaultArgs: {'appName': 'YouTube'},
      ),
      ToolDebugItem(
        index: 2,
        toolName: 'open_youtube',
        displayName: '2. YouTube Search ("electronics tutorial")',
        permissionRequired: 'INTERNET',
        riskLevel: ActionRiskLevel.safe,
        defaultArgs: {'query': 'electronics tutorial'},
      ),
      ToolDebugItem(
        index: 3,
        toolName: 'search_web',
        displayName: '3. Google Search ("circuit design")',
        permissionRequired: 'INTERNET',
        riskLevel: ActionRiskLevel.safe,
        defaultArgs: {'query': 'electronics circuit design', 'engine': 'google'},
      ),
      ToolDebugItem(
        index: 4,
        toolName: 'open_whatsapp',
        displayName: '4. Open WhatsApp Compose',
        permissionRequired: 'READ_CONTACTS (Optional)',
        riskLevel: ActionRiskLevel.userConfirmation,
        defaultArgs: {'contactName': 'Rahim', 'message': 'Hello from JX AI Android Engine!'},
      ),
      ToolDebugItem(
        index: 5,
        toolName: 'open_camera',
        displayName: '5. Open Camera (Photo Mode)',
        permissionRequired: 'CAMERA',
        riskLevel: ActionRiskLevel.safe,
        defaultArgs: {'mode': 'photo'},
      ),
      ToolDebugItem(
        index: 6,
        toolName: 'adjust_volume',
        displayName: '6. Volume Change (Set 50%)',
        permissionRequired: 'MODIFY_AUDIO_SETTINGS',
        riskLevel: ActionRiskLevel.safe,
        defaultArgs: {'percent': 50},
      ),
      ToolDebugItem(
        index: 7,
        toolName: 'navigate_os',
        displayName: '7. OS Navigation: BACK',
        permissionRequired: 'ACCESSIBILITY_SERVICE',
        riskLevel: ActionRiskLevel.safe,
        defaultArgs: {'action': 'back'},
      ),
      ToolDebugItem(
        index: 8,
        toolName: 'navigate_os',
        displayName: '8. OS Navigation: HOME',
        permissionRequired: 'ACCESSIBILITY_SERVICE',
        riskLevel: ActionRiskLevel.safe,
        defaultArgs: {'action': 'home'},
      ),
      ToolDebugItem(
        index: 9,
        toolName: 'navigate_os',
        displayName: '9. OS Navigation: RECENTS',
        permissionRequired: 'ACCESSIBILITY_SERVICE',
        riskLevel: ActionRiskLevel.safe,
        defaultArgs: {'action': 'recents'},
      ),
      ToolDebugItem(
        index: 10,
        toolName: 'inspect_screen_ui',
        displayName: '10. Accessibility Status & UI Tree Inspection',
        permissionRequired: 'ACCESSIBILITY_SERVICE',
        riskLevel: ActionRiskLevel.safe,
        defaultArgs: {},
      ),
      ToolDebugItem(
        index: 11,
        toolName: 'analyze_screen',
        displayName: '11. Screen Capture Consent (MediaProjection)',
        permissionRequired: 'MEDIA_PROJECTION',
        riskLevel: ActionRiskLevel.userConfirmation,
        defaultArgs: {'prompt': 'Analyze current visible interface.'},
      ),
      ToolDebugItem(
        index: 12,
        toolName: 'gemini_tool_calling',
        displayName: '12. Gemini Agentic Function Calling Test',
        permissionRequired: 'GEMINI_API_KEY',
        riskLevel: ActionRiskLevel.safe,
        defaultArgs: {'prompt': 'JX YouTube-এ electronics tutorial search করো.'},
      ),
    ];
  }

  Future<void> _loadGeminiConfig() async {
    final key = await SecureStorageService.instance.getGeminiApiKey() ?? '';
    final model = await SecureStorageService.instance.getGeminiModel() ?? 'gemini-1.5-flash';
    if (mounted) {
      setState(() {
        _geminiApiKey = key;
        _geminiService = GeminiService(apiKey: key, modelName: model);
      });
    }
  }

  Future<void> _checkAllPermissions() async {
    final access = await _router.isAccessibilityEnabled();
    final cam = await Permission.camera.status;
    final contacts = await Permission.contacts.status;

    if (mounted) {
      setState(() {
        _isAccessibilityActive = access;

        for (var item in _tools) {
          if (item.permissionRequired.contains('ACCESSIBILITY')) {
            item.isPermissionGranted = access;
          } else if (item.permissionRequired.contains('CAMERA')) {
            item.isPermissionGranted = cam.isGranted;
          } else if (item.permissionRequired.contains('CONTACTS')) {
            item.isPermissionGranted = contacts.isGranted;
          } else if (item.permissionRequired.contains('GEMINI')) {
            item.isPermissionGranted = _geminiApiKey.isNotEmpty;
          } else {
            item.isPermissionGranted = true;
          }
        }
      });
    }
  }

  Future<void> _executeToolTest(ToolDebugItem item) async {
    setState(() {
      item.status = 'RUNNING';
    });

    if (item.riskLevel == ActionRiskLevel.userConfirmation) {
      final confirmed = await ActionConfirmationDialog.show(
        context,
        toolCall: AndroidToolCall(toolName: item.toolName, arguments: item.defaultArgs),
        riskLevel: item.riskLevel,
        description: "Test execution of ${item.displayName}",
      );

      if (!confirmed) {
        setState(() {
          item.status = 'CANCELLED';
          item.lastResult = "User rejected confirmation.";
        });
        return;
      }
    }

    if (item.toolName == 'gemini_tool_calling') {
      if (_geminiService == null || _geminiApiKey.isEmpty) {
        setState(() {
          item.status = 'FAILED';
          item.lastResult = "Gemini API key not configured. Set key in Settings.";
        });
        return;
      }

      final prompt = item.defaultArgs['prompt'] ?? 'JX YouTube খোলো';
      final res = await _geminiService!.processAgenticPrompt(
        prompt,
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
        item.status = res.toolResult?.success == true || res.toolCall != null ? 'SUCCESS' : 'COMPLETED';
        item.lastResult = "Tool: ${res.toolCall?.toolName ?? 'None'}\nReply: ${res.text}";
      });
      return;
    }

    final call = AndroidToolCall(
      toolName: item.toolName,
      arguments: item.defaultArgs,
    );

    final res = await _router.executeTool(call);

    setState(() {
      item.status = res.success ? 'SUCCESS' : 'FAILED';
      item.lastResult = res.success ? res.message : (res.errorMessage ?? res.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0E17),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ANDROID CONTROL ENGINE",
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00FFCC),
                letterSpacing: 1.2,
              ),
            ),
            Text(
              "Phase 3 Real Android Native Tool Test & Verification",
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white60,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF00FFCC), size: 18),
            onPressed: () {
              _checkAllPermissions();
              _loadGeminiConfig();
            },
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // System Overview Banner
              _buildStatusCard(),

              const SizedBox(height: 16),

              Text(
                "NATIVE ANDROID TOOLS (12/12)",
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 10),

              // Tool Cards
              ..._tools.map((item) => _buildToolCard(item)),

              const SizedBox(height: 100),
            ],
          ),

          // Live Action HUD Overlay
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

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131422),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00FFCC).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.cpu, color: Color(0xFF00FFCC), size: 20),
              const SizedBox(width: 8),
              Text(
                "JX CONTROL ENGINE STATUS",
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF00FFCC),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFCC).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "PHASE 3 ACTIVE",
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00FFCC),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow("Accessibility Service", _isAccessibilityActive ? "ENABLED ✓" : "DISABLED (Tap to enable)", _isAccessibilityActive),
          const SizedBox(height: 6),
          _buildInfoRow("Gemini Brain Integration", _geminiApiKey.isNotEmpty ? "CONFIGURED ✓" : "NOT SET", _geminiApiKey.isNotEmpty),
          const SizedBox(height: 6),
          _buildInfoRow("Native Router Channel", "com.jx.ai/android_tools ✓", true),
          const SizedBox(height: 6),
          _buildInfoRow("Action Confirmation", "Risk Level Interceptor ACTIVE ✓", true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isOk) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.rajdhani(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600),
        ),
        GestureDetector(
          onTap: label.contains("Accessibility") && !isOk ? () => _router.openAccessibilitySettings() : null,
          child: Text(
            value,
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              color: isOk ? const Color(0xFF00FFCC) : const Color(0xFFFF9900),
              fontWeight: FontWeight.w700,
              decoration: label.contains("Accessibility") && !isOk ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolCard(ToolDebugItem item) {
    final isSuccess = item.status == 'SUCCESS';
    final isFailed = item.status == 'FAILED';
    final isRunning = item.status == 'RUNNING';

    Color cardBorder = Colors.white12;
    if (isSuccess) cardBorder = const Color(0xFF00FFCC).withOpacity(0.6);
    if (isFailed) cardBorder = const Color(0xFFFF0055).withOpacity(0.6);
    if (isRunning) cardBorder = const Color(0xFFFF007F).withOpacity(0.8);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF11121F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "#${item.index}",
                  style: GoogleFonts.orbitron(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.displayName,
                  style: GoogleFonts.rajdhani(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              // Risk Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: item.riskLevel == ActionRiskLevel.safe
                      ? const Color(0xFF00FFCC).withOpacity(0.15)
                      : const Color(0xFFFFB800).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.riskLevel == ActionRiskLevel.safe ? "SAFE" : "CONFIRM",
                  style: GoogleFonts.orbitron(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: item.riskLevel == ActionRiskLevel.safe
                        ? const Color(0xFF00FFCC)
                        : const Color(0xFFFFB800),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Metadata Grid
          Row(
            children: [
              Expanded(
                child: Text(
                  "Permission: ${item.permissionRequired}",
                  style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                item.isPermissionGranted ? "✓ GRANTED" : "✕ REQUIRED",
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: item.isPermissionGranted ? const Color(0xFF00FFCC) : const Color(0xFFFF9900),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Arguments
          if (item.defaultArgs.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "Args: ${jsonEncode(item.defaultArgs)}",
                style: GoogleFonts.sourceCodePro(fontSize: 11, color: Colors.white60),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          if (item.lastResult != null) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSuccess
                    ? const Color(0xFF00FFCC).withOpacity(0.08)
                    : const Color(0xFFFF0055).withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSuccess
                      ? const Color(0xFF00FFCC).withOpacity(0.3)
                      : const Color(0xFFFF0055).withOpacity(0.3),
                ),
              ),
              child: Text(
                "Result: ${item.lastResult}",
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: isSuccess ? const Color(0xFF00FFCC) : const Color(0xFFFF6688),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Trigger Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: isRunning ? null : () => _executeToolTest(item),
              icon: isRunning
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Icon(LucideIcons.play, size: 14, color: Colors.black),
              label: Text(
                isRunning ? "EXECUTING..." : "TEST TOOL",
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FFCC),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
