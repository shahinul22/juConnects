import 'package:flutter/material.dart';
import '../../models/club_model.dart';
import '../../service/club_service.dart';

class EditClubPage extends StatefulWidget {
  final Club club;

  const EditClubPage({super.key, required this.club});

  @override
  State<EditClubPage> createState() => _EditClubPageState();
}

class _EditClubPageState extends State<EditClubPage> {
  final _formKey = GlobalKey<FormState>();
  final ClubService _service = ClubService();

  late TextEditingController name;
  late TextEditingController moto;
  late TextEditingController description;
  late TextEditingController mission;
  late TextEditingController vision;
  late TextEditingController who;
  late TextEditingController criteria;
  late TextEditingController rules;
  late TextEditingController election;
  late TextEditingController meeting;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.club.name);
    moto = TextEditingController(text: widget.club.moto);
    description = TextEditingController(text: widget.club.description);
    mission = TextEditingController(text: widget.club.mission);
    vision = TextEditingController(text: widget.club.vision);
    who = TextEditingController(text: widget.club.whoCanJoin);
    criteria = TextEditingController(text: widget.club.membershipCriteria);
    rules = TextEditingController(text: widget.club.rulesAndRegulations);
    election = TextEditingController(text: widget.club.electionProcess);
    meeting = TextEditingController(text: widget.club.meetingRules);
  }

  @override
  void dispose() {
    name.dispose();
    moto.dispose();
    description.dispose();
    mission.dispose();
    vision.dispose();
    who.dispose();
    criteria.dispose();
    rules.dispose();
    election.dispose();
    meeting.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clubId = widget.club.id;

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Club")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _input(name, "Name"),
              _input(moto, "Moto"),
              _input(description, "Description", max: 4),
              _input(mission, "Mission", max: 4),
              _input(vision, "Vision", max: 4),
              _input(who, "Who Can Join?", max: 2),
              _input(criteria, "Membership Criteria", max: 4),
              _input(rules, "Rules & Regulations", max: 4),
              _input(election, "Election Process", max: 4),
              _input(meeting, "Meeting Rules", max: 4),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  await _service.updateClub(clubId, {
                    "name": name.text.trim(),
                    "moto": moto.text.trim(),
                    "description": description.text.trim(),
                    "mission": mission.text.trim(),
                    "vision": vision.text.trim(),
                    "whoCanJoin": who.text.trim(),
                    "membershipCriteria": criteria.text.trim(),
                    "rulesAndRegulations": rules.text.trim(),
                    "electionProcess": election.text.trim(),
                    "meetingRules": meeting.text.trim(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Club updated successfully!")),
                  );

                  Navigator.pop(context);
                },
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String label, {int max = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        maxLines: max,
        validator: (v) => v!.isEmpty ? "$label required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
