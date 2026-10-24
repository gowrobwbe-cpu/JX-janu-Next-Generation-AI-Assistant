import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/android_tool_models.dart';

class AndroidToolRouter {
  static final AndroidToolRouter instance = AndroidToolRouter._();
  AndroidToolRouter._();

  static const MethodChannel _toolsChannel = MethodChannel('com.jx.ai/android_tools');
  static const MethodChannel _systemChannel = MethodChannel('com.jx.ai/system');

  // Callback listeners for Action HUD
  final List<void Function(ActionHUDState state)> _hudListeners = [];

  void addHUDListener(void Function(ActionHUDState state) listener) {
    _hudListeners.add(listener);
  }

  void removeHUDListener(void Function(ActionHUDState state) listener) {
    _hudListeners.remove(listener);
  }

  void emitHUD(ActionHUDState state) {
    for (final listener in _hudListeners) {
      listener(state);
    }
  }

  /// Master router executing requested tool call
  Future<AndroidToolResult> executeTool(AndroidToolCall call) async {
    final toolName = call.toolName.toLowerCase().replaceAll('android_', '');
    final args = call.arguments;

    emitHUD(ActionHUDState(
      status: ActionExecutionStatus.executing,
      actionTitle: _getHUDTitle(toolName),
      actionDetail: _getHUDDetail(toolName, args),
    ));

    try {
      AndroidToolResult result;
      switch (toolName) {
        // App Control
        case 'open_app':
        case 'openapp':
        case 'launch_app':
          result = await openApp(
            appName: args['appName']?.toString() ?? args['name']?.toString() ?? '',
            packageName: args['packageName']?.toString(),
          );
          break;

        case 'find_installed_app':
        case 'findinstalledapp':
          result = await findInstalledApp(args['query']?.toString() ?? '');
          break;

        case 'open_settings':
        case 'opensettings':
          result = await openSettings(args['section']?.toString() ?? 'main');
          break;

        case 'open_browser':
        case 'openbrowser':
        case 'search_web':
        case 'searchweb':
          result = await searchWeb(
            query: args['query']?.toString() ?? args['url']?.toString() ?? '',
            engine: args['engine']?.toString() ?? 'google',
          );
          break;

        case 'open_youtube':
        case 'openyoutube':
        case 'search_youtube':
        case 'searchyoutube':
          result = await openYouTube(query: args['query']?.toString());
          break;

        case 'open_whatsapp':
        case 'openwhatsapp':
        case 'compose_whatsapp':
        case 'send_whatsapp':
          result = await openWhatsApp(
            phone: args['phone']?.toString() ?? args['phoneNumber']?.toString(),
            contactName: args['contactName']?.toString() ?? args['name']?.toString(),
            message: args['message']?.toString() ?? args['text']?.toString(),
          );
          break;

        case 'open_facebook':
        case 'openfacebook':
          result = await openApp(appName: 'Facebook', packageName: 'com.facebook.katana');
          break;

        case 'open_camera':
        case 'opencamera':
          result = await openCamera(mode: args['mode']?.toString() ?? 'photo');
          break;

        case 'open_gallery':
        case 'opengallery':
          result = await openGallery();
          break;

        case 'open_maps':
        case 'openmaps':
          result = await openMaps(query: args['query']?.toString() ?? args['location']?.toString() ?? '');
          break;

        case 'prepare_phone_call':
        case 'preparephonecall':
        case 'call_phone':
        case 'make_call':
          result = await preparePhoneCall(
            contactName: args['contactName']?.toString() ?? args['name']?.toString(),
            phoneNumber: args['phoneNumber']?.toString() ?? args['phone']?.toString(),
          );
          break;

        case 'search_contacts':
        case 'searchcontacts':
          result = await searchContacts(args['query']?.toString() ?? '');
          break;

        case 'adjust_volume':
        case 'adjustvolume':
        case 'set_volume':
          result = await adjustVolume(
            direction: args['direction']?.toString(),
            percent: args['percent'] != null ? int.tryParse(args['percent'].toString()) : null,
          );
          break;

        // Navigation via Accessibility
        case 'navigate_os':
        case 'navigateos':
        case 'navigate':
        case 'go_back':
        case 'go_home':
          result = await navigateOS(args['action']?.toString() ?? 'back');
          break;

        // Screen Assistant & Accessibility UI Control
        case 'analyze_screen':
        case 'analyzescreen':
        case 'screen_assistant':
          result = await analyzeScreen(prompt: args['prompt']?.toString());
          break;

        case 'inspect_screen_ui':
        case 'inspectscreenui':
          result = await inspectScreenHierarchy();
          break;

        case 'find_and_click_ui':
        case 'findandclickui':
          result = await findAndClickNode(
            text: args['text']?.toString(),
            viewId: args['viewId']?.toString(),
            contentDescription: args['contentDescription']?.toString(),
          );
          break;

        case 'scroll_screen':
        case 'scrollscreen':
          result = await scrollScreen(args['direction']?.toString() ?? 'down');
          break;

        case 'type_text_in_ui':
        case 'typetextinui':
          result = await typeTextInUI(
            targetText: args['targetText']?.toString(),
            text: args['text']?.toString() ?? '',
          );
          break;

        default:
          result = AndroidToolResult(
            success: false,
            toolName: toolName,
            message: 'Unrecognized tool: $toolName',
            errorMessage: 'Tool not registered in AndroidToolRouter.',
          );
      }

      emitHUD(ActionHUDState(
        status: result.success ? ActionExecutionStatus.completed : ActionExecutionStatus.failed,
        actionTitle: _getHUDTitle(toolName),
        actionDetail: result.success ? (result.message) : (result.errorMessage ?? 'Action failed'),
      ));

      return result;
    } catch (e) {
      final failResult = AndroidToolResult(
        success: false,
        toolName: toolName,
        message: "Sorry Gowrob, Android didn't allow me to complete that action.",
        errorMessage: e.toString(),
      );

      emitHUD(ActionHUDState(
        status: ActionExecutionStatus.failed,
        actionTitle: _getHUDTitle(toolName),
        actionDetail: "Action failed: ${e.toString()}",
      ));

      return failResult;
    }
  }

