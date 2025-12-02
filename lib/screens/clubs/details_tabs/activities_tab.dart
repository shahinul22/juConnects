import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/club_model.dart';
import '../../../models/club_event_model.dart';
import '../../../service/club_service.dart';
import 'event_create_screen.dart';

extension ClubEventDateTime on ClubEvent {
  DateTime get startDateTime => DateTime(
    date.year,
    date.month,
    date.day,
    startTime.hour,
    startTime.minute,
  );

  DateTime get endDateTime => DateTime(
    date.year,
    date.month,
    date.day,
    endTime.hour,
    endTime.minute,
  );
}

class ActivitiesTab extends StatefulWidget {
  final Club club;

  const ActivitiesTab({required this.club, Key? key}) : super(key: key);

  @override
  State<ActivitiesTab> createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends State<ActivitiesTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ClubService _clubService = ClubService();
  final ScrollController _scrollController = ScrollController();

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";

  bool get isAdmin {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return widget.club.admins.contains(uid);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _showCreateButton => isAdmin && _tabController.index == 0;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            color: Colors.white,
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
                          'Club Events',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage and participate in club activities',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    // Create Event Button in Header (Top Right)
                    if (isAdmin && _tabController.index == 0)
                      ElevatedButton.icon(
                        onPressed: () async {
                          final bool? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventCreateScreen(clubId: widget.club.id),
                            ),
                          );
                          if (result == true) setState(() {});
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text(
                          "Create Event",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: primaryColor.withOpacity(0.3),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Custom Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey.shade700,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.event, size: 18),
                        text: "Upcoming",
                      ),
                      Tab(
                        icon: Icon(Icons.event_available, size: 18),
                        text: "Ongoing",
                      ),
                      Tab(
                        icon: Icon(Icons.history, size: 18),
                        text: "Past",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingEvents(),
                _buildOngoingActivities(),
                _buildPastEvents(),
              ],
            ),
          ),
        ],
      ),
      // Create Event Button in Bottom Left Corner

    );
  }

  // ---------------------- STREAMS ----------------------

  Widget _buildUpcomingEvents() {
    return StreamBuilder<List<ClubEvent>>(
      stream: _clubService.getEvents(widget.club.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event_available,
            title: "No Upcoming Events",
            subtitle: "When events are scheduled,\nthey'll appear here",
            actionText: isAdmin ? "Create your first event" : null,
            onAction: isAdmin
                ? () async {
              final bool? result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EventCreateScreen(clubId: widget.club.id),
                ),
              );
              if (result == true) setState(() {});
            }
                : null,
          );
        }

        final now = DateTime.now();
        final upcoming = snapshot.data!
            .where((e) => e.startDateTime.isAfter(now))
            .toList();

        if (upcoming.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event_available,
            title: "No Upcoming Events",
            subtitle: "Check back later for new events",
          );
        }

        upcoming.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: upcoming.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildEventCard(
              upcoming[index],
              isOngoing: false,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOngoingActivities() {
    return StreamBuilder<List<ClubEvent>>(
      stream: _clubService.getEvents(widget.club.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final now = DateTime.now();
        final ongoing = snapshot.data
            ?.where((e) =>
        e.startDateTime.isBefore(now) && e.endDateTime.isAfter(now))
            .toList() ??
            [];

        if (ongoing.isEmpty) {
          return _buildEmptyState(
            icon: Icons.update,
            title: "No Ongoing Activities",
            subtitle: "No programs running right now",
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ongoing.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildEventCard(
            ongoing[index],
            isOngoing: true,
          ),
        );
      },
    );
  }

  Widget _buildPastEvents() {
    return StreamBuilder<List<ClubEvent>>(
      stream: _clubService.getEvents(widget.club.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData) return const SizedBox();

        final now = DateTime.now();
        final past = snapshot.data!
            .where((e) => e.endDateTime.isBefore(now))
            .toList();

        if (past.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history,
            title: "No Past Events",
            subtitle: "Past events will appear here",
          );
        }

        past.sort((a, b) => b.endDateTime.compareTo(a.endDateTime));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: past.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildEventCard(
            past[index],
            isPast: true,
          ),
        );
      },
    );
  }

  // ---------------------- EVENT CARD ----------------------

  Widget _buildEventCard(
      ClubEvent event, {
        bool isOngoing = false,
        bool isPast = false,
      }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color primaryColor = Theme.of(context).primaryColor;

    final isRegistered =
        event.registrationForm?.containsKey(currentUserId) ?? false;
    final participantCount = event.registrationForm?.length ?? 0;
    final participantLimit = event.participantLimit;
    final bool isFull = participantLimit != null &&
        participantCount >= participantLimit &&
        !isRegistered;

    // Determine card colors based on event status
    Color statusColor = primaryColor;
    Color backgroundColor = Colors.white;
    String statusText = "Upcoming";
    IconData statusIcon = Icons.event;

    if (isOngoing) {
      statusColor = Colors.green;
      statusText = "Happening Now";
      statusIcon = Icons.live_tv;
    } else if (isPast) {
      statusColor = Colors.grey.shade600;
      backgroundColor = Colors.grey.shade50;
      statusText = "Completed";
      statusIcon = Icons.check_circle;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  statusIcon,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (event.registrationRequired && !isPast)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 12,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          participantLimit != null
                              ? "$participantCount/$participantLimit"
                              : "$participantCount",
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Event Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Description
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (event.description != null && event.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      event.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Date and Time
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(event.startDateTime),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatTimeRange(
                                event.startDateTime,
                                event.endDateTime,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Registration Button (only for upcoming events)
                if (!isPast && !isOngoing && event.registrationRequired)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isFull
                            ? null
                            : () async {
                          try {
                            if (isRegistered) {
                              await _clubService.unregisterFromEvent(
                                clubId: widget.club.id,
                                eventId: event.id,
                                userId: currentUserId,
                              );
                            } else {
                              await _clubService.registerForEvent(
                                clubId: widget.club.id,
                                eventId: event.id,
                                userId: currentUserId,
                              );
                            }
                            setState(() {});
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRegistered
                              ? Colors.green
                              : primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isRegistered
                                  ? Icons.check_circle
                                  : Icons.how_to_reg,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isFull
                                  ? "Event Full"
                                  : isRegistered
                                  ? "Registered ✓"
                                  : "Register Now",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Additional info for past events
                if (isPast)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            participantLimit != null
                                ? "$participantCount/$participantLimit participants attended"
                                : "$participantCount participants attended",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------- LOADING & EMPTY STATES ----------------------

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          const Text(
            "Loading events...",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            if (actionText != null && onAction != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(actionText),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------- DATE FORMATTERS ----------------------

  String _formatDate(DateTime date) {
    final day = date.day;
    final month = _getMonthName(date.month);
    final year = date.year;
    return '$day $month, $year';
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    final startTime = '${start.hour}:${start.minute.toString().padLeft(2, '0')}';
    final endTime = '${end.hour}:${end.minute.toString().padLeft(2, '0')}';
    return '$startTime - $endTime';
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }
}