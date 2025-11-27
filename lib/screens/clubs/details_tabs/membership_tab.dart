import 'package:flutter/material.dart';
import '../../../models/club_model.dart';

class MembershipTab extends StatelessWidget {
  final Club club;

  const MembershipTab({required this.club});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Join Our Community",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(club.whoCanJoin),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
