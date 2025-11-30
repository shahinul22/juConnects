import 'package:flutter/material.dart';
import '../../../models/club_model.dart';
import '../../../service/club_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMemberForm extends StatefulWidget {
  final Club club;

  const AddMemberForm({required this.club, Key? key}) : super(key: key);

  @override
  State<AddMemberForm> createState() => _AddMemberFormState();
}

class _AddMemberFormState extends State<AddMemberForm> {
  final ClubService service = ClubService();

  String selectedUser = "";
  String selectedRole = "Member";
  bool isLoadingMember = false;
  bool isLoadingAdvisor = false;

  // Advisor fields
  String advisorName = "";
  String advisorDesig = "";
  String advisorDept = "";
  bool isFaculty = true;

  final List<String> roles = [
    'Member',
    'President',
    'Vice President',
    'General Secretary',
    'Joint Secretary',
    'Assistant Secretary',
    'Organizing Secretary',
    'Treasurer',
    'Financial Controller',
    'Event Manager',
    'Event Coordinator',
    'Logistics Head',
    'Operations Manager',
    'Public Relations Officer',
    'Communications Officer',
    'Media Coordinator',
    'Social Media Manager',
    'Creative Director',
    'Design Head',
    'Technical Head',
    'Content Creator',
    'Graphic Designer',
    'Webmaster',
    'Photographer',
    'Videographer',
    'Membership Coordinator',
    'Outreach Coordinator',
    'Partnership Coordinator',
    'Fundraising Officer',
    'Alumni Relations Officer',
    'Cultural Secretary',
    'Sports Secretary',
    'Academic Head',
    'Research Head',
    'Training Head',
    'Welfare Officer',
    'Equity Officer',
    'Faculty Advisor',
    'Mentor',
    'Legal Advisor',
    'Auditor',
    'Project Manager',
    'Volunteer Coordinator',
    'General Member',
    'Executive Member'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Member / Advisor")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------
            // ADD MEMBER
            // ------------------------------
            const Text("Add Student Member", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("users").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final users = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  value: selectedUser.isNotEmpty ? selectedUser : null,
                  hint: const Text("Select User"),
                  items: users.map((u) {
                    return DropdownMenuItem(
                      value: u.id,
                      child: Text(u["fullName"] ?? "No Name"),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => selectedUser = v ?? ""),
                );
              },
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedRole,
              items: roles
                  .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (v) => setState(() => selectedRole = v ?? "Member"),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoadingMember ? null : _addMember,
                child: isLoadingMember
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Member"),
              ),
            ),

            const Divider(height: 32),

            // ------------------------------
            // ADD ADVISOR
            // ------------------------------
            const Text("Add Advisor (Faculty/Alumni)", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: "Name"),
              onChanged: (v) => advisorName = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Designation"),
              onChanged: (v) => advisorDesig = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Department"),
              onChanged: (v) => advisorDept = v,
            ),
            SwitchListTile(
              value: isFaculty,
              onChanged: (v) => setState(() => isFaculty = v),
              title: const Text("Is Faculty?"),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoadingAdvisor ? null : _addAdvisor,
                child: isLoadingAdvisor
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Advisor"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  // MEMBER BUTTON FUNCTION
  // ------------------------------
  Future<void> _addMember() async {
    if (selectedUser.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a user")),
      );
      return;
    }

    setState(() => isLoadingMember = true);

    try {
      final doc = await FirebaseFirestore.instance.collection("users").doc(selectedUser).get();
      if (!doc.exists) throw "User not found";

      final user = doc.data()!;
      final member = ClubMember(
        uid: selectedUser,
        name: user["fullName"] ?? "",
        imageUrl: user["profilePicUrl"] ?? "",
        designation: selectedRole,
        joinDate: DateTime.now(),
      );

      await service.addMember(clubId: widget.club.id, member: member);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${member.name} added as ${member.designation}")),
      );

      setState(() {
        selectedUser = "";
        selectedRole = "Member";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoadingMember = false);
    }
  }

  // ------------------------------
  // ADVISOR BUTTON FUNCTION
  // ------------------------------
  Future<void> _addAdvisor() async {
    if (advisorName.isEmpty || advisorDesig.isEmpty || advisorDept.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all advisor fields")),
      );
      return;
    }

    setState(() => isLoadingAdvisor = true);

    try {
      final advisor = ClubAdvisor(
        name: advisorName,
        designation: advisorDesig,
        department: advisorDept,
        imageUrl: "https://i.imgur.com/8x8gK4h.png",
        isFaculty: isFaculty,
        joinDate: DateTime.now(),
      );

      await service.addAdvisor(clubId: widget.club.id, advisor: advisor);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${advisor.name} added as advisor")),
      );

      setState(() {
        advisorName = "";
        advisorDesig = "";
        advisorDept = "";
        isFaculty = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoadingAdvisor = false);
    }
  }
}