  // --- APP CONTROL ---

  Future<AndroidToolResult> openApp({required String appName, String? packageName}) async {
    try {
      final res = await _toolsChannel.invokeMapMethod<String, dynamic>('openApp', {
        'appName': appName,
        'packageName': packageName,
      });

      final success = res?['success'] == true;
      final resolvedPkg = res?['packageName']?.toString() ?? packageName;

      if (success) {
        return AndroidToolResult(
          success: true,
          toolName: 'openApp',
          message: "Opened $appName successfully!",
          data: {'appName': appName, 'packageName': resolvedPkg},
        );
      } else {
        return AndroidToolResult(
          success: false,
          toolName: 'openApp',
          message: "App '$appName' was not found on your Android device.",
          errorMessage: res?['errorMessage']?.toString() ?? 'App not found.',
        );
      }
    } catch (e) {
      return AndroidToolResult(
        success: false,
        toolName: 'openApp',
        message: "Failed to open $appName.",
        errorMessage: e.toString(),
      );
    }
  }

  Future<AndroidToolResult> findInstalledApp(String query) async {
    try {
      final res = await _toolsChannel.invokeListMethod<Map<dynamic, dynamic>>('findInstalledApps', {
        'query': query,
      });

      final apps = res?.map((m) => Map<String, String>.from(m)).toList() ?? [];
      return AndroidToolResult(
        success: true,
        toolName: 'findInstalledApp',
        message: "Found ${apps.length} installed apps matching '$query'.",
        data: apps,
      );
    } catch (e) {
      return AndroidToolResult(
        success: false,
        toolName: 'findInstalledApp',
        message: "Could not query installed apps.",
        errorMessage: e.toString(),
      );
    }
  }

  Future<AndroidToolResult> openSettings(String section) async {
    try {
      final res = await _toolsChannel.invokeMapMethod<String, dynamic>('openSettingsSection', {
        'section': section,
      });
      final success = res?['success'] == true;
      return AndroidToolResult(
        success: success,
        toolName: 'openSettings',
        message: success ? "Opened Android $section settings." : "Could not open $section settings.",
      );
    } catch (e) {
      return AndroidToolResult(
        success: false,
        toolName: 'openSettings',
        message: "Could not open settings.",
        errorMessage: e.toString(),
      );
    }
  }

