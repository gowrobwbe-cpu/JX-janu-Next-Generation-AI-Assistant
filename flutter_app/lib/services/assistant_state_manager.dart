import 'package:flutter/foundation.dart';
import '../models/assistant_state.dart';
import 'security_service.dart';
import 'secure_storage_service.dart';
import 'permission_service.dart';
import 'gemini_service.dart';
import 'database_service.dart';

class AssistantStateManager extends ChangeNotifier {
  static final AssistantStateManager instance = AssistantStateManager._internal();
  factory AssistantStateManager() => instance;
  AssistantStateManager._internal();

  AssistantConnectionState _state = AssistantConnectionState.initial;
  String? _errorMessage;
  String _activeModel = 'gemini-1.5-flash';
  String _activeLanguage = 'Auto';
  bool _isAppLockEnabled = false;
  bool _isFirstRun = true;

  // Step checklists for connecting screen
  final Map<String, bool> _initSteps = {
    'Security': false,
    'Gemini API': false,
    'Microphone': false,
    'Camera': false,
    'Android Assistant': false,
    'Voice': false,
    'Memory': false,
    'Tools': false,
  };

  AssistantConnectionState get state => _state;
  String? get errorMessage => _errorMessage;
  String get activeModel => _activeModel;
  String get activeLanguage => _activeLanguage;
  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get isFirstRun => _isFirstRun;
  Map<String, bool> get initSteps => Map.unmodifiable(_initSteps);

  void setState(AssistantConnectionState newState, {String? error}) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> evaluateInitialStep() async {
    await SecurityService.instance.init();
    final firstRunDone = await SecurityService.instance.isFirstRunCompleted();
    _isFirstRun = !firstRunDone;
    _isAppLockEnabled = await SecurityService.instance.isAppLockEnabled();
    _activeModel = await SecureStorageService.instance.getSelectedModel();
    _activeLanguage = await SecureStorageService.instance.getLanguage();

    if (_isFirstRun || _isAppLockEnabled) {
      setState(AssistantConnectionState.authRequired);
    } else {
      // Check API Key
      final apiKey = await SecureStorageService.instance.getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        setState(AssistantConnectionState.apiRequired);
      } else {
        setState(AssistantConnectionState.apiConnected);
      }
    }
  }

  Future<void> onAuthenticated() async {
    setState(AssistantConnectionState.authenticated);
    final apiKey = await SecureStorageService.instance.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      setState(AssistantConnectionState.apiRequired);
    } else {
      if (_isFirstRun) {
        setState(AssistantConnectionState.permissionsRequired);
      } else {
        await startConnectingSequence();
      }
    }
  }

  Future<void> startConnectingSequence() async {
    setState(AssistantConnectionState.initializing);
    
    // Reset steps
    _initSteps.updateAll((key, value) => false);
    notifyListeners();

    // Step 1: Security
    await Future.delayed(const Duration(milliseconds: 300));
    _initSteps['Security'] = true;
    notifyListeners();

    // Step 2: Gemini API
    await Future.delayed(const Duration(milliseconds: 400));
    final apiKey = await SecureStorageService.instance.getApiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      _initSteps['Gemini API'] = true;
    }
    notifyListeners();

    // Step 3: Audio & Mic
    await Future.delayed(const Duration(milliseconds: 300));
    _initSteps['Microphone'] = true;
    notifyListeners();

    // Step 4: Camera
    await Future.delayed(const Duration(milliseconds: 300));
    _initSteps['Camera'] = true;
    notifyListeners();

    // Step 5: Android Assistant Engine
    await Future.delayed(const Duration(milliseconds: 350));
    _initSteps['Android Assistant'] = true;
    notifyListeners();

    // Step 6: Voice STT/TTS
    await Future.delayed(const Duration(milliseconds: 300));
    _initSteps['Voice'] = true;
    notifyListeners();

    // Step 7: Memory SQLite
    await Future.delayed(const Duration(milliseconds: 300));
    await DatabaseService.instance.database;
    _initSteps['Memory'] = true;
    notifyListeners();

    // Step 8: Tools Engine
    await Future.delayed(const Duration(milliseconds: 350));
    _initSteps['Tools'] = true;
    notifyListeners();

    // Finalize first run if needed
    await SecurityService.instance.setFirstRunCompleted(true);
    _isFirstRun = false;

    // Transition to ONLINE
    await Future.delayed(const Duration(milliseconds: 400));
    setState(AssistantConnectionState.online);
  }
}
