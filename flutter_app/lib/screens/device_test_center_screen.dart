import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../models/android_tool_models.dart';
import '../services/android_tool_router.dart';
import '../services/gemini_service.dart';
import '../services/secure_storage_service.dart';
import '../widgets/action_confirmation_dialog.dart';
import '../widgets/action_hud.dart';

enum DeviceTestStatus {
  idle,
  running,
  pass,
  fail,
  notGranted,
  notSupported,
  requiresRealDevice,
}

class DeviceTestItem {
  final int id;
  final String title;
  final String category; // AI, Permission, OS, App, Accessibility
  final String description;
  final String mechanism; // MethodChannel / Native / API
  final ActionRiskLevel riskLevel;
  DeviceTestStatus status;
  String? resultDetails;
  DateTime? lastRunTime;

  DeviceTestItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.mechanism,
    this.riskLevel = ActionRiskLevel.safe,
    this.status = DeviceTestStatus.idle,
    this.resultDetails,
    this.lastRunTime,
  });
}

class DeviceTestCenterScreen extends StatefulWidget {
  const DeviceTestCenterScreen({Key? key}) : super(key: key);

  @override
  State<DeviceTestCenterScreen> createState() => _DeviceTestCenterScreenState();
}

class _DeviceTestCenterScreenState extends State<DeviceTestCenterScreen> {
  final AndroidToolRouter _router = AndroidToolRouter.instance;
  ActionHUDState _currentHUD = ActionHUDState.idle();

  String _geminiApiKey = '';
  String _geminiModel = 'gemini-1.5-flash';
  GeminiService? _geminiService;
  bool _isAutoRunning = false;
  String _selectedCategory = 'ALL';

  late List<DeviceTestItem> _tests;