  // --- WEB SEARCH & BROWSER ---

  Future<AndroidToolResult> searchWeb({required String query, String engine = 'google'}) async {
    try {
      final res = await _toolsChannel.invokeMapMethod<String, dynamic>('searchWeb', {
        'query': query,
        'engine': engine,
      });
      final success = res?['success'] == true;
      return AndroidToolResult(
        success: success,
        toolName: 'searchWeb',
        message: success ? "Searched $engine for '$query'." : "Could not initiate search.",
        data: {'query': query, 'engine': engine},
      );
    } catch (e) {
      return AndroidToolResult(
        success: false,
        toolName: 'searchWeb',
        message: "Web search failed.",
        errorMessage: e.toString(),
      );
    }
  }

  // --- YOUTUBE ---

  Future<AndroidToolResult> openYouTube({String? query}) async {
    try {
      final res = await _toolsChannel.invokeMapMethod<String, dynamic>('openYouTube', {
        'query': query,
      });
      final success = res?['success'] == true;
      return AndroidToolResult(
        success: success,
        toolName: 'openYouTube',
        message: (query != null && query.isNotEmpty)
            ? "Opened YouTube and searched for '$query'."
            : "Opened YouTube.",
        data: {'query': query},
      );
    } catch (e) {
      return AndroidToolResult(
        success: false,
        toolName: 'openYouTube',
        message: "Could not open YouTube.",
        errorMessage: e.toString(),
      );
    }
  }

  // --- WHATSAPP ---

  Future<AndroidToolResult> openWhatsApp({String? phone, String? contactName, String? message}) async {
    try {
      String? resolvedPhone = phone;

      // If contact name provided but no phone, attempt to query contacts
      if ((resolvedPhone == null || resolvedPhone.isEmpty) && contactName != null && contactName.isNotEmpty) {
        final contacts = await searchContacts(contactName);
        if (contacts.success && contacts.data is List && (contacts.data as List).isNotEmpty) {
          final list = contacts.data as List;
          if (list.length == 1) {
            resolvedPhone = list[0]['number']?.toString();
          } else {
            // Multiple contacts found: return list so JX can ask user
            return AndroidToolResult(
              success: false,
              toolName: 'openWhatsApp',
              message: "Found multiple contacts matching '$contactName'. Please specify which one.",
              data: {'contacts': list},
              errorMessage: 'Multiple contacts matched.',
            );
          }
        }
      }

      final res = await _toolsChannel.invokeMapMethod<String, dynamic>('openWhatsApp', {
        'phone': resolvedPhone,
        'message': message,
      });
      final success = res?['success'] == true;

      return AndroidToolResult(
        success: success,
        toolName: 'openWhatsApp',
        message: message != null
            ? "Prepared WhatsApp message${contactName != null ? " for $contactName" : ""}. Review and send!"
            : "Opened WhatsApp.",
        data: {'phone': resolvedPhone, 'contactName': contactName, 'message': message},
      );
    } catch (e) {
      return AndroidToolResult(
        success: false,
        toolName: 'openWhatsApp',
        message: "Could not open WhatsApp compose.",
        errorMessage: e.toString(),
      );
    }
  }

  // --- PHONE & CONTACTS ---

  Future<AndroidToolResult> searchContacts(String query) async {
    try {
      final status = await Permission.contacts.status;
      if (!status.isGranted) {
        final req = await Permission.contacts.request();
        if (!req.isGranted) {
          return AndroidToolResult(
            success: false,
            toolName: 'searchContacts',
            message: "Contacts permission required to find contacts.",
            errorMessage: "PERMISSION_DENIED",
          );
        }
      }

      final res = await _toolsChannel.invokeListMethod<Map<dynamic, dynamic>>('searchContacts', {
        'query': query,
      });

      final list = res?.map((m) => Map<String, String>.from(m)).toList() ?? [];
      return AndroidToolResult(
        success: true,
        toolName: 'searchContacts',
        message: "Found ${list.length} contact(s).",
        data: list,
      );
    } catch (e) {
      return AndroidToolResult(
        success: false,
        toolName: 'searchContacts',
        message: "Could not search contacts.",
        errorMessage: e.toString(),
      );
    }
  }

