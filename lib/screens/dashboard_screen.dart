import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/delivery_provider.dart';
import '../models/delivery.dart';
import '../services/auth_service.dart';
import '../widgets/delivery_card.dart';
import 'login_screen.dart';
import 'detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  final List<String> _tabs = ['All', 'Pending', 'Active', 'Done'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Delivery> _getTabDeliveries(DeliveryProvider provider) {
    switch (_selectedTab) {
      case 1:
        return provider.pending;
      case 2:
        return provider.inProgress;
      case 3:
        return provider.completed;
      default:
        return provider.deliveries;
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('End Route?',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.spaceGrotesk(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              minimumSize: const Size(80, 44),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await AuthService.logout();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryProvider>(
      builder: (context, provider, _) {
        final deliveries = _getTabDeliveries(provider);

        return Scaffold(
          backgroundColor: const Color(0xFFE8EDF5),
          body: CustomScrollView(
            slivers: [
              _buildAppBar(provider),
              _buildStatsRow(provider),
              _buildTabBar(),
              _buildDeliveryList(provider, deliveries),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(DeliveryProvider provider) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMM').format(now);

    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0A2463),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A2463), Color(0xFF1A4A9A)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good ${_greeting()}, 👋',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: Colors.white60,
                            ),
                          ),
                          Text(
                            AuthService.currentDriverName,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              await provider.resetDemoData();
                            },
                            icon: const Icon(Icons.refresh_rounded,
                                color: Colors.white60),
                            tooltip: 'Reset Demo',
                          ),
                          IconButton(
                            onPressed: _handleLogout,
                            icon: const Icon(Icons.logout_rounded,
                                color: Colors.white60),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.route_rounded,
                          color: Color(0xFF00D4FF), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${AuthService.currentRoute}  •  $dateStr',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          color: const Color(0xFF00D4FF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      title: Text(
        'My Route',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout_rounded, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildStatsRow(DeliveryProvider provider) {
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            _StatCard(
              label: 'Stops',
              value: '${provider.completedCount}/${provider.totalStops}',
              icon: Icons.pin_drop_rounded,
              color: const Color(0xFF0A2463),
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: 'Remaining',
              value: '${provider.remainingCount}',
              icon: Icons.pending_actions_rounded,
              color: const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: 'Collected',
              value: currency.format(provider.totalRevenue),
              icon: Icons.payments_rounded,
              color: const Color(0xFF059669),
              compact: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          labelStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          labelColor: const Color(0xFF0A2463),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: const Color(0xFF00D4FF),
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildDeliveryList(
      DeliveryProvider provider, List<Delivery> deliveries) {
    if (deliveries.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded,
                  size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'All caught up!',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final delivery = deliveries[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DeliveryCard(
                delivery: delivery,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(delivery: delivery),
                  ),
                ),
                onStatusChange: (newStatus) {
                  HapticFeedback.mediumImpact();
                  provider.updateStatus(delivery, newStatus);
                },
              ),
            );
          },
          childCount: deliveries.length,
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool compact;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: compact ? 14 : 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFE8EDF5),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