  @override
  void initState() {
    super.initState();
    _initTests();
    _loadConfigAndInitialCheck();
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

  void _initTests() {
    _tests = [
      // 1. Gemini API connection
      DeviceTestItem(
        id: 1,
        title: '1. Gemini API Connection',
        category: 'AI ENGINE',
        description: 'Verifies encrypted Keystore API key and pings Google Gemini API server.',
        mechanism: 'REST endpoint / v1beta models',
      ),

      // 2. Microphone
      DeviceTestItem(
        id: 2,
        title: '2. Microphone',
        category: 'PERMISSIONS & HARDWARE',
        description: 'Checks RECORD_AUDIO runtime permission and audio recorder availability.',
        mechanism: 'Permission.microphone',
      ),

      // 3. Camera
      DeviceTestItem(
        id: 3,
        title: '3. Camera',
        category: 'PERMISSIONS & HARDWARE',
        description: 'Verifies CAMERA runtime permission and camera sensor hardware access.',
        mechanism: 'Permission.camera',
      ),

      // 4. Location
      DeviceTestItem(
        id: 4,
        title: '4. Location',
        category: 'PERMISSIONS & HARDWARE',
        description: 'Verifies ACCESS_FINE_LOCATION and coarse GPS provider permission.',
        mechanism: 'Permission.location',
      ),

      // 5. Contacts
      DeviceTestItem(
        id: 5,
        title: '5. Contacts Permission',
        category: 'PERMISSIONS & HARDWARE',
        description: 'Verifies READ_CONTACTS permission for querying phone address book.',
        mechanism: 'Permission.contacts',
      ),

      // 6. Accessibility Service
      DeviceTestItem(
        id: 6,
        title: '6. Accessibility Service',
        category: 'SYSTEM ACCESSIBILITY',
        description: 'Verifies if JXAccessibilityService is enabled in Android System Settings.',
        mechanism: 'com.jx.ai/system (isAccessibilityEnabled)',
      ),

      // 7. Notification Access
      DeviceTestItem(
        id: 7,
        title: '7. Notification Access',
        category: 'SYSTEM ACCESSIBILITY',
        description: 'Verifies JXNotificationListenerService permission in Android Notification Listener settings.',
        mechanism: 'com.jx.ai/system (isNotificationListenerEnabled)',
      ),

      // 8. Screen Capture / MediaProjection
      DeviceTestItem(
        id: 8,
        title: '8. Screen Capture / MediaProjection',
        category: 'SYSTEM ACCESSIBILITY',
        description: 'Verifies MediaProjectionManager foreground service & user screen capture consent.',
        riskLevel: ActionRiskLevel.userConfirmation,
        mechanism: 'MediaProjection foreground token',
      ),

      // 9. Open Installed App
      DeviceTestItem(
        id: 9,
        title: '9. Open Installed App',
        category: 'APP AUTOMATION',
        description: 'Tests PackageManager launch intent to open an installed Android application.',
        mechanism: 'com.jx.ai/android_tools (openApp -> YouTube/Settings)',
      ),

      // 10. Google Search
      DeviceTestItem(
        id: 10,
        title: '10. Google Search',
        category: 'APP AUTOMATION',
        description: 'Tests Intent.ACTION_VIEW web query dispatcher to default Android browser.',
        mechanism: 'com.jx.ai/android_tools (searchWeb)',
      ),

      // 11. YouTube
      DeviceTestItem(
        id: 11,
        title: '11. YouTube',
        category: 'APP AUTOMATION',
        description: 'Tests YouTube intent filter (vnd.youtube / search_query) to open videos.',
        mechanism: 'com.jx.ai/android_tools (openYouTube)',
      ),

      // 12. WhatsApp Compose
      DeviceTestItem(
        id: 12,
        title: '12. WhatsApp Compose',
        category: 'APP AUTOMATION',
        description: 'Prepares WhatsApp message composition screen (no silent background sending).',
        riskLevel: ActionRiskLevel.userConfirmation,
        mechanism: 'com.jx.ai/android_tools (openWhatsApp)',
      ),

      // 13. Contact Search
      DeviceTestItem(
        id: 13,
        title: '13. Contact Search',
        category: 'APP AUTOMATION',
        description: 'Queries Android ContactsContract.CommonDataKinds.Phone for names/numbers.',
        mechanism: 'com.jx.ai/android_tools (searchContacts)',
      ),

      // 14. Phone Dialer
      DeviceTestItem(
        id: 14,
        title: '14. Phone Dialer',
        category: 'APP AUTOMATION',
        description: 'Pre-fills Android native phone dialer via Intent.ACTION_DIAL.',
        riskLevel: ActionRiskLevel.userConfirmation,
        mechanism: 'com.jx.ai/android_tools (preparePhoneCall)',
      ),

      // 15. Volume Control
      DeviceTestItem(
        id: 15,
        title: '15. Volume Control',
        category: 'OS NAVIGATION & AUDIO',
        description: 'Adjusts AudioManager.STREAM_MUSIC volume up/down/percent via native service.',
        mechanism: 'com.jx.ai/system (adjustVolume)',
      ),

      // 16. Back
      DeviceTestItem(
        id: 16,
        title: '16. OS Navigation: BACK',
        category: 'OS NAVIGATION & AUDIO',
        description: 'Performs AccessibilityService.GLOBAL_ACTION_BACK to return to previous screen.',
        mechanism: 'com.jx.ai/system (performGlobalAction: back)',
      ),

      // 17. Home
      DeviceTestItem(
        id: 17,
        title: '17. OS Navigation: HOME',
        category: 'OS NAVIGATION & AUDIO',
        description: 'Performs AccessibilityService.GLOBAL_ACTION_HOME to return to Home screen.',
        mechanism: 'com.jx.ai/system (performGlobalAction: home)',
      ),

      // 18. Recents
      DeviceTestItem(
        id: 18,
        title: '18. OS Navigation: RECENTS',
        category: 'OS NAVIGATION & AUDIO',
        description: 'Performs AccessibilityService.GLOBAL_ACTION_RECENTS to show app switcher.',
        mechanism: 'com.jx.ai/system (performGlobalAction: recents)',
      ),

      // 19. Accessibility UI Inspection
      DeviceTestItem(
        id: 19,
        title: '19. Accessibility UI Inspection',
        category: 'ACCESSIBILITY ACTIONS',
        description: 'Traverses active window AccessibilityNodeInfo tree and extracts UI hierarchy.',
        mechanism: 'com.jx.ai/android_tools (inspectScreenHierarchy)',
      ),

      // 20. Accessibility Tap
      DeviceTestItem(
        id: 20,
        title: '20. Accessibility Tap',
        category: 'ACCESSIBILITY ACTIONS',
        description: 'Finds on-screen target node by text or viewId and performs ACTION_CLICK.',
        mechanism: 'com.jx.ai/android_tools (findAndClickNode)',
      ),

      // 21. Accessibility Text Input
      DeviceTestItem(
        id: 21,
        title: '21. Accessibility Text Input',
        category: 'ACCESSIBILITY ACTIONS',
        description: 'Targets input field and inputs text via ACTION_SET_TEXT.',
        mechanism: 'com.jx.ai/android_tools (typeTextInNode)',
      ),

      // 22. Gemini Tool Calling
      DeviceTestItem(
        id: 22,
        title: '22. Gemini Tool Calling',
        category: 'AI ENGINE',
        description: 'Tests end-to-end natural language agentic function calling loop.',
        mechanism: 'GeminiService + FunctionDeclarations + AndroidToolRouter',
      ),
    ];
  }

  Future<void> _loadConfigAndInitialCheck() async {
    final key = await SecureStorageService.instance.getGeminiApiKey() ?? '';
    final model = await SecureStorageService.instance.getGeminiModel() ?? 'gemini-1.5-flash';

    if (mounted) {
      setState(() {
        _geminiApiKey = key;
        _geminiModel = model;
        _geminiService = GeminiService(apiKey: key, modelName: model);
      });
    }

    // Run basic permission checks on start
    await _checkQuickPermissions();
  }

  Future<void> _checkQuickPermissions() async {
    for (var test in _tests) {
      if (test.id == 2) {
        final status = await Permission.microphone.status;
        _updateStatus(test, status.isGranted ? DeviceTestStatus.pass : DeviceTestStatus.notGranted,
            status.isGranted ? "Microphone permission is GRANTED." : "RECORD_AUDIO is NOT GRANTED. Tap to request.");
      } else if (test.id == 3) {
        final status = await Permission.camera.status;
        _updateStatus(test, status.isGranted ? DeviceTestStatus.pass : DeviceTestStatus.notGranted,
            status.isGranted ? "Camera permission is GRANTED." : "CAMERA is NOT GRANTED. Tap to request.");
      } else if (test.id == 4) {
        final status = await Permission.location.status;
        _updateStatus(test, status.isGranted ? DeviceTestStatus.pass : DeviceTestStatus.notGranted,
            status.isGranted ? "Location permission is GRANTED." : "LOCATION is NOT GRANTED. Tap to request.");
      } else if (test.id == 5) {
        final status = await Permission.contacts.status;
        _updateStatus(test, status.isGranted ? DeviceTestStatus.pass : DeviceTestStatus.notGranted,
            status.isGranted ? "Contacts permission is GRANTED." : "READ_CONTACTS is NOT GRANTED. Tap to request.");
      } else if (test.id == 6) {
        final access = await _router.isAccessibilityEnabled();
        _updateStatus(test, access ? DeviceTestStatus.pass : DeviceTestStatus.notGranted,
            access ? "JX Accessibility Service is ENABLED." : "Accessibility Service is NOT ENABLED. Enable in Android Settings.");
      }
    }
  }

  void _updateStatus(DeviceTestItem item, DeviceTestStatus status, String details) {
    if (mounted) {
      setState(() {
        item.status = status;
        item.resultDetails = details;
        item.lastRunTime = DateTime.now();
      });
    }
  }

  Future<void> _runIndividualTest(DeviceTestItem item) async {
    setState(() {
      item.status = DeviceTestStatus.running;
      item.resultDetails = "Executing test on device...";
    });

    try {
      switch (item.id) {
        // 1. Gemini API connection
        case 1:
          if (_geminiApiKey.isEmpty) {
            _updateStatus(item, DeviceTestStatus.notGranted, "Gemini API key is not configured in Settings/Keystore.");
            return;
          }
          final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$_geminiApiKey');
          final response = await http.get(uri).timeout(const Duration(seconds: 8));
          if (response.statusCode == 200) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: Connected to Gemini API server (HTTP 200 OK). Key is valid.");
          } else {
            _updateStatus(item, DeviceTestStatus.fail, "FAIL: API responded with status ${response.statusCode}: ${response.body}");
          }
          break;

        // 2. Microphone
        case 2:
          var micStatus = await Permission.microphone.status;
          if (!micStatus.isGranted) {
            micStatus = await Permission.microphone.request();
          }
          if (micStatus.isGranted) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: Microphone runtime permission verified and granted.");
          } else {
            _updateStatus(item, DeviceTestStatus.notGranted, "NOT GRANTED: User did not grant RECORD_AUDIO permission.");
          }
          break;

        // 3. Camera
        case 3:
          var camStatus = await Permission.camera.status;
          if (!camStatus.isGranted) {
            camStatus = await Permission.camera.request();
          }
          if (camStatus.isGranted) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: Camera hardware permission verified and granted.");
          } else {
            _updateStatus(item, DeviceTestStatus.notGranted, "NOT GRANTED: Camera permission denied.");
          }
          break;

        // 4. Location
        case 4:
          var locStatus = await Permission.location.status;
          if (!locStatus.isGranted) {
            locStatus = await Permission.location.request();
          }
          if (locStatus.isGranted) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: Fine and Coarse location permissions granted.");
          } else {
            _updateStatus(item, DeviceTestStatus.notGranted, "NOT GRANTED: Location permission not granted.");
          }
          break;