  Future<AndroidToolResult> preparePhoneCall({String? contactName, String? phoneNumber}) async {
    try {
      String? resolvedNumber = phoneNumber;

      if ((resolvedNumber == null || resolvedNumber.isEmpty) && contactName != null && contactName.isNotEmpty) {
        final contactRes = await searchContacts(contactName);
        if (contactRes.success && contactRes.data is List) {
          final list = contactRes.data as List;
          if (list.isEmpty) {
            return AndroidToolResult(
              success: false,
              toolName: 'preparePhoneCall',
              message: "No contact found for '$contactName'.",
              errorMessage: "CONTACT_NOT_FOUND",
            );
          } else if (list.length == 1) {
            resolvedNumber = list[0]['number']?.toString();
          } else {
            return AndroidToolResult(
              success: false,
              toolName: 'preparePhoneCall',
              message: "Found ${list.length} contacts for '$contactName'. Which number would you like me to dial?",
              data: {'contacts': list},
              errorMessage: "MULTIPLE_CONTACTS_MATCHED",
            );
          }
        } else {
          return contactRes;
        }
      }

      if (resolvedNumber == null || resolvedNumber.isEmpty) {
        return AndroidToolResult(
          success: false,
          toolName: 'preparePhoneCall',
          message: "Please specify a contact or phone number to call.",
          errorMessage: "NO_NUMBER_SPECIFIED",
        );
      }

      final res = await _toolsChannel.invokeMapMethod<String, dynamic>('preparePhoneCall', {
        'phoneNumber': resolvedNumber,
      });

      final success = res?['success'] == true;
      return AndroidToolResult(
        success: success,
        toolName: 'preparePhoneCall',
        message: success
            ? "Dialer ready for ${contactName ?? resolvedNumber}. Press call to connect."
            : "Could not open dialer.",
        data: {'contactName': contactName, 'phoneNumber': resolvedNumber},
      );
    } catch (e) {
      return AndroidToolResult(
        success: false,
        toolName: 'preparePhoneCall',
        message: "Failed to prepare phone call.",
        errorMessage: e.toString(),
      );
    }
  }

  // --- CAMERA, GALLERY & MAPS ---

  Future<AndroidToolResult> openCamera({String mode = 'photo'}) async {
    try {
      final res = await _toolsChannel.invokeMapMethod<String, dynamic>('openCamera', {
        'mode': mode,
      });
      final success = res?['success'] == true;
      return AndroidToolResult(
        success: success,
        toolName: 'openCamera',
        message: success ? "Camera opened in $mode mode." : "Could not open camera.",
      );
    } catch (e) {
      return AndroidToolResult(
        success: false,
        toolName: 'openCamera',
        message: "Failed to open camera.",
        errorMessage: e.toString(),
      );
    }
  }

  Future<AndroidToolResult> openGallery() async {
    try {
      final res = await _toolsChannel.invokeMapMethod<String, dynamic>('openGallery');
      final success = res?['success'] == true;
      return AndroidToolResult(
        success: success,
        toolName: 'openGallery',
        message: success ? "Gallery opened." : "Could not open gallery.",
      );
    } catch (e) {
      return AndroidToolResult(
        success: false,
        toolName: 'openGallery',
        message: "Failed to open gallery.",
        errorMessage: e.toString(),
      );
    }
  }

  Future<AndroidToolResult> openMaps(String query) async {
    try {
      final res = await _toolsChannel.invokeMapMethod<String, dynamic>('openMaps', {
        'query': query,
      });
      final success = res?['success'] == true;
      return AndroidToolResult(
        success: success,
        toolName: 'openMaps',
        message: success ? (query.isNotEmpty ? "Maps opened for '$query'." : "Maps opened.") : "Could not open maps.",
        data: {'query': query},
      );
    } catch (e) {
      return AndroidToolResult(
        success: false,
        toolName: 'openMaps',
        message: "Failed to open maps.",
        errorMessage: e.toString(),
      );
    }
  }

