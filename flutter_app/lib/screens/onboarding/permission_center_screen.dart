import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/assistant_state.dart';
import '../../services/permission_service.dart';
import '../../services/assistant_state_manager.dart';

class PermissionCenterScreen extends StatefulWidget {
  final VoidCallback? onCompleted;

  const PermissionCenterScreen({super.key, this.onCompleted});

  @override
  State<PermissionCenterScreen> createState() => _PermissionCenterScreenState();
}

class _PermissionCenterScreenState extends State<PermissionCenterScreen> {
  late List<PermissionCardModel> _cards;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cards = PermissionService.instance.getInitialCards();
    _refreshPermissions();
  }

  Future<void> _refreshPermissions() async {
    setState(() => _isLoading = true);
    await PermissionService.instance.refreshStatuses(_cards);
    if (mounted) setState(() => _isLoading = false);
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'mic':
        return LucideIcons.mic;
      case 'camera':
        return LucideIcons.camera;
      case 'map-pin':
        return LucideIcons.mapPin;
      case 'bell':
        return LucideIcons.bell;
      case 'accessibility':
        return LucideIcons.accessibility;
      case 'monitor':
        return LucideIcons.monitor;
      case 'phone':
        return LucideIcons.phone;
      case 'users':
        return LucideIcons.users;
      default:
        return LucideIcons.shield;
    }
  }

  Color _getStatusColor(AndroidPermissionStatus status) {
    switch (status) {
      case AndroidPermissionStatus.granted:
        return const Color(0xFF00F2FE);
      case AndroidPermissionStatus.setupRequired:
        return const Color(0xFFFF007A);
      case AndroidPermissionStatus.denied:
        return Colors.redAccent;
      case AndroidPermissionStatus.notGranted:
        return Colors.amberAccent;
      case AndroidPermissionStatus.notRequired:
        return Colors.white38;
    }
  }

  String _getStatusText(AndroidPermissionStatus status) {
    switch (status) {
      case AndroidPermissionStatus.granted:
        return 'GRANTED ✓';
      case AndroidPermissionStatus.setupRequired:
        return 'SETUP REQUIRED';
      case AndroidPermissionStatus.denied:
        return 'DENIED';
      case AndroidPermissionStatus.notGranted:
        return 'NOT GRANTED';
      case AndroidPermissionStatus.notRequired:
        return 'NOT REQUIRED';
    }
  }

  Future<void> _handleCardAction(PermissionCardModel card) async {
    // Show clear rationale dialog
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF121826),
        title: Row(
          children: [
            Icon(_getIconData(card.iconName), color: const Color(0xFF00F2FE), size: 20),
            const SizedBox(width: 10),
            Text(card.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.purpose, style: const TextStyle(color: Color(0xFFFF007A), fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 10),
            Text(card.rationale, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
            if (card.isSpecialPermission) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF080C14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.3)),
                ),
                child: const Text(
                  'ℹ️ Android requires opening system settings or confirmation dialogs to toggle this feature.',
                  style: TextStyle(color: Color(0xFF00F2FE), fontSize: 11),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00F2FE),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await PermissionService.instance.requestPermission(card);
              await _refreshPermissions();
            },
            child: Text(card.isSpecialPermission ? 'OPEN SYSTEM FLOW' : 'ALLOW PERMISSION'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGrantAllAvailable() async {
    setState(() => _isLoading = true);
    await PermissionService.instance.grantAllAvailable(_cards);
    await _refreshPermissions();
  }

  void _proceedToConnecting() {
    if (widget.onCompleted != null) {
      widget.onCompleted!();
    } else {
      AssistantStateManager.instance.startConnectingSequence();
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
          'JX Permission Center',
          style: TextStyle(
            color: Color(0xFF00F2FE),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF00F2FE), size: 18),
            onPressed: _refreshPermissions,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Give JX the permissions it needs to become your personal assistant.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: _handleGrantAllAvailable,
                      icon: const Icon(LucideIcons.shieldCheck, size: 16),
                      label: const Text(
                        'GRANT ALL RUNTIME PERMISSIONS',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00F2FE),
                        side: const BorderSide(color: Color(0xFF00F2FE)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Permissions Card List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  final statusColor = _getStatusColor(card.status);
                  final isGranted = card.status == AndroidPermissionStatus.granted;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121826),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isGranted ? const Color(0xFF00F2FE).withOpacity(0.3) : Colors.white10,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Box
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF080C14),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: statusColor.withOpacity(0.4)),
                          ),
                          child: Icon(_getIconData(card.iconName), color: statusColor, size: 20),
                        ),
                        const SizedBox(width: 12),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    card.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: statusColor.withOpacity(0.6)),
                                    ),
                                    child: Text(
                                      _getStatusText(card.status),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                card.purpose,
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 32,
                                child: isGranted
                                    ? const Row(
                                        children: [
                                          Icon(LucideIcons.check, size: 14, color: Color(0xFF00F2FE)),
                                          SizedBox(width: 6),
                                          Text(
                                            'Active & Ready',
                                            style: TextStyle(color: Color(0xFF00F2FE), fontSize: 11, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      )
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: card.isSpecialPermission ? const Color(0xFFFF007A) : const Color(0xFF00F2FE),
                                          foregroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: () => _handleCardAction(card),
                                        child: Text(
                                          card.isSpecialPermission ? 'SETUP' : 'ALLOW',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Continue
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF121826),
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(LucideIcons.arrowRight, size: 18),
                      label: const Text(
                        'INITIALIZE JX AI ASSISTANT',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF007A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _proceedToConnecting,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Optional permissions can be enabled anytime from Settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.white38),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
