import 'package:flutter/material.dart';
import '../../services/assistant_state_manager.dart';
import '../../models/assistant_state.dart';
import 'security_auth_screen.dart';
import 'gemini_setup_screen.dart';
import 'permission_center_screen.dart';
import 'jx_connecting_screen.dart';
import 'jx_online_screen.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  @override
  void initState() {
    super.initState();
    AssistantStateManager.instance.evaluateInitialStep();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AssistantStateManager.instance,
      builder: (context, child) {
        final state = AssistantStateManager.instance.state;

        switch (state) {
          case AssistantConnectionState.initial:
            return const Scaffold(
              backgroundColor: Color(0xFF080C14),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF00F2FE)),
              ),
            );

          case AssistantConnectionState.authRequired:
            return SecurityAuthScreen(
              onAuthenticated: () async {
                await AssistantStateManager.instance.onAuthenticated();
              },
            );

          case AssistantConnectionState.authenticated:
          case AssistantConnectionState.apiRequired:
          case AssistantConnectionState.apiConnecting:
            return GeminiSetupScreen(
              onConnected: () {
                AssistantStateManager.instance.setState(AssistantConnectionState.permissionsRequired);
              },
            );

          case AssistantConnectionState.apiConnected:
          case AssistantConnectionState.permissionsRequired:
            return PermissionCenterScreen(
              onCompleted: () {
                AssistantStateManager.instance.startConnectingSequence();
              },
            );

          case AssistantConnectionState.initializing:
            return JXConnectingScreen(
              onOnline: () {
                AssistantStateManager.instance.setState(AssistantConnectionState.online);
              },
            );

          case AssistantConnectionState.online:
          default:
            return const JXOnlineScreen();
        }
      },
    );
  }
}
