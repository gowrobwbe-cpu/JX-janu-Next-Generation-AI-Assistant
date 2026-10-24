import 'dart:convert';
import '../models/android_tool_models.dart';

class GeminiToolDeclarations {
  /// Structured schema list of all supported native Android tools
  static final List<AndroidToolDefinition> registeredTools = [
    // 1. App Control
    const AndroidToolDefinition(
      name: 'open_app',
      displayName: 'Open App',
      description: 'Opens an Android app by name (e.g. YouTube, Facebook, WhatsApp, Chrome, Settings, Calculator, Clock, Maps, Gallery, etc.) or package name.',
      requiredPermission: 'None',
      riskLevel: ActionRiskLevel.safe,
      parameterSchema: {
        'type': 'object',
        'properties': {
          'appName': {'type': 'string', 'description': 'The name of the app to launch (e.g. "YouTube", "Facebook", "Instagram", "Settings")'},
          'packageName': {'type': 'string', 'description': 'Optional specific package name (e.g. "com.facebook.katana")'},
        },
        'required': ['appName'],
      },
    ),

    // 2. Find Installed Apps
    const AndroidToolDefinition(
      name: 'find_installed_app',
      displayName: 'Find Installed App',
      description: 'Searches the Android device for installed apps matching a search term.',
      requiredPermission: 'QUERY_ALL_PACKAGES',
      riskLevel: ActionRiskLevel.safe,
      parameterSchema: {
        'type': 'object',
        'properties': {
          'query': {'type': 'string', 'description': 'Name or partial name of the app to search for'},
        },
        'required': ['query'],
      },
    ),

    // 3. Web Search
    const AndroidToolDefinition(
      name: 'search_web',
      displayName: 'Google / Web Search',
      description: 'Opens the default Android browser and executes a search query on Google or specified search engine.',
      requiredPermission: 'INTERNET',
      riskLevel: ActionRiskLevel.safe,
      parameterSchema: {
        'type': 'object',
        'properties': {
          'query': {'type': 'string', 'description': 'The search query or URL to open'},
          'engine': {'type': 'string', 'description': 'Search engine: "google" or "bing"', 'default': 'google'},
        },
        'required': ['query'],
      },
    ),

    // 4. YouTube
    const AndroidToolDefinition(
      name: 'open_youtube',
      displayName: 'YouTube Search / Open',
      description: 'Opens YouTube directly or searches for videos / tutorials on YouTube.',
      requiredPermission: 'INTERNET',
      riskLevel: ActionRiskLevel.safe,
      parameterSchema: {
        'type': 'object',
        'properties': {
          'query': {'type': 'string', 'description': 'Optional query to search on YouTube (e.g. "electronics tutorial")'},
        },
      },
    ),

    // 5. WhatsApp
    const AndroidToolDefinition(
      name: 'open_whatsapp',
      displayName: 'WhatsApp Compose',
      description: 'Opens WhatsApp to send or compose a message to a contact or phone number. Never sends silently.',
      requiredPermission: 'READ_CONTACTS (Optional)',
      riskLevel: ActionRiskLevel.userConfirmation,
      parameterSchema: {
        'type': 'object',
        'properties': {
          'contactName': {'type': 'string', 'description': 'Contact name (e.g. "Rahim", "Mom")'},
          'phone': {'type': 'string', 'description': 'Phone number in international format'},
          'message': {'type': 'string', 'description': 'The message draft content to send'},
        },
      },
    ),

    // 6. Phone Call / Dial
    const AndroidToolDefinition(
      name: 'prepare_phone_call',
      displayName: 'Prepare Phone Call',
      description: 'Prepares a phone call by resolving contact details and launching Android dialer (ACTION_DIAL).',
      requiredPermission: 'READ_CONTACTS / CALL_PHONE',
      riskLevel: ActionRiskLevel.userConfirmation,
      parameterSchema: {
        'type': 'object',
        'properties': {
          'contactName': {'type': 'string', 'description': 'The name of the contact (e.g. "Mom", "মা", "Rahim")'},
          'phoneNumber': {'type': 'string', 'description': 'Direct phone number if known'},
        },
      },
    ),

    // 7. Search Contacts
    const AndroidToolDefinition(
      name: 'search_contacts',
      displayName: 'Search Contacts',
      description: 'Queries the Android device address book for contact names and phone numbers.',
      requiredPermission: 'READ_CONTACTS',
      riskLevel: ActionRiskLevel.safe,
      parameterSchema: {
        'type': 'object',
        'properties': {
          'query': {'type': 'string', 'description': 'Contact name to look up'},
        },
        'required': ['query'],
      },
    ),

    // 8. Camera
    const AndroidToolDefinition(
      name: 'open_camera',
      displayName: 'Open Camera',
      description: 'Launches the Android camera application in photo or video mode.',
      requiredPermission: 'CAMERA',
      riskLevel: ActionRiskLevel.safe,
      parameterSchema: {
        'type': 'object',
        'properties': {
          'mode': {'type': 'string', 'description': '"photo" or "video"', 'default': 'photo'},
        },
      },
    ),

    // 9. Volume Control
    const AndroidToolDefinition(
      name: 'adjust_volume',
      displayName: 'Volume Control',
      description: 'Raises, lowers, mutes, or sets media volume percentage on the Android device.',
      requiredPermission: 'MODIFY_AUDIO_SETTINGS',
      riskLevel: ActionRiskLevel.safe,
      parameterSchema: {
        'type': 'object',
        'properties': {
          'direction': {'type': 'string', 'description': '"up", "down", or "mute"'},
          'percent': {'type': 'integer', 'description': 'Target volume percentage 0 to 100 (e.g. 50)'},
        },
      },
    ),

    // 10. Navigation (Back, Home, Recents, Notifications)
    const AndroidToolDefinition(
      name: 'navigate_os',
      displayName: 'OS Navigation',
      description: 'Performs global Android navigation actions: back, home, recents, notifications, quick_settings via Accessibility Service.',
      requiredPermission: 'ACCESSIBILITY_SERVICE',
      riskLevel: ActionRiskLevel.safe,
      parameterSchema: {
        'type': 'object',
        'properties': {
          'action': {'type': 'string', 'description': '"back", "home", "recents", "notifications", or "quick_settings"'},
        },
        'required': ['action'],
      },
    ),

    // 11. Screen Assistant (MediaProjection)
    const AndroidToolDefinition(
      name: 'analyze_screen',
      displayName: 'Screen Assistant',
      description: 'Analyzes what is currently on the user’s Android screen with explicit user consent.',
      requiredPermission: 'MEDIA_PROJECTION',
      riskLevel: ActionRiskLevel.userConfirmation,
      parameterSchema: {
        'type': 'object',
        'properties': {
          'prompt': {'type': 'string', 'description': 'Specific question about the screen content'},
        },
      },
    ),

    // 12. Accessibility UI Control (Click, Scroll, Inspect, Type)
    const AndroidToolDefinition(
      name: 'find_and_click_ui',
      displayName: 'Find & Click UI',
      description: 'Finds and clicks a semantic button or link on the active Android screen via Accessibility node tree.',
      requiredPermission: 'ACCESSIBILITY_SERVICE',
      riskLevel: ActionRiskLevel.safe,
      parameterSchema: {
        'type': 'object',
        'properties': {
          'text': {'type': 'string', 'description': 'Visible text on the target button or element (e.g. "Settings", "Send")'},
          'viewId': {'type': 'string', 'description': 'Optional resource id'},
          'contentDescription': {'type': 'string', 'description': 'Optional accessibility content description'},
        },
      },
    ),
  ];

