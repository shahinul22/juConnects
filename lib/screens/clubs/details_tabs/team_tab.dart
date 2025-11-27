import 'package:flutter/material.dart';
import '../../../models/club_model.dart';
import '../../../service/club_service.dart';

class TeamTab extends StatelessWidget {
  final Club club;
  final ClubService clubService;

  const TeamTab({required this.club, required this.clubService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ClubMember>>(
      stream: clubService.getExecutives(club.id),
      builder: (context, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!s.hasData || s.data!.isEmpty) {
          return const Center(child: Text("No team members yet."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: s.data!.length,
          itemBuilder: (_, i) {
            final m = s.data![i];
            return Card(
              child: ListTile(
                title: Text(m.name),
                subtitle: Text(m.designation),
                leading:
                CircleAvatar(backgroundImage: NetworkImage(m.imageUrl)),
              ),
            );
          },
        );
      },
    );
  }
}
