import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/club_model.dart';
import '../../service/club_service.dart';

// Import tabs
import 'details_tabs/overview_tab.dart';
import 'details_tabs/activities_tab.dart';
import 'details_tabs/membership_tab.dart';
import 'details_tabs/team_tab.dart';
import 'details_tabs/governance_tab.dart';

// Import Edit Page
import 'edit_club_page.dart';

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _tabBar,
    );
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

class ClubDetailsPage extends StatefulWidget {
  final Club club;

  const ClubDetailsPage({Key? key, required this.club}) : super(key: key);

  @override
  State<ClubDetailsPage> createState() => _ClubDetailsPageState();
}

class _ClubDetailsPageState extends State<ClubDetailsPage>
    with SingleTickerProviderStateMixin {
  final ClubService _clubService = ClubService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    final isAdmin = widget.club.admins.contains(uid);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        floatingActionButton: isAdmin
            ? FloatingActionButton.extended(
          backgroundColor: colorScheme.primary,
          label: const Text("Edit Club"),
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditClubPage(club: widget.club),
              ),
            );
          },
        )
            : null,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            _buildSliverAppBar(theme, colorScheme),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  isScrollable: true,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: colorScheme.primary,
                  ),
                  tabs: const [
                    Tab(icon: Icon(Icons.dashboard_outlined), text: "Overview"),
                    Tab(icon: Icon(Icons.event_outlined), text: "Activities"),
                    Tab(icon: Icon(Icons.people_outlined), text: "Membership"),
                    Tab(icon: Icon(Icons.group_outlined), text: "Team"),
                    Tab(icon: Icon(Icons.description_outlined), text: "Governance"),
                  ],
                ),
              ),
            )
          ],
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: TabBarView(
              children: [
                OverviewTab(club: widget.club),
                ActivitiesTab(club: widget.club),
                MembershipTab(club: widget.club),
                TeamTab(club: widget.club, clubService: _clubService),
                GovernanceTab(club: widget.club),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(ThemeData theme, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: _circleIcon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: _circleIcon(Icons.share),
          onPressed: _shareClub,
        ),
        IconButton(
          icon: _circleIcon(_isFavorite ? Icons.favorite : Icons.favorite_border),
          onPressed: _toggleFavorite,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.club.name),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.club.bannerUrl,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  void _shareClub() {}

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
  }
}