  /// Generate function calling prompt instruction for Gemini
  static String getSystemFunctionCallingPrompt() {
    final buffer = StringBuffer();
    buffer.writeln('### AVAILABLE ANDROID TOOLS');
    buffer.writeln('When Gowrob Baby asks you to perform an Android OS action, control the device, open an app, search YouTube/Google, call someone, prepare a WhatsApp message, or adjust device settings, you MUST output a structured JSON tool call.');
    buffer.writeln();
    buffer.writeln('Tool Call JSON Format:');
    buffer.writeln('```json');
    buffer.writeln('{');
    buffer.writeln('  "tool": "<tool_name>",');
    buffer.writeln('  "arguments": { ... }');
    buffer.writeln('}');
    buffer.writeln('```');
    buffer.writeln();
    buffer.writeln('Available Tools List:');
    for (final tool in registeredTools) {
      buffer.writeln('- `${tool.name}`: ${tool.description} (Risk: ${tool.riskLevel.name.toUpperCase()})');
    }
    buffer.writeln();
    buffer.writeln('Language Understanding Rules (Bengali, Banglish & English):');
    buffer.writeln('- "ফেসবুক খোলো" / "Facebook খুলে দাও" / "facebook ta open koro" -> tool: "open_app", args: {"appName": "Facebook"}');
    buffer.writeln('- "JX Google-এ electronics circuit search করো." -> tool: "search_web", args: {"query": "electronics circuit"}');
    buffer.writeln('- "JX YouTube খোলো" -> tool: "open_youtube", args: {}');
    buffer.writeln('- "JX YouTube-এ electronics tutorial search করো." -> tool: "open_youtube", args: {"query": "electronics tutorial"}');
    buffer.writeln('- "JX WhatsApp খোলো" -> tool: "open_app", args: {"appName": "WhatsApp"}');
    buffer.writeln('- "JX Rahim-কে message লিখে দাও" -> tool: "open_whatsapp", args: {"contactName": "Rahim", "message": "..."}');
    buffer.writeln('- "JX মাকে ফোন দেওয়ার জন্য প্রস্তুত করো" -> tool: "prepare_phone_call", args: {"contactName": "Mom"}');
    buffer.writeln('- "JX camera চালু করো" -> tool: "open_camera", args: {"mode": "photo"}');
    buffer.writeln('- "JX volume বাড়াও" -> tool: "adjust_volume", args: {"direction": "up"}');
    buffer.writeln('- "volume komao" -> tool: "adjust_volume", args: {"direction": "down"}');
    buffer.writeln('- "JX media volume 50% করো" -> tool: "adjust_volume", args: {"percent": 50}');
    buffer.writeln('- "JX back যাও" / "back jao" -> tool: "navigate_os", args: {"action": "back"}');
    buffer.writeln('- "JX home screen-এ যাও" / "home e jao" -> tool: "navigate_os", args: {"action": "home"}');
    buffer.writeln('- "JX recent apps দেখাও" -> tool: "navigate_os", args: {"action": "recents"}');
    buffer.writeln('- "JX আমার screen-এ কী আছে?" -> tool: "analyze_screen", args: {"prompt": "What is on the screen?"}');
    buffer.writeln('- "JX এই page-এ Settings খুঁজে খোলো" -> tool: "find_and_click_ui", args: {"text": "Settings"}');
    buffer.writeln();
    buffer.writeln('Do NOT invent random tools. Only use the tools above.');
    return buffer.toString();
  }

