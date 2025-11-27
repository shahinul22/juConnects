import 'package:flutter/material.dart';
import '../../../models/club_model.dart';

class GovernanceTab extends StatelessWidget {
  final Club club;

  const GovernanceTab({required this.club});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Rules & Regulations"),
          _card(club.rulesAndRegulations),
          const SizedBox(height: 20),

          _title("Election Process"),
          _card(club.electionProcess),
          const SizedBox(height: 20),

          _title("Meeting Guidelines"),
          _card(club.meetingRules),
        ],
      ),
    );
  }

  Widget _title(String text) => Text(
    text,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );

  Widget _card(String text) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(text),
    ),
  );
}