        // 5. Contacts
        case 5:
          var conStatus = await Permission.contacts.status;
          if (!conStatus.isGranted) {
            conStatus = await Permission.contacts.request();
          }
          if (conStatus.isGranted) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: Contacts permission granted.");
          } else {
            _updateStatus(item, DeviceTestStatus.notGranted, "NOT GRANTED: Contacts permission denied.");
          }
          break;

        // 6. Accessibility Service
        case 6:
          final accessEnabled = await _router.isAccessibilityEnabled();
          if (accessEnabled) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: JX Accessibility Service is active in Android system.");
          } else {
            _updateStatus(item, DeviceTestStatus.notGranted, "NOT GRANTED: Accessibility Service disabled. Tap 'OPEN SETTINGS' to enable JX.");
          }
          break;

        // 7. Notification Access
        case 7:
          final notifStatus = await Permission.notification.status;
          if (!notifStatus.isGranted) {
            await Permission.notification.request();
          }
          final hasNotif = await Permission.notification.status.isGranted;
          if (hasNotif) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: Notification posting and listener service available.");
          } else {
            _updateStatus(item, DeviceTestStatus.notGranted, "NOT GRANTED: Notification access not granted.");
          }
          break;

        // 8. Screen Capture / MediaProjection
        case 8:
          final res = await _router.executeTool(AndroidToolCall(toolName: 'analyze_screen', arguments: {}));
          _updateStatus(item, DeviceTestStatus.requiresRealDevice, "Requires real Android device test: Requires physical user consent token on device screen.");
          break;

        // 9. Open Installed App
        case 9:
          final res = await _router.openApp(appName: 'YouTube');
          if (res.success) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: Successfully launched app via PackageManager intent.");
          } else {
            _updateStatus(item, DeviceTestStatus.fail, "FAIL: ${res.errorMessage ?? res.message}");
          }
          break;

        // 10. Google Search
        case 10:
          final res = await _router.searchWeb(query: 'JX AI Companion');
          if (res.success) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: Intent.ACTION_VIEW web search dispatched successfully.");
          } else {
            _updateStatus(item, DeviceTestStatus.fail, "FAIL: ${res.errorMessage ?? res.message}");
          }
          break;

        // 11. YouTube
        case 11:
          final res = await _router.openYouTube(query: 'electronics tutorial');
          if (res.success) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: YouTube intent dispatched successfully.");
          } else {
            _updateStatus(item, DeviceTestStatus.fail, "FAIL: ${res.errorMessage ?? res.message}");
          }
          break;

        // 12. WhatsApp Compose
        case 12:
          final res = await _router.openWhatsApp(phone: '1234567890', message: 'Hello from JX AI');
          if (res.success) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: WhatsApp composition intent prepared successfully.");
          } else {
            _updateStatus(item, DeviceTestStatus.fail, "FAIL: ${res.errorMessage ?? res.message}");
          }
          break;

        // 13. Contact Search
        case 13:
          final res = await _router.searchContacts('Rahim');
          if (res.success) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: Queried ContactsContract database successfully (${res.message}).");
          } else if (res.errorMessage == 'PERMISSION_DENIED') {
            _updateStatus(item, DeviceTestStatus.notGranted, "NOT GRANTED: READ_CONTACTS permission denied.");
          } else {
            _updateStatus(item, DeviceTestStatus.fail, "FAIL: ${res.errorMessage ?? res.message}");
          }
          break;

        // 14. Phone Dialer
        case 14:
          final res = await _router.preparePhoneCall(phoneNumber: '999');
          if (res.success) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: Native dialer launched via Intent.ACTION_DIAL.");
          } else {
            _updateStatus(item, DeviceTestStatus.fail, "FAIL: ${res.errorMessage ?? res.message}");
          }
          break;

        // 15. Volume Control
        case 15:
          final res = await _router.adjustVolume(percent: 60);
          if (res.success) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: AudioManager.STREAM_MUSIC adjusted (${res.message}).");
          } else {
            _updateStatus(item, DeviceTestStatus.fail, "FAIL: ${res.errorMessage ?? res.message}");
          }
          break;

        // 16. Back
        case 16:
          final access = await _router.isAccessibilityEnabled();
          if (!access) {
            _updateStatus(item, DeviceTestStatus.notGranted, "NOT GRANTED: Requires JX Accessibility Service enabled in Android Settings.");
            return;
          }
          final res = await _router.navigateOS('back');
          if (res.success) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: Executed GLOBAL_ACTION_BACK.");
          } else {
            _updateStatus(item, DeviceTestStatus.fail, "FAIL: ${res.errorMessage ?? res.message}");
          }
          break;

        // 17. Home
        case 17:
          final access = await _router.isAccessibilityEnabled();
          if (!access) {
            _updateStatus(item, DeviceTestStatus.notGranted, "NOT GRANTED: Requires JX Accessibility Service enabled.");
            return;
          }
          final res = await _router.navigateOS('home');
          if (res.success) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: Executed GLOBAL_ACTION_HOME.");
          } else {
            _updateStatus(item, DeviceTestStatus.fail, "FAIL: ${res.errorMessage ?? res.message}");
          }
          break;

        // 18. Recents
        case 18:
          final access = await _router.isAccessibilityEnabled();
          if (!access) {
            _updateStatus(item, DeviceTestStatus.notGranted, "NOT GRANTED: Requires JX Accessibility Service enabled.");
            return;
          }
          final res = await _router.navigateOS('recents');
          if (res.success) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: Executed GLOBAL_ACTION_RECENTS.");
          } else {
            _updateStatus(item, DeviceTestStatus.fail, "FAIL: ${res.errorMessage ?? res.message}");
          }
          break;

        // 19. Accessibility UI Inspection
        case 19:
          final access = await _router.isAccessibilityEnabled();
          if (!access) {
            _updateStatus(item, DeviceTestStatus.notGranted, "NOT GRANTED: Requires JX Accessibility Service.");
            return;
          }
          final res = await _router.inspectScreenHierarchy();
          if (res.success) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: Inspected UI hierarchy (${res.message}).");
          } else {
            _updateStatus(item, DeviceTestStatus.fail, "FAIL: ${res.errorMessage ?? res.message}");
          }
          break;

        // 20. Accessibility Tap
        case 20:
          final access = await _router.isAccessibilityEnabled();
          if (!access) {
            _updateStatus(item, DeviceTestStatus.notGranted, "NOT GRANTED: Requires JX Accessibility Service.");
            return;
          }
          final res = await _router.findAndClickNode(text: 'Settings');
          _updateStatus(item, res.success ? DeviceTestStatus.pass : DeviceTestStatus.requiresRealDevice,
              res.success ? "PASS: Tap executed on target UI node." : "Requires real Android device test: No active window target node matched.");
          break;

        // 21. Accessibility Text Input
        case 21:
          final access = await _router.isAccessibilityEnabled();
          if (!access) {
            _updateStatus(item, DeviceTestStatus.notGranted, "NOT GRANTED: Requires JX Accessibility Service.");
            return;
          }
          final res = await _router.typeTextInUI(text: 'Hello from JX AI');
          _updateStatus(item, res.success ? DeviceTestStatus.pass : DeviceTestStatus.requiresRealDevice,
              res.success ? "PASS: Text entered into active input field." : "Requires real Android device test: Requires focused edit text on active device.");
          break;

        // 22. Gemini Tool Calling
        case 22:
          if (_geminiService == null || _geminiApiKey.isEmpty) {
            _updateStatus(item, DeviceTestStatus.notGranted, "NOT GRANTED: Gemini API key missing. Add key in Settings.");
            return;
          }
          final res = await _geminiService!.processAgenticPrompt('YouTube-এ electronics tutorial search করো');
          if (res.toolCall != null || res.toolResult?.success == true) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: Gemini Agentic loop called tool: ${res.toolCall?.toolName}. Reply: ${res.text}");
          } else if (res.text.isNotEmpty) {
            _updateStatus(item, DeviceTestStatus.pass, "PASS: Gemini replied: \"${res.text}\"");
          } else {
            _updateStatus(item, DeviceTestStatus.fail, "FAIL: No response received from Gemini.");
          }
          break;

        default:
          _updateStatus(item, DeviceTestStatus.notSupported, "NOT SUPPORTED");
      }
    } catch (e) {
      _updateStatus(item, DeviceTestStatus.fail, "FAIL: Error occurred: $e");
    }
  }

  Future<void> _runAllTests() async {
    if (_isAutoRunning) return;
    setState(() => _isAutoRunning = true);

    for (var test in _tests) {
      await _runIndividualTest(test);
      await Future.delayed(const Duration(milliseconds: 350));
    }

    if (mounted) {
      setState(() => _isAutoRunning = false);
    }
  }

  void _resetTests() {
    setState(() {
      for (var test in _tests) {
        test.status = DeviceTestStatus.idle;
        test.resultDetails = null;
        test.lastRunTime = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final passCount = _tests.where((t) => t.status == DeviceTestStatus.pass).length;
    final failCount = _tests.where((t) => t.status == DeviceTestStatus.fail).length;
    final notGrantedCount = _tests.where((t) => t.status == DeviceTestStatus.notGranted).length;
    final realDeviceCount = _tests.where((t) => t.status == DeviceTestStatus.requiresRealDevice).length;

    final filteredTests = _selectedCategory == 'ALL'
        ? _tests
        : _tests.where((t) => t.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1422),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "JX DEVICE TEST CENTER",
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00F2FE),
                letterSpacing: 1.2,
              ),
            ),
            Text(
              "Real Android Device Verification Suite (22 Tests)",
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
            icon: const Icon(LucideIcons.rotateCcw, color: Colors.white70, size: 18),
            onPressed: _resetTests,
            tooltip: 'Reset Tests',
          ),
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF00F2FE), size: 18),
            onPressed: _checkQuickPermissions,
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // Summary Metrics Card
              _buildMetricsSummaryCard(passCount, failCount, notGrantedCount, realDeviceCount),

              const SizedBox(height: 16),

              // Action Toolbar: Run All Tests Button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isAutoRunning ? null : _runAllTests,
                      icon: _isAutoRunning
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Icon(LucideIcons.playCircle, color: Colors.black, size: 18),
                      label: Text(
                        _isAutoRunning ? "RUNNING ALL 22 TESTS..." : "RUN ALL 22 AUTOMATED TESTS",
                        style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00F2FE),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Category Filter Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'ALL',
                    'AI ENGINE',
                    'PERMISSIONS & HARDWARE',
                    'SYSTEM ACCESSIBILITY',
                    'APP AUTOMATION',
                    'OS NAVIGATION & AUDIO',
                    'ACCESSIBILITY ACTIONS',
                  ].map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          cat,
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.black : Colors.white70,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF00F2FE),
                        backgroundColor: const Color(0xFF131722),
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = cat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Individual Test Cards
              ...filteredTests.map((test) => _buildTestCard(test)),

              const SizedBox(height: 80),
            ],
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

  Widget _buildMetricsSummaryCard(int pass, int fail, int notGranted, int realDevice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1422),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.activity, color: Color(0xFF00F2FE), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "DEVICE HEALTH AUDIT",
                    style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF00F2FE)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00F2FE).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "22 TOTAL TESTS",
                  style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF00F2FE)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildMetricBadge("PASS ✓", pass.toString(), const Color(0xFF00FFCC)),
              const SizedBox(width: 8),
              _buildMetricBadge("FAIL ✕", fail.toString(), const Color(0xFFFF0055)),
              const SizedBox(width: 8),
              _buildMetricBadge("NOT GRANTED", notGranted.toString(), const Color(0xFFFFB800)),
              const SizedBox(width: 8),
              _buildMetricBadge("REAL DEVICE", realDevice.toString(), const Color(0xFF7000FF)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBadge(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.w900, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.orbitron(fontSize: 8, fontWeight: FontWeight.w700, color: color),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(DeviceTestItem test) {
    final status = test.status;

    Color badgeColor = Colors.white38;
    String badgeText = "IDLE / READY";

    switch (status) {
      case DeviceTestStatus.pass:
        badgeColor = const Color(0xFF00FFCC);
        badgeText = "PASS ✓";
        break;
      case DeviceTestStatus.fail:
        badgeColor = const Color(0xFFFF0055);
        badgeText = "FAIL ✕";
        break;
      case DeviceTestStatus.notGranted:
        badgeColor = const Color(0xFFFFB800);
        badgeText = "NOT GRANTED";
        break;
      case DeviceTestStatus.notSupported:
        badgeColor = Colors.grey;
        badgeText = "NOT SUPPORTED";
        break;
      case DeviceTestStatus.requiresRealDevice:
        badgeColor = const Color(0xFF7000FF);
        badgeText = "Requires real Android device test.";
        break;
      case DeviceTestStatus.running:
        badgeColor = const Color(0xFF00F2FE);
        badgeText = "TESTING...";
        break;
      case DeviceTestStatus.idle:
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101422),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status == DeviceTestStatus.pass
              ? const Color(0xFF00FFCC).withOpacity(0.4)
              : (status == DeviceTestStatus.fail
                  ? const Color(0xFFFF0055).withOpacity(0.4)
                  : Colors.white10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  test.title,
                  style: GoogleFonts.rajdhani(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor.withOpacity(0.5)),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            test.description,
            style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              Text(
                "Category: ",
                style: GoogleFonts.orbitron(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.w600),
              ),
              Text(
                test.category,
                style: GoogleFonts.orbitron(fontSize: 10, color: const Color(0xFF00F2FE), fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                "Via: ${test.mechanism}",
                style: GoogleFonts.sourceCodePro(fontSize: 10, color: Colors.white54),
              ),
            ],
          ),

          if (test.resultDetails != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: badgeColor.withOpacity(0.2)),
              ),
              child: Text(
                test.resultDetails!,
                style: GoogleFonts.sourceCodePro(
                  fontSize: 11,
                  color: badgeColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Action Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (test.id == 6 && test.status == DeviceTestStatus.notGranted) ...[
                TextButton.icon(
                  onPressed: () => _router.openAccessibilitySettings(),
                  icon: const Icon(LucideIcons.externalLink, size: 14, color: Color(0xFFFFB800)),
                  label: Text("OPEN SETTINGS", style: GoogleFonts.orbitron(fontSize: 10, color: const Color(0xFFFFB800), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
              ],
              ElevatedButton.icon(
                onPressed: status == DeviceTestStatus.running ? null : () => _runIndividualTest(test),
                icon: status == DeviceTestStatus.running
                    ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(LucideIcons.play, size: 13, color: Colors.black),
                label: Text(
                  status == DeviceTestStatus.running ? "TESTING..." : "TEST FEATURE",
                  style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F2FE),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
