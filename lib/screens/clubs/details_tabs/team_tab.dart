import 'package:flutter/material.dart';
import '../../../models/club_model.dart';
import '../../../service/club_service.dart';

class TeamTab extends StatelessWidget {
  final Club club;
  final ClubService clubService;

  const TeamTab({
    required this.club,
    required this.clubService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),

            _sectionTitle("Faculty & Alumni Advisors", Icons.school),
            _buildActiveAdvisors(),

            _sectionTitle("Previous Advisors", Icons.history),
            _buildPreviousAdvisors(),

            const SizedBox(height: 28),

            _sectionTitle("Executive Committee", Icons.leaderboard),
            _buildExecutives(),

            const SizedBox(height: 28),

            _sectionTitle("General Members", Icons.people),
            _buildMembers(),

            const SizedBox(height: 28),

            _sectionTitle("Previous Members", Icons.history_edu),
            _buildPreviousMembers(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[700]!,
            Colors.purple[700]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.groups, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                "Team Management",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Manage your club members and advisors",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // ACTIVE ADVISORS
  // -------------------------------------------------
  Widget _buildActiveAdvisors() {
    return StreamBuilder<List<ClubAdvisor>>(
      stream: clubService.getAdvisors(club.id),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return _buildShimmerLoader();
        final advisors = snapshot.data!;
        if (advisors.isEmpty) return _emptyState("No advisors added", Icons.person_add);

        return _buildPersonList(
          people: advisors,
          isActive: true,
          onAction: (advisor, value) async {
            if (value == 'Remove') {
              await clubService.removeAdvisor(clubId: club.id, advisorId: advisor.name);
            }
          },
          actionItems: [
            _buildPopupItem('Remove', Icons.person_remove, Colors.red),
          ],
          subtitleBuilder: (advisor) => "${advisor.designation} • ${advisor.department}",
          joinDate: (advisor) => advisor.joinDate,
        );
      },
    );
  }

  // -------------------------------------------------
  // PREVIOUS ADVISORS
  // -------------------------------------------------
  Widget _buildPreviousAdvisors() {
    return StreamBuilder<List<ClubAdvisor>>(
      stream: clubService.getPreviousAdvisors(club.id),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return Container();
        final advisors = snapshot.data!;
        if (advisors.isEmpty) return _emptyState("No previous advisors", Icons.history_toggle_off);

        return _buildPersonList(
          people: advisors,
          isActive: false,
          subtitleBuilder: (advisor) => "${advisor.designation} • ${advisor.department}",
          joinDate: (advisor) => advisor.joinDate,
          leaveDate: (advisor) => advisor.leaveDate,
        );
      },
    );
  }

