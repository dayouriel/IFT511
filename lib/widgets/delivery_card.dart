import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/delivery.dart';
import 'status_badge.dart';

class DeliveryCard extends StatelessWidget {
  final Delivery delivery;
  final VoidCallback onTap;
  final Function(DeliveryStatus) onStatusChange;

  const DeliveryCard({
    super.key,
    required this.delivery,
    required this.onTap,
    required this.onStatusChange,
  });

  Color get _borderColor {
    switch (delivery.status) {
      case DeliveryStatus.delivered:
        return const Color(0xFF059669);
      case DeliveryStatus.inProgress:
        return const Color(0xFF00D4FF);
      case DeliveryStatus.failed:
        return const Color(0xFFDC2626);
      case DeliveryStatus.pending:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final timeFormat = DateFormat('h:mm a');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: _borderColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
              child: Row(
                children: [
                  // Stop number bubble
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A2463),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${delivery.stopNumber}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivery.customerName,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0A2463),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          timeFormat.format(delivery.scheduledTime),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: delivery.status),
                ],
              ),
            ),

            // Address row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded,
                      size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      delivery.address,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            const Divider(height: 1),

            // Footer: items count + amount + quick action
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 12),
              child: Row(
                children: [
                  Icon(Icons.inventory_2_rounded,
                      size: 16, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Text(
                    '${delivery.items.length} products  •  ${delivery.totalUnits} units',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    currency.format(delivery.totalAmount),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Quick-action chevron
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF0A2463),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Quick status buttons (only for pending/in-progress)
            if (delivery.isPending || delivery.isInProgress)
              _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFF),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      child: Row(
        children: [
          if (delivery.isPending)
            Expanded(
              child: _QuickButton(
                label: 'Start',
                icon: Icons.play_arrow_rounded,
                color: const Color(0xFF0A2463),
                onTap: () => onStatusChange(DeliveryStatus.inProgress),
                isLeft: true,
              ),
            ),
          if (delivery.isInProgress) ...[
            Expanded(
              child: _QuickButton(
                label: 'Delivered',
                icon: Icons.check_rounded,
                color: const Color(0xFF059669),
                onTap: () => onStatusChange(DeliveryStatus.delivered),
                isLeft: true,
              ),
            ),
            Expanded(
              child: _QuickButton(
                label: 'Failed',
                icon: Icons.close_rounded,
                color: const Color(0xFFDC2626),
                onTap: () => onStatusChange(DeliveryStatus.failed),
                isLeft: false,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLeft;

  const _QuickButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.only(
        bottomLeft: isLeft ? const Radius.circular(18) : Radius.zero,
        bottomRight: !isLeft ? const Radius.circular(18) : Radius.zero,
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
            right: isLeft ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