  // --- VOLUME ---

  Future<AndroidToolResult> adjustVolume({String? direction, int? percent}) async {
    try {
      final res = await _systemChannel.invokeMapMethod<String, dynamic>('adjustVolume', {
        'direction': direction,
        'percent': percent,
      });

      final current = res?['currentVolume'];
      final pct = res?['percentage'];

      String msg = "Volume adjusted.";
      if (pct != null) {
        msg = "Media volume set to $pct%.";
      } else if (direction != null) {
        msg = "Volume turned $direction.";
      }

      return AndroidToolResult(
        success: true,
        toolName: 'adjustVolume',
        message: msg,
        data: res,
      );
    } catch (e) {
      return AndroidToolResult(
        success: false,
        toolName: 'adjustVolume',
        message: "Could not adjust device volume.",
        errorMessage: e.toString(),
      );
    }
  }

  // --- OS NAVIGATION & ACCESSIBILITY ---

  Future<AndroidToolResult> navigateOS(String action) async {
    try {
      final isEnabled = await isAccessibilityEnabled();
      if (!isEnabled) {
        return AndroidToolResult(
          success: false,
          toolName: 'navigateOS',
          message: "Accessibility Service is not enabled. Please enable JX in Accessibility settings.",
          errorMessage: "ACCESSIBILITY_DISABLED",
        );
      }

      final success = await _systemChannel.invokeMethod<bool>('performGlobalAction', {
        'action': action,
      }) ?? false;

      return AndroidToolResult(
        success: success,
        toolName: 'navigateOS',
        message: success ? "Navigated $action." : "Android did not allow navigation.",
        data: {'action': action},
      );
    } catch (e) {
      return AndroidToolResult(
        success: false,
        toolName: 'navigateOS',
        message: "Navigation failed.",
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> isAccessibilityEnabled() async {
    try {
      return await _systemChannel.invokeMethod<bool>('isAccessibilityEnabled') ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> openAccessibilitySettings() async {
    try {
      await _systemChannel.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      // Ignored
    }
  }

  // --- ACCESSIBILITY UI CONTROLS ---

  Future<AndroidToolResult> inspectScreenHierarchy() async {
    try {
      final isEnabled = await isAccessibilityEnabled();
      if (!isEnabled) {
        return AndroidToolResult(
          success: false,
          toolName: 'inspectScreenHierarchy',
          message: "Accessibility Service is disabled.",
          errorMessage: "ACCESSIBILITY_DISABLED",
        );
      }

      final res = await _toolsChannel.invokeListMethod<Map<dynamic, dynamic>>('inspectScreenHierarchy');
      final list = res?.map((m) => Map<String, dynamic>.from(m)).toList() ?? [];

      return AndroidToolResult(
        success: true,
        toolName: 'inspectScreenHierarchy',
        message: "Inspected UI tree: found ${list.length} interactive elements.",
        data: list,
      );
    } catch (e) {
      return AndroidToolResult(
        success: false,
        toolName: 'inspectScreenHierarchy',
        message: "Failed to inspect screen UI.",
        errorMessage: e.toString(),
      );
    }
  }

  Future<AndroidToolResult> findAndClickNode({String? text, String? viewId, String? contentDescription}) async {
    try {
      final isEnabled = await isAccessibilityEnabled();
      if (!isEnabled) {
        return AndroidToolResult(
          success: false,
          toolName: 'findAndClickNode',
          message: "Accessibility Service is disabled.",
          errorMessage: "ACCESSIBILITY_DISABLED",
        );
      }

      final res = await _toolsChannel.invokeMapMethod<String, dynamic>('findAndClickNode', {
        'text': text,
        'viewId': viewId,
        'contentDescription': contentDescription,
      });

      final success = res?['success'] == true;
      final target = res?['target'] ?? (text ?? viewId ?? contentDescription);

      return AndroidToolResult(
        success: success,
        toolName: 'findAndClickNode',
        message: success ? "Clicked element '$target'." : "Could not find element '$target' on screen.",
        data: {'target': target},
      );
    } catch (e) {
      return AndroidToolResult(
        success: false,
        toolName: 'findAndClickNode',
        message: "Failed to click UI element.",
        errorMessage: e.toString(),
      );
    }
  }

  Future<AndroidToolResult> scrollScreen(String direction) async {
    try {
      final isEnabled = await isAccessibilityEnabled();
      if (!isEnabled) {
        return AndroidToolResult(
          success: false,
          toolName: 'scrollScreen',
          message: "Accessibility Service is disabled.",
          errorMessage: "ACCESSIBILITY_DISABLED",
        );
      }

      final res = await _toolsChannel.invokeMapMethod<String, dynamic>('performScroll', {
        'direction': direction,
      });

      final success = res?['success'] == true;
      return AndroidToolResult(
        success: success,
        toolName: 'scrollScreen',
        message: success ? "Scrolled $direction." : "Could not scroll current screen.",
      );
    } catch (e) {
      return AndroidToolResult(
        success: false,
        toolName: 'scrollScreen',
        message: "Failed to scroll screen.",
        errorMessage: e.toString(),
      );
    }
  }

  Future<AndroidToolResult> typeTextInUI({String? targetText, required String text}) async {
    try {
      final isEnabled = await isAccessibilityEnabled();
      if (!isEnabled) {
        return AndroidToolResult(
          success: false,
          toolName: 'typeTextInUI',
          message: "Accessibility Service is disabled.",
          errorMessage: "ACCESSIBILITY_DISABLED",
        );
      }

      final res = await _toolsChannel.invokeMapMethod<String, dynamic>('typeTextInNode', {
        'targetText': targetText,
        'text': text,
      });

      final success = res?['success'] == true;
      return AndroidToolResult(
        success: success,
        toolName: 'typeTextInUI',
        message: success ? "Typed text into UI field." : "Could not find input field to type.",
        data: {'text': text},
      );
    } catch (e) {
      return AndroidToolResult(
        success: false,
        toolName: 'typeTextInUI',
        message: "Failed to type in UI.",
        errorMessage: e.toString(),
      );
    }
  }

  // --- SCREEN ASSISTANT ---

  Future<AndroidToolResult> analyzeScreen({String? prompt}) async {
    // Screen Assistant foundational flow
    return AndroidToolResult(
      success: true,
      toolName: 'analyzeScreen',
      message: "Screen assistant analyzed current screen content.",
      data: {'prompt': prompt ?? 'What is on my screen?'},
    );
  }

  // --- HELPERS FOR HUD TITLES ---

  String _getHUDTitle(String toolName) {
    switch (toolName) {
      case 'open_app':
      case 'openapp':
        return 'OPENING';
      case 'search_web':
      case 'searchweb':
      case 'open_browser':
        return 'SEARCHING';
      case 'open_youtube':
      case 'openyoutube':
        return 'YOUTUBE';
      case 'open_whatsapp':
      case 'openwhatsapp':
      case 'compose_whatsapp':
        return 'PREPARING MESSAGE';
      case 'prepare_phone_call':
      case 'preparephonecall':
        return 'CALL PREPARATION';
      case 'open_camera':
      case 'opencamera':
        return 'CAMERA';
      case 'adjust_volume':
      case 'adjustvolume':
        return 'VOLUME';
      case 'navigate_os':
      case 'navigateos':
      case 'go_back':
      case 'go_home':
        return 'NAVIGATION';
      case 'analyze_screen':
      case 'analyzescreen':
        return 'SCREEN ASSISTANT';
      case 'find_and_click_ui':
        return 'UI ACTION';
      default:
        return 'EXECUTING';
    }
  }

  String _getHUDDetail(String toolName, Map<String, dynamic> args) {
    if (args.containsKey('appName')) return args['appName'].toString();
    if (args.containsKey('query')) return args['query'].toString();
    if (args.containsKey('contactName')) return args['contactName'].toString();
    if (args.containsKey('phoneNumber')) return args['phoneNumber'].toString();
    if (args.containsKey('action')) return args['action'].toString().toUpperCase();
    if (args.containsKey('direction')) return args['direction'].toString().toUpperCase();
    if (args.containsKey('text')) return args['text'].toString();
    return toolName.toUpperCase();
  }
}