  // -------------------------------------------------
  // EXECUTIVES (editable)
  // -------------------------------------------------
  Widget _buildExecutives() {
    return StreamBuilder<List<ClubMember>>(
      stream: clubService.getExecutives(club.id),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return _buildShimmerLoader();
        final execs = snapshot.data!;
        if (execs.isEmpty) return _emptyState("No executives found", Icons.leaderboard_outlined);

        return _buildPersonList(
          people: execs,
          isActive: true,
          onAction: (member, value) async {
            if (value == 'Remove') {
              await clubService.removeMember(clubId: club.id, uid: member.uid);
            } else {
              await clubService.updateMemberRole(
                  clubId: club.id,
                  uid: member.uid,
                  newRole: value
              );
            }
          },
          actionItems: [
            _buildPopupItem('President', Icons.verified, Colors.green),
            _buildPopupItem('Vice President', Icons.verified, Colors.blue),
            _buildPopupItem('General Secretary', Icons.verified, Colors.orange),
            _buildPopupItem('Remove', Icons.person_remove, Colors.red),
          ],
          subtitleBuilder: (member) => member.designation,
          joinDate: (member) => member.joinDate,
          showBadge: true,
        );
      },
    );
  }

  // -------------------------------------------------
  // ACTIVE MEMBERS (editable)
  // -------------------------------------------------
  Widget _buildMembers() {
    return StreamBuilder<List<ClubMember>>(
      stream: clubService.getMembers(club.id),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return Container();
        final members = snapshot.data!;
        if (members.isEmpty) return _emptyState("No members added", Icons.group_add);

        return _buildPersonList(
          people: members,
          isActive: true,
          onAction: (member, value) async {
            if (value == 'Remove') {
              await clubService.removeMember(clubId: club.id, uid: member.uid);
            } else {
              await clubService.updateMemberRole(
                  clubId: club.id,
                  uid: member.uid,
                  newRole: value
              );
            }
          },
          actionItems: [
            _buildPopupItem('Member', Icons.person, Colors.grey),
            _buildPopupItem('Treasurer', Icons.attach_money, Colors.green),
            _buildPopupItem('Event Manager', Icons.event, Colors.purple),
            _buildPopupItem('Remove', Icons.person_remove, Colors.red),
          ],
          subtitleBuilder: (member) => member.designation,
          joinDate: (member) => member.joinDate,
        );
      },
    );
  }

  // -------------------------------------------------
  // PREVIOUS MEMBERS
  // -------------------------------------------------
  Widget _buildPreviousMembers() {
    return StreamBuilder<List<ClubMember>>(
      stream: clubService.getPreviousMembers(club.id),
      builder: (_, snapshot) {
        if (!snapshot.hasData) return Container();
        final members = snapshot.data!;
        if (members.isEmpty) return _emptyState("No previous members", Icons.history);

        return _buildPersonList(
          people: members,
          isActive: false,
          subtitleBuilder: (member) => "Former ${member.designation}",
          joinDate: (member) => member.joinDate,
          leaveDate: (member) => member.leaveDate,
        );
      },
    );
  }

  // -------------------------------------------------
  // REUSABLE PERSON LIST BUILDER
  // -------------------------------------------------
  Widget _buildPersonList<T>({
    required List<T> people,
    required bool isActive,
    required String Function(T) subtitleBuilder,
    required DateTime Function(T) joinDate,
    DateTime? Function(T)? leaveDate,
    Function(T, String)? onAction,
    List<PopupMenuEntry<String>>? actionItems,
    bool showBadge = false,
  }) {
    return Column(
      children: people.map((person) {
        final name = _getName(person);
        final imageUrl = _getImageUrl(person);
        final role = subtitleBuilder(person);
        final joinDateStr = joinDate(person).toLocal().toString().split(' ')[0];
        final leaveDateStr = leaveDate?.call(person)?.toLocal().toString().split(' ')[0];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.person,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
                if (showBadge && isActive)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.star, color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Alumni",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isActive
                      ? "Joined: $joinDateStr"
                      : "Served: $joinDateStr → ${leaveDateStr ?? 'Present'}",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: isActive && onAction != null && actionItems != null
                ? PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
              onSelected: (value) => onAction(person, value),
              itemBuilder: (_) => actionItems,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            )
                : null,
          ),
        );
      }).toList(),
    );
  }

  // -------------------------------------------------
  // HELPER METHODS
  // -------------------------------------------------
  String _getName(dynamic person) {
    if (person is ClubAdvisor) return person.name;
    if (person is ClubMember) return person.name;
    return 'Unknown';
  }

  String _getImageUrl(dynamic person) {
    if (person is ClubAdvisor) return person.imageUrl;
    if (person is ClubMember) return person.imageUrl;
    return '';
  }

  PopupMenuItem<String> _buildPopupItem(String text, IconData icon, Color color) {
    return PopupMenuItem<String>(
      value: text,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: text == 'Remove' ? Colors.red : Colors.grey[800],
              fontWeight: text == 'Remove' ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue[700], size: 18),
          ),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            msg,
            style: TextStyle(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Column(
      children: List.generate(3, (index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 12,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}