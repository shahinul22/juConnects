import 'package:flutter/material.dart';
import '../../../models/club_model.dart';

class ActivitiesTab extends StatelessWidget {
  final Club club;

  const ActivitiesTab({required this.club});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blueAccent,
              tabs: const [
                Tab(text: "Upcoming"),
                Tab(text: "Ongoing"),
                Tab(text: "Past"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildUpcomingEvents(),
                _buildOngoingActivities(),
                _buildPastEvents(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    final upcomingEvents = _getSampleUpcomingEvents();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (upcomingEvents.isEmpty)
            _buildEmptyState(
              icon: Icons.event_available,
              title: "No Upcoming Events",
              description: "Check back later for new events and activities.",
            )
          else ...[
            _sectionTitle("Upcoming Events", Icons.event),
            const SizedBox(height: 16),
            ...upcomingEvents.map((event) => _buildEventCard(event)),
          ],
        ],
      ),
    );
  }

  Widget _buildOngoingActivities() {
    final ongoingActivities = _getSampleOngoingActivities();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Regular Activities", Icons.repeat),
          const SizedBox(height: 16),
          _buildRegularActivities(),
          const SizedBox(height: 24),

          _sectionTitle("Ongoing Programs", Icons.running_with_errors),
          const SizedBox(height: 16),
          if (ongoingActivities.isEmpty)
            _buildEmptyState(
              icon: Icons.update,
              title: "No Ongoing Programs",
              description: "There are no programs running at the moment.",
            )
          else
            ...ongoingActivities.map((activity) => _buildActivityCard(activity)),
        ],
      ),
    );
  }

  Widget _buildPastEvents() {
    final pastEvents = _getSamplePastEvents();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pastEvents.isEmpty)
            _buildEmptyState(
              icon: Icons.history,
              title: "No Past Events",
              description: "Past events and their photos will appear here.",
            )
          else ...[
            _sectionTitle("Recent Events", Icons.history_toggle_off),
            const SizedBox(height: 16),
            ...pastEvents.map((event) => _buildPastEventCard(event)),
          ],
        ],
      ),
    );
  }

  Widget _buildRegularActivities() {
    final regularActivities = [
      {
        'title': 'Weekly Meetings',
        'description': 'Every Wednesday, 5:00 PM at Club Room',
        'icon': Icons.groups,
        'color': Colors.blue,
      },
      {
        'title': 'Workshop Sessions',
        'description': 'Monthly skill development workshops',
        'icon': Icons.workspaces,
        'color': Colors.green,
      },
      {
        'title': 'Social Gatherings',
        'description': 'Monthly networking and social events',
        'icon': Icons.celebration,
        'color': Colors.orange,
      },
      {
        'title': 'Training Programs',
        'description': 'Regular training and development programs',
        'icon': Icons.school,
        'color': Colors.purple,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: regularActivities.length,
      itemBuilder: (context, index) {
        final activity = regularActivities[index];
        return _buildActivityGridItem(
          icon: activity['icon'] as IconData,
          title: activity['title'] as String,
          description: activity['description'] as String,
          color: activity['color'] as Color,
        );
      },
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: event['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(event['icon'], color: event['color'], size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event['date'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: event['statusColor'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event['status'],
                    style: TextStyle(
                      fontSize: 12,
                      color: event['statusColor'],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event['description'],
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  event['location'],
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  event['time'],
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${event['participants']} participants',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const Spacer(),
                if (event['isRegistered'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Registered',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Register'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: activity['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(activity['icon'], color: activity['color'], size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        activity['schedule'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildPastEventCard(Map<String, dynamic> event) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(event['icon'], color: Colors.grey, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event['date'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event['description'],
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            if (event['photos'] > 0)
              Row(
                children: [
                  Icon(Icons.photo_library, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${event['photos']} photos',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View Gallery'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityGridItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, IconData icon) => Row(
    children: [
      Icon(icon, color: Colors.blueAccent),
      const SizedBox(width: 8),
      Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sample data - Replace with actual data from your backend
  List<Map<String, dynamic>> _getSampleUpcomingEvents() {
    return [
      {
        'title': 'Annual Tech Symposium',
        'description': 'Join us for our biggest event of the year featuring industry experts and networking opportunities.',
        'date': 'Dec 15, 2024',
        'time': '9:00 AM - 5:00 PM',
        'location': 'Main Auditorium',
        'icon': Icons.emoji_events,
        'color': Colors.amber,
        'status': 'Upcoming',
        'statusColor': Colors.blue,
        'participants': 45,
        'isRegistered': true,
      },
      {
        'title': 'Web Development Workshop',
        'description': 'Hands-on workshop covering modern web development technologies and best practices.',
        'date': 'Nov 30, 2024',
        'time': '2:00 PM - 4:00 PM',
        'location': 'Computer Lab 3',
        'icon': Icons.computer,
        'color': Colors.purple,
        'status': 'Registration Open',
        'statusColor': Colors.green,
        'participants': 23,
        'isRegistered': false,
      },
    ];
  }

  List<Map<String, dynamic>> _getSampleOngoingActivities() {
    return [
      {
        'title': 'Mentorship Program',
        'description': 'Ongoing mentorship matching senior and junior members for skill development.',
        'schedule': 'Ongoing',
        'icon': Icons.psychology,
        'color': Colors.teal,
      },
    ];
  }

  List<Map<String, dynamic>> _getSamplePastEvents() {
    return [
      {
        'title': 'Hackathon 2024',
        'description': '24-hour coding competition with amazing projects and innovations.',
        'date': 'Oct 20, 2024',
        'icon': Icons.code,
        'color': Colors.blue,
        'photos': 15,
      },
      {
        'title': 'Industry Connect',
        'description': 'Networking event with professionals from various tech companies.',
        'date': 'Sep 15, 2024',
        'icon': Icons.business,
        'color': Colors.orange,
        'photos': 8,
      },
    ];
  }
}