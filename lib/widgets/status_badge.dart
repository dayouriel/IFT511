import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/delivery.dart';

class StatusBadge extends StatelessWidget {
  final DeliveryStatus status;
  final bool large;

  const StatusBadge({
    super.key,
    required this.status,
    this.large = false,
  });

  Color get _bgColor {
    switch (status) {
      case DeliveryStatus.pending:
        return const Color(0xFFFEF3C7);
      case DeliveryStatus.inProgress:
        return const Color(0xFFE0F7FF);
      case DeliveryStatus.delivered:
        return const Color(0xFFD1FAE5);
      case DeliveryStatus.failed:
        return const Color(0xFFFEE2E2);
    }
  }

  Color get _textColor {
    switch (status) {
      case DeliveryStatus.pending:
        return const Color(0xFFD97706);
      case DeliveryStatus.inProgress:
        return const Color(0xFF0284C7);
      case DeliveryStatus.delivered:
        return const Color(0xFF059669);
      case DeliveryStatus.failed:
        return const Color(0xFFDC2626);
    }
  }

  IconData get _icon {
    switch (status) {
      case DeliveryStatus.pending:
        return Icons.schedule_rounded;
      case DeliveryStatus.inProgress:
        return Icons.local_shipping_rounded;
      case DeliveryStatus.delivered:
        return Icons.check_circle_rounded;
      case DeliveryStatus.failed:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = large ? 14.0 : 12.0;
    final iconSize = large ? 16.0 : 13.0;
    final hPad = large ? 12.0 : 8.0;
    final vPad = large ? 8.0 : 5.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _textColor, size: iconSize),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}
