import 'package:flutter/material.dart';
import '../../../models/club_model.dart';

class OverviewTab extends StatelessWidget {
  final Club club;

  const OverviewTab({required this.club});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Club Header with Stats
          _buildClubHeader(),
          const SizedBox(height: 24),

          // About Section
          _buildSection(
            title: "About Our Club",
            icon: Icons.info_outline,
            content: club.description.isNotEmpty
                ? club.description
                : "Welcome to ${club.name}! This club focuses on ${club.type}.",
          ),

          const SizedBox(height: 24),

          // Mission & Vision Row
          if (club.mission.isNotEmpty || club.vision.isNotEmpty)
            Row(
              children: [
                if (club.mission.isNotEmpty) ...[
                  Expanded(
                    child: _buildSection(
                      title: "Our Mission",
                      icon: Icons.flag,
                      content: club.mission,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (club.vision.isNotEmpty) ...[
                  Expanded(
                    child: _buildSection(
                      title: "Our Vision",
                      icon: Icons.visibility,
                      content: club.vision,
                    ),
                  ),
                ],
              ],
            ),

          if (club.mission.isNotEmpty || club.vision.isNotEmpty)
            const SizedBox(height: 24),

          // Membership Information
          if (club.whoCanJoin.isNotEmpty || club.membershipCriteria.isNotEmpty)
            _buildSection(
              title: "Membership Information",
              icon: Icons.how_to_reg,
              children: [
                if (club.whoCanJoin.isNotEmpty) ...[
                  _buildInfoItem(
                    icon: Icons.person_add,
                    title: "Who Can Join",
                    content: club.whoCanJoin,
                  ),
                  const SizedBox(height: 12),
                ],
                if (club.membershipCriteria.isNotEmpty) ...[
                  _buildInfoItem(
                    icon: Icons.checklist,
                    title: "Membership Criteria",
                    content: club.membershipCriteria,
                  ),
                ],
              ],
            ),

          if (club.whoCanJoin.isNotEmpty || club.membershipCriteria.isNotEmpty)
            const SizedBox(height: 24),

          // Governance & Rules
          if (club.rulesAndRegulations.isNotEmpty ||
              club.electionProcess.isNotEmpty ||
              club.meetingRules.isNotEmpty)
            _buildSection(
              title: "Governance & Rules",
              icon: Icons.gavel,
              children: [
                if (club.rulesAndRegulations.isNotEmpty) ...[
                  _buildInfoItem(
                    icon: Icons.rule,
                    title: "Rules & Regulations",
                    content: club.rulesAndRegulations,
                  ),
                  const SizedBox(height: 12),
                ],
                if (club.electionProcess.isNotEmpty) ...[
                  _buildInfoItem(
                    icon: Icons.how_to_vote,
                    title: "Election Process",
                    content: club.electionProcess,
                  ),
                  const SizedBox(height: 12),
                ],
                if (club.meetingRules.isNotEmpty) ...[
                  _buildInfoItem(
                    icon: Icons.groups,
                    title: "Meeting Rules",
                    content: club.meetingRules,
                  ),
                ],
              ],
            ),

          const SizedBox(height: 24),

          // Quick Stats
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildClubHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(club.logoUrl),
                  onBackgroundImageError: (_, __) => const Icon(Icons.group),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        club.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (club.moto.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          club.moto,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Text(
                club.type.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    String? content,
    List<Widget>? children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (content != null)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                content,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
          ),
        if (children != null) ...children,
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blueAccent, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text(
                  "Club Stats",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  value: club.memberCount.toString(),
                  label: "Members",
                  icon: Icons.people,
                  color: Colors.green,
                ),
                _buildStatItem(
                  value: club.isMember ? "Joined" : "Not Joined",
                  label: "Your Status",
                  icon: club.isMember ? Icons.check_circle : Icons.person_outline,
                  color: club.isMember ? Colors.green : Colors.orange,
                ),
                _buildStatItem(
                  value: club.type,
                  label: "Category",
                  icon: Icons.category,
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}