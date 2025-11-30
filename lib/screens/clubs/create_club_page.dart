import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/club_model.dart';
import '../../service/club_service.dart';

class CreateClubPage extends StatefulWidget {
  const CreateClubPage({super.key});

  @override
  State<CreateClubPage> createState() => _CreateClubPageState();
}

class _CreateClubPageState extends State<CreateClubPage> {
  final _formKey = GlobalKey<FormState>();
  final ClubService clubService = ClubService();

  final nameController = TextEditingController();
  final motoController = TextEditingController();
  final descriptionController = TextEditingController();
  final missionController = TextEditingController();
  final visionController = TextEditingController();
  final whoCanJoinController = TextEditingController();
  final membershipCriteriaController = TextEditingController();
  final rulesController = TextEditingController();
  final electionController = TextEditingController();
  final meetingController = TextEditingController();

  String clubType = "Academic";

  File? logoFile;
  File? bannerFile;

  Future<String> uploadImage(File file, String folder) async {
    String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    Reference ref = FirebaseStorage.instance.ref().child("$folder/$fileName");

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final String uid = FirebaseAuth.instance.currentUser!.uid;
    String id = FirebaseFirestore.instance.collection('clubs').doc().id;

    String logoUrl = '';
    String bannerUrl = '';

    if (logoFile != null) {
      logoUrl = await uploadImage(logoFile!, "club_logos");
    } else {
      logoUrl = "https://via.placeholder.com/150";
    }

    if (bannerFile != null) {
      bannerUrl = await uploadImage(bannerFile!, "club_banners");
    } else {
      bannerUrl = "https://i.imgur.com/LxWkZp0.png";
    }

    Club club = Club(
      id: id,
      name: nameController.text.trim(),
      moto: motoController.text.trim(),
      type: clubType,
      logoUrl: logoUrl,
      bannerUrl: bannerUrl,
      description: descriptionController.text.trim(),
      mission: missionController.text.trim(),
      vision: visionController.text.trim(),
      whoCanJoin: whoCanJoinController.text.trim(),
      membershipCriteria: membershipCriteriaController.text.trim(),
      rulesAndRegulations: rulesController.text.trim(),
      electionProcess: electionController.text.trim(),
      meetingRules: meetingController.text.trim(),

      // membership (creator auto member)
      isMember: true,
      memberCount: 1,

      // NEW
      createdBy: uid,
      admins: [uid],
    );

    await clubService.createClub(club);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Club created successfully!")),
    );

    Navigator.pop(context);
  }

  Widget imagePickerBox({
    required String label,
    required File? imageFile,
    required VoidCallback onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPick,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child: imageFile == null
                ? const Center(child: Icon(Icons.add_a_photo, size: 40))
                : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(imageFile!, fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Club")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Club Name"),
                validator: (v) => v!.isEmpty ? "Enter club name" : null,
              ),

              TextFormField(
                controller: motoController,
                decoration: const InputDecoration(labelText: "Club Moto"),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField(
                value: clubType,
                items: const [
                  DropdownMenuItem(value: "Academic", child: Text("Academic")),
                  DropdownMenuItem(value: "Cultural", child: Text("Cultural")),
                  DropdownMenuItem(value: "Sports", child: Text("Sports")),
                  DropdownMenuItem(value: "Tech", child: Text("Tech")),
                  DropdownMenuItem(value: "Social", child: Text("Social")),
                  DropdownMenuItem(value: "Arts", child: Text("Arts")),
                  DropdownMenuItem(value: "Music", child: Text("Music")),
                  DropdownMenuItem(value: "Dance", child: Text("Dance")),
                  DropdownMenuItem(value: "Drama", child: Text("Drama")),
                  DropdownMenuItem(value: "Photography", child: Text("Photography")),
                  DropdownMenuItem(value: "Debate", child: Text("Debate")),
                  DropdownMenuItem(value: "Entrepreneurship", child: Text("Entrepreneurship")),
                  DropdownMenuItem(value: "Science", child: Text("Science")),
                  DropdownMenuItem(value: "Environment", child: Text("Environment")),
                  DropdownMenuItem(value: "Volunteer", child: Text("Volunteer")),
                  DropdownMenuItem(value: "Media", child: Text("Media")),
                  DropdownMenuItem(value: "Gaming", child: Text("Gaming")),
                  DropdownMenuItem(value: "Robotics", child: Text("Robotics")),
                  DropdownMenuItem(value: "Coding", child: Text("Coding")),
                  DropdownMenuItem(value: "AI & ML", child: Text("AI & ML")),
                  DropdownMenuItem(value: "Health & Fitness", child: Text("Health & Fitness")),
                  DropdownMenuItem(value: "Language & Literature", child: Text("Language & Literature")),
                  DropdownMenuItem(value: "Travel & Adventure", child: Text("Travel & Adventure")),
                  DropdownMenuItem(value: "Food & Culinary", child: Text("Food & Culinary")),
                  DropdownMenuItem(value: "Film & Media", child: Text("Film & Media")),
                  DropdownMenuItem(value: "Spiritual/Religious", child: Text("Spiritual/Religious")),
                  DropdownMenuItem(value: "Community Service", child: Text("Community Service")),
                  DropdownMenuItem(value: "Photography & Design", child: Text("Photography & Design")),
                  DropdownMenuItem(value: "Innovation & Research", child: Text("Innovation & Research")),

                ],
                onChanged: (v) => setState(() => clubType = v.toString()),
                decoration: const InputDecoration(labelText: "Club Type"),
              ),
              const SizedBox(height: 20),

              imagePickerBox(
                label: "Club Logo",
                imageFile: logoFile,
                onPick: () async {
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() => logoFile = File(picked.path));
                  }
                },
              ),
              const SizedBox(height: 20),

              imagePickerBox(
                label: "Club Banner",
                imageFile: bannerFile,
                onPick: () async {
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() => bannerFile = File(picked.path));
                  }
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: descriptionController,
                maxLines: 2,
                decoration:
                const InputDecoration(labelText: "Short Description"),
              ),
              TextFormField(
                controller: missionController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: "Mission"),
              ),
              TextFormField(
                controller: visionController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: "Vision"),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              TextFormField(
                controller: whoCanJoinController,
                decoration: const InputDecoration(labelText: "Who Can Join"),
              ),
              TextFormField(
                controller: membershipCriteriaController,
                decoration:
                const InputDecoration(labelText: "Membership Criteria"),
              ),
              TextFormField(
                controller: rulesController,
                decoration:
                const InputDecoration(labelText: "Rules & Regulations"),
              ),
              TextFormField(
                controller: electionController,
                decoration:
                const InputDecoration(labelText: "Election Process"),
              ),
              TextFormField(
                controller: meetingController,
                decoration:
                const InputDecoration(labelText: "Meeting Rules"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submit,
                child: const Text("Create Club"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
