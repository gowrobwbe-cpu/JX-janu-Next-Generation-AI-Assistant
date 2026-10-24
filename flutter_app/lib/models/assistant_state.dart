enum AssistantConnectionState {
  initial,
  authRequired,
  authenticated,
  apiRequired,
  apiConnecting,
  apiConnected,
  permissionsRequired,
  initializing,
  online,
  offline,
  error,
}

enum JXLanguagePreference {
  auto,
  bengali,
  english,
}

enum AndroidPermissionStatus {
  notRequired,
  notGranted,
  granted,
  setupRequired,
  denied,
}

class PermissionCardModel {
  final String id;
  final String title;
  final String iconName;
  final String purpose;
  final String rationale;
  final bool isSpecialPermission;
  final String androidManifestName;
  AndroidPermissionStatus status;

  PermissionCardModel({
    required this.id,
    required this.title,
    required this.iconName,
    required this.purpose,
    required this.rationale,
    required this.isSpecialPermission,
    required this.androidManifestName,
    this.status = AndroidPermissionStatus.notGranted,
  });
}
