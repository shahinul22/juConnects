import 'package:flutter/material.dart';
import '../../../models/club_model.dart';
import '../../../service/club_service.dart';
// import 'add_member_form.dart';
import 'add_member_form.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MembershipTab extends StatelessWidget {
  final Club club;
  final ClubService service = ClubService();

  MembershipTab({required this.club});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final isAdmin = club.admins.contains(uid);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Join Our Community",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(club.whoCanJoin),
          const SizedBox(height: 20),

          // Join button (only if recruitment is open)
          if (club.recruitmentOpen && !isAdmin)
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser!;
                await service.joinClub(
                  clubId: club.id,
                  uid: user.uid,
                  name: user.displayName ?? "Unknown",
                  image: user.photoURL ??
                      "https://i.imgur.com/8x8gK4h.png",
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Request Submitted")),
                );
              },
              child: Text("Join Club"),
            ),

          const SizedBox(height: 20),

          // Admin Button: Add Member
          if (isAdmin)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddMemberForm(club: club),
                  ),
                );
              },
              child: Text("Add Member / Advisor"),
            ),
        ],
      ),
    );
  }
}