  /// Extracts structured tool call from Gemini output text
  static AndroidToolCall? parseToolCallFromResponse(String responseText) {
    try {
      final trimmed = responseText.trim();

      // Check for ```json ... ``` blocks
      final jsonBlockRegex = RegExp(r'```(?:json)?\s*(\{[\s\S]*?\})\s*```', caseSensitive: false);
      final match = jsonBlockRegex.firstMatch(trimmed);

      if (match != null) {
        final jsonStr = match.group(1);
        if (jsonStr != null) {
          final decoded = jsonDecode(jsonStr);
          if (decoded is Map<String, dynamic> && decoded.containsKey('tool')) {
            return AndroidToolCall.fromJson(decoded);
          }
        }
      }

      // Check for standalone JSON object
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic> && decoded.containsKey('tool')) {
          return AndroidToolCall.fromJson(decoded);
        }
      }

      // Natural language pattern matcher fallback for Bengali / Banglish / English
      return matchNaturalLanguageCommand(trimmed);
    } catch (e) {
      return matchNaturalLanguageCommand(responseText);
    }
  }

  /// Direct fallback pattern parser for Bengali / Banglish commands if Gemini is offline
  static AndroidToolCall? matchNaturalLanguageCommand(String text) {
    final lower = text.toLowerCase().trim();

    // Volume
    if (lower.contains('volume barao') || lower.contains('volume বাড়াও') || lower.contains('increase volume')) {
      return AndroidToolCall(toolName: 'adjust_volume', arguments: {'direction': 'up'});
    }
    if (lower.contains('volume komao') || lower.contains('volume কমাও') || lower.contains('decrease volume')) {
      return AndroidToolCall(toolName: 'adjust_volume', arguments: {'direction': 'down'});
    }
    final volMatch = RegExp(r'volume\s*(\d{1,3})%').firstMatch(lower);
    if (volMatch != null) {
      final p = int.tryParse(volMatch.group(1)!);
      if (p != null) return AndroidToolCall(toolName: 'adjust_volume', arguments: {'percent': p});
    }

    // Navigation
    if (lower.contains('back jao') || lower.contains('ব্যাক যাও') || lower.contains('go back')) {
      return AndroidToolCall(toolName: 'navigate_os', arguments: {'action': 'back'});
    }
    if (lower.contains('home e jao') || lower.contains('হোম স্ক্রিন') || lower.contains('go home')) {
      return AndroidToolCall(toolName: 'navigate_os', arguments: {'action': 'home'});
    }
    if (lower.contains('recents') || lower.contains('recent apps')) {
      return AndroidToolCall(toolName: 'navigate_os', arguments: {'action': 'recents'});
    }

    // YouTube
    if (lower.contains('youtube') && (lower.contains('search') || lower.contains('tutorial'))) {
      String query = lower.replaceAll('youtube', '').replaceAll('search', '').replaceAll('খোলো', '').replaceAll('kholo', '').trim();
      return AndroidToolCall(toolName: 'open_youtube', arguments: {'query': query.isNotEmpty ? query : null});
    }
    if (lower.contains('youtube kholo') || lower.contains('ইউটিউব খোলো') || lower.contains('open youtube')) {
      return AndroidToolCall(toolName: 'open_youtube', arguments: {});
    }

    // WhatsApp
    if (lower.contains('whatsapp') && (lower.contains('message') || lower.contains('মেসেজ'))) {
      return AndroidToolCall(toolName: 'open_whatsapp', arguments: {'message': 'Hello from JX AI'});
    }
    if (lower.contains('whatsapp kholo') || lower.contains('হোয়াটসঅ্যাপ খোলো') || lower.contains('open whatsapp')) {
      return AndroidToolCall(toolName: 'open_app', arguments: {'appName': 'WhatsApp'});
    }

    // Facebook
    if (lower.contains('facebook') || lower.contains('ফেসবুক')) {
      return AndroidToolCall(toolName: 'open_app', arguments: {'appName': 'Facebook'});
    }

    // Camera
    if (lower.contains('camera') || lower.contains('ক্যামেরা')) {
      return AndroidToolCall(toolName: 'open_camera', arguments: {'mode': 'photo'});
    }

    return null;
  }
}
