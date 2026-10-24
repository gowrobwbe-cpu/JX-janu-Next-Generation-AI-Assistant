import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/assistant_state.dart';

class PermissionService {
  static final PermissionService instance = PermissionService._internal();
  factory PermissionService() => instance;
  PermissionService._internal();

  static const MethodChannel _systemChannel = MethodChannel('com.jx.ai/system');

  List<PermissionCardModel> getInitialCards() {
    return [
      PermissionCardModel(
        id: 'microphone',
        title: 'Microphone',
        iconName: 'mic',
        purpose: 'Real-time voice conversation.',
        rationale: 'Required for natural real-time speech interaction and voice commands with JX.',
        isSpecialPermission: false,
        androidManifestName: 'android.permission.RECORD_AUDIO',
      ),
      PermissionCardModel(
        id: 'camera',
        title: 'Camera',
        iconName: 'camera',
        purpose: 'JX vision and camera assistance.',
        rationale: 'Allows JX to see what you are looking at and provide visual analysis on command.',
        isSpecialPermission: false,
        androidManifestName: 'android.permission.CAMERA',
      ),
      PermissionCardModel(
        id: 'location',
        title: 'Location',
        iconName: 'map-pin',
        purpose: 'Location-aware assistance and maps.',
        rationale: 'Enables JX to provide local weather, navigation routes, and area-specific information.',
        isSpecialPermission: false,
        androidManifestName: 'android.permission.ACCESS_FINE_LOCATION',
      ),
      PermissionCardModel(
        id: 'notifications',
        title: 'Notifications',
        iconName: 'bell',
        purpose: 'Allow JX to understand notifications when explicitly enabled.',
        rationale: 'Used to alert you to incoming reminders and notify you of background events.',
        isSpecialPermission: false,
        androidManifestName: 'android.permission.POST_NOTIFICATIONS',
      ),
      PermissionCardModel(
        id: 'accessibility',
        title: 'Accessibility Service',
        iconName: 'accessibility',
        purpose: 'Interact with Android UI elements & perform navigation actions.',
        rationale: 'Accessibility allows JX to interact with supported buttons and UI elements (Back, Home, Recents). Android requires you to enable this manually in Settings.',
        isSpecialPermission: true,
        androidManifestName: 'android.permission.BIND_ACCESSIBILITY_SERVICE',
      ),
      PermissionCardModel(
        id: 'screen_assistant',
        title: 'Screen Assistant',
        iconName: 'monitor',
        purpose: 'Analyze the visible screen when explicitly initiated.',
        rationale: 'Screen capture allows JX to understand what is currently visible on your screen. Android will show a system confirmation before capture begins.',
        isSpecialPermission: true,
        androidManifestName: 'android.media.projection.MediaProjection',
      ),
      PermissionCardModel(
        id: 'phone',
        title: 'Phone',
        iconName: 'phone',
        purpose: 'Call assistance.',
        rationale: 'Allows JX to prepare phone dials to contacts on your command.',
        isSpecialPermission: false,
        androidManifestName: 'android.permission.CALL_PHONE',
      ),
      PermissionCardModel(
        id: 'contacts',
        title: 'Contacts',
        iconName: 'users',
        purpose: 'Find contacts when asking JX to call or message someone.',
        rationale: 'Enables resolving names like "Mom" or friend names to their numbers safely.',
        isSpecialPermission: false,
        androidManifestName: 'android.permission.READ_CONTACTS',
      ),
    ];
  }

  Future<void> refreshStatuses(List<PermissionCardModel> cards) async {
    for (final card in cards) {
      if (card.isSpecialPermission) {
        if (card.id == 'accessibility') {
          final isEnabled = await isAccessibilityServiceEnabled();
          card.status = isEnabled ? AndroidPermissionStatus.granted : AndroidPermissionStatus.setupRequired;
        } else if (card.id == 'screen_assistant') {
          // Screen capture is requested on-demand per session with MediaProjection
          card.status = AndroidPermissionStatus.setupRequired;
        }
      } else {
        final perm = _getPermissionFromId(card.id);
        if (perm != null) {
          final status = await perm.status;
          if (status.isGranted) {
            card.status = AndroidPermissionStatus.granted;
          } else if (status.isPermanentlyDenied) {
            card.status = AndroidPermissionStatus.denied;
          } else {
            card.status = AndroidPermissionStatus.notGranted;
          }
        }
      }
    }
  }

  Permission? _getPermissionFromId(String id) {
    switch (id) {
      case 'microphone':
        return Permission.microphone;
      case 'camera':
        return Permission.camera;
      case 'location':
        return Permission.location;
      case 'notifications':
        return Permission.notification;
      case 'phone':
        return Permission.phone;
      case 'contacts':
        return Permission.contacts;
      default:
        return null;
    }
  }

  Future<AndroidPermissionStatus> requestPermission(PermissionCardModel card) async {
    if (card.isSpecialPermission) {
      if (card.id == 'accessibility') {
        await openAccessibilitySettings();
        return AndroidPermissionStatus.setupRequired;
      } else if (card.id == 'screen_assistant') {
        // Trigger system MediaProjection intent
        await triggerScreenCaptureConsent();
        return AndroidPermissionStatus.granted;
      }
      return AndroidPermissionStatus.setupRequired;
    }

    final perm = _getPermissionFromId(card.id);
    if (perm == null) return AndroidPermissionStatus.notRequired;

    final result = await perm.request();
    if (result.isGranted) {
      card.status = AndroidPermissionStatus.granted;
    } else if (result.isPermanentlyDenied) {
      card.status = AndroidPermissionStatus.denied;
    } else {
      card.status = AndroidPermissionStatus.notGranted;
    }
    return card.status;
  }

  /// Request all standard runtime permissions directly in sequence
  Future<void> grantAllAvailable(List<PermissionCardModel> cards) async {
    final permissionsToRequest = <Permission>[];
    for (final card in cards) {
      if (!card.isSpecialPermission && card.status != AndroidPermissionStatus.granted) {
        final p = _getPermissionFromId(card.id);
        if (p != null) permissionsToRequest.add(p);
      }
    }

    if (permissionsToRequest.isNotEmpty) {
      final statuses = await permissionsToRequest.request();
      for (final card in cards) {
        final p = _getPermissionFromId(card.id);
        if (p != null && statuses.containsKey(p)) {
          final res = statuses[p]!;
          if (res.isGranted) {
            card.status = AndroidPermissionStatus.granted;
          } else if (res.isPermanentlyDenied) {
            card.status = AndroidPermissionStatus.denied;
          } else {
            card.status = AndroidPermissionStatus.notGranted;
          }
        }
      }
    }
  }

  Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final bool? enabled = await _systemChannel.invokeMethod<bool>('isAccessibilityEnabled');
      return enabled ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openAccessibilitySettings() async {
    try {
      await _systemChannel.invokeMethod('openAccessibilitySettings');
    } catch (_) {
      await openAppSettings();
    }
  }

  Future<void> triggerScreenCaptureConsent() async {
    try {
      await _systemChannel.invokeMethod('requestMediaProjection');
    } catch (_) {
      // Fallback
    }
  }
}
