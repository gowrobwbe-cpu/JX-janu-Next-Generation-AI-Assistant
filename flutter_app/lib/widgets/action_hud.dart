import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/android_tool_models.dart';

class ActionHUDOverlay extends StatelessWidget {
  final ActionHUDState state;
  final VoidCallback? onDismiss;

  const ActionHUDOverlay({
    Key? key,
    required this.state,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (state.status == ActionExecutionStatus.idle) {
      return const SizedBox.shrink();
    }

    final isExecuting = state.status == ActionExecutionStatus.executing;
    final isCompleted = state.status == ActionExecutionStatus.completed;
    final isFailed = state.status == ActionExecutionStatus.failed;

    final primaryColor = isCompleted
        ? const Color(0xFF00FFCC)
        : isFailed
            ? const Color(0xFFFF0055)
            : const Color(0xFFFF007F);

    final statusIcon = isCompleted
        ? LucideIcons.checkCircle2
        : isFailed
            ? LucideIcons.alertTriangle
            : LucideIcons.cpu;

    final statusLabel = isCompleted
        ? "Completed ✓"
        : isFailed
            ? "Action Failed ✕"
            : "Executing Android Action...";

    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0E15).withOpacity(0.94),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryColor.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.25),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              // Glowing Status Avatar / Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.15),
                  border: Border.all(color: primaryColor, width: 1.5),
                ),
                child: Center(
                  child: isExecuting
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        )
                      : Icon(
                          statusIcon,
                          color: primaryColor,
                          size: 22,
                        ),
                ),
              ),

              const SizedBox(width: 14),

              // Title and Action Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          "JX ACTION",
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusLabel,
                          style: GoogleFonts.rajdhani(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${state.actionTitle} ${state.actionDetail}",
                      style: GoogleFonts.rajdhani(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Dismiss / Close button if finished
              if (!isExecuting && onDismiss != null)
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.white54, size: 18),
                  onPressed: onDismiss,
                  splashRadius: 20,
                ),
            ],
          ),
        )
            .animate()
            .slideY(begin: -0.5, end: 0, duration: 250.ms, curve: Curves.easeOutCubic)
            .fadeIn(duration: 200.ms),
      ),
    );
  }
}
