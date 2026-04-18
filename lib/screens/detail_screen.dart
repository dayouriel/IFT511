import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/delivery.dart';
import '../providers/delivery_provider.dart';
import '../widgets/status_badge.dart';
import '../widgets/action_button.dart';

class DetailScreen extends StatefulWidget {
  final Delivery delivery;

  const DetailScreen({super.key, required this.delivery});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _noteController = TextEditingController();
  bool _showNoteField = false;

  @override
  void initState() {
    super.initState();
    _noteController.text = widget.delivery.notes ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final provider = context.read<DeliveryProvider>();
    await provider.addNote(widget.delivery, _noteController.text.trim());
    setState(() => _showNoteField = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note saved', style: GoogleFonts.spaceGrotesk()),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _confirmStatusChange(
      DeliveryStatus newStatus, String label) async {
    HapticFeedback.mediumImpact();

    final confirm = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ConfirmSheet(
        delivery: widget.delivery,
        newStatus: newStatus,
        label: label,
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<DeliveryProvider>();
      await provider.updateStatus(widget.delivery, newStatus);
      HapticFeedback.heavyImpact();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final delivery = widget.delivery;
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFE8EDF5),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: const Color(0xFF0A2463),
            foregroundColor: Colors.white,
            pinned: true,
            title: Text(
              'Stop #${delivery.stopNumber}',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: StatusBadge(status: delivery.status),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Card
                  _buildCustomerCard(delivery),
                  const SizedBox(height: 16),

                  // Order Items
                  _buildSection(
                    title: 'Order Items',
                    icon: Icons.inventory_2_rounded,
                    child: _buildItemsList(delivery, currency),
                  ),
                  const SizedBox(height: 16),

                  // Total
                  _buildTotalCard(delivery, currency),
                  const SizedBox(height: 16),

                  // Delivery Info
                  _buildSection(
                    title: 'Delivery Info',
                    icon: Icons.schedule_rounded,
                    child: _buildDeliveryInfo(delivery),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  _buildNotesSection(delivery),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActions(delivery),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Delivery delivery) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2463),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            delivery.customerName,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.location_on_rounded, delivery.address, Colors.white70),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // In a real app, this would launch the dialer
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling ${delivery.phone}…',
                      style: GoogleFonts.spaceGrotesk()),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: _infoRow(
                Icons.phone_rounded, delivery.phone, const Color(0xFF00D4FF)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF0A2463), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0A2463),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }

  Widget _buildItemsList(Delivery delivery, NumberFormat currency) {
    return Column(
      children: [
        ...delivery.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${item.quantity}x',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0A2463),
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
                          item.displayName,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'SKU: ${item.sku}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currency.format(item.lineTotal),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildTotalCard(Delivery delivery, NumberFormat currency) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF059669),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 13, color: Colors.white70),
              ),
              Text(
                '${delivery.totalUnits} units',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
          Text(
            currency.format(delivery.totalAmount),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(Delivery delivery) {
    final timeFormat = DateFormat('h:mm a');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _infoRowAlt(
            'Scheduled',
            timeFormat.format(delivery.scheduledTime),
            Icons.access_time_rounded,
          ),
          if (delivery.deliveredAt != null) ...[
            const SizedBox(height: 10),
            _infoRowAlt(
              'Delivered At',
              timeFormat.format(delivery.deliveredAt!),
              Icons.check_circle_rounded,
              valueColor: const Color(0xFF059669),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRowAlt(String label, String value, IconData icon,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade400),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
              fontSize: 14, color: Colors.grey.shade500),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(Delivery delivery) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
            child: Row(
              children: [
                const Icon(Icons.sticky_note_2_rounded,
                    color: Color(0xFFF59E0B), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Notes',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0A2463),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _showNoteField = !_showNoteField),
                  icon: Icon(
                    _showNoteField ? Icons.close : Icons.edit_rounded,
                    size: 16,
                  ),
                  label: Text(_showNoteField ? 'Cancel' : 'Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0A2463),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _showNoteField
                ? Column(
                    children: [
                      TextField(
                        controller: _noteController,
                        maxLines: 3,
                        style: GoogleFonts.spaceGrotesk(fontSize: 14),
                        decoration: InputDecoration(
                          hintText:
                              'Add delivery notes (e.g. call ahead, gate code)...',
                          hintStyle: GoogleFonts.spaceGrotesk(
                              color: Colors.grey.shade400),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _saveNote,
                          child: Text('Save Note',
                              style: GoogleFonts.spaceGrotesk(fontSize: 15)),
                        ),
                      ),
                    ],
                  )
                : delivery.notes?.isNotEmpty == true
                    ? Text(
                        delivery.notes!,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: const Color(0xFF4A4A6A),
                        ),
                      )
                    : Text(
                        'No notes added.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(Delivery delivery) {
    if (delivery.isCompleted) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF059669), size: 24),
            const SizedBox(width: 10),
            Text(
              'Delivery Confirmed ✓',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF059669),
              ),
            ),
          ],
        ),
      );
    }

    if (delivery.isFailed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 24),
            const SizedBox(width: 10),
            Text(
              'Delivery Failed',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (delivery.isPending)
          ActionButton(
            label: 'Start Delivery',
            icon: Icons.local_shipping_rounded,
            color: const Color(0xFF0A2463),
            onPressed: () => _confirmStatusChange(
                DeliveryStatus.inProgress, 'Start Delivery'),
          ),
        if (delivery.isInProgress) ...[
          ActionButton(
            label: 'Confirm Delivered',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF059669),
            onPressed: () => _confirmStatusChange(
                DeliveryStatus.delivered, 'Confirm Delivered'),
          ),
          const SizedBox(height: 12),
          ActionButton(
            label: 'Mark as Failed',
            icon: Icons.cancel_rounded,
            color: const Color(0xFFDC2626),
            outlined: true,
            onPressed: () =>
                _confirmStatusChange(DeliveryStatus.failed, 'Mark as Failed'),
          ),
        ],
      ],
    );
  }
}

class _ConfirmSheet extends StatelessWidget {
  final Delivery delivery;
  final DeliveryStatus newStatus;
  final String label;

  const _ConfirmSheet({
    required this.delivery,
    required this.newStatus,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = newStatus == DeliveryStatus.delivered ||
        newStatus == DeliveryStatus.inProgress;
    final color =
        isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Icon(
            newStatus == DeliveryStatus.delivered
                ? Icons.check_circle_rounded
                : newStatus == DeliveryStatus.inProgress
                    ? Icons.local_shipping_rounded
                    : Icons.cancel_rounded,
            color: color,
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A2463),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            delivery.customerName,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: const Color(0xFF4A4A6A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Cancel',
                      style: GoogleFonts.spaceGrotesk(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Confirm',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
